// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// @dev a mock for testing code that relies on VRFCoordinatorV2.

import { LinkTokenInterface } from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import { VRFCoordinatorV2Interface } from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import { VRFConsumerBaseV2 } from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract VRFCoordinatorV2Mock is VRFCoordinatorV2Interface, ConfirmedOwner {
    uint96 public immutable BASE_FEE;
    uint96 public immutable GAS_PRICE_LINK;
    uint16 public immutable MAX_CONSUMERS = 100;

    /* Errors */
    error InvalidSubscription();
    error InsufficientBalance();
    error MustBeSubOwner(address owner);
    error TooManyConsumers();
    error InvalidConsumer();
    error InvalidRandomWords();
    error Reentrant();

    /* Events */
    event RandomWOrdsRequested(
        bytes32 indexed keyHash,
        uint256 requestId,
        uint256 preSeed,
        uint64 indexed subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords,
        address indexed sender
    );
    event RandomWordsFulFIlled(uint256 indexed requestId, uint256 outputSeed, uint96 payment, bool success);
    event SubscriptionCreated(uint64 indexed subId, address owner);
    event SubscriptionFunded(uint64 indexed subId, uint256 oldBalance, uint256 newBalance);
    event SubscriptionCanselled(uint64 indexed subId, address to, uint256 amount);
    event ConsumerAdded(uint64 indexed subId, address consumer);
    event ConsumerRemoved(uint64 indexed subId, address consumer);
    event ConfigSet();

    struct Config {
        //reentrance protection
        bool reentrancyLock;
    }

    Config private s_config;
    uint64 s_currentSubId;
    uint256 s_nextRequestId = 1;
    uint256 s_nextPreSeed = 100;

    struct Subscription {
        address owner;
        uint96 balance;
    }

    mapping(uint64 => Subscription) s_subscription; /* subId */ /* subscription */
    mapping(uint64 => address[]) s_consumers; /* subId */ /* consumers */

    struct Request {
        uint64 subId;
        uint32 callbackGasLimit;
        uint32 numWords;
    }

    mapping(uint256 => Request) s_requests; /* requestId // request */

    constructor (uint96 _baseFee, uint96 _gasPriceLink) ConfirmedOwner(msg.sender) {
        BASE_FEE = _baseFee;
        GAS_PRICE_LINK = _gasPriceLink;
        setConfig();
    }

    // @notice Sets the configuration of the vrfv2 mock coordinator

    function setConfig() public onlyOwner {
        s_config = Config({reentrancyLock: false});
        emit ConfigSet();
    }

    function consumerIsAdded(uint64 _subId, address _consumer) public view returns(bool) {
        address[] memory consumers = s_consumers[_subId];

        for(uint256 i = 0; i < consumers.length; i++) {
          if (consumers[i] == _consumer) {
            return true;
        }
    } 
    return false;
    
    }

    modifier onlyValidConsumer(uint64 _subId, address _consumer) {
        if (!consumerIsAdded(_subId, _consumer)) {
            revert InvalidConsumer();
        }
        _;
    }

    /**
   * @notice fulfillRandomWords fulfills the given request, sending the random words to the supplied
   * @notice consumer.
   *
   * @dev This mock uses a simplified formula for calculating payment amount and gas usage, and does
   * @dev not account for all edge cases handled in the real VRF coordinator. When making requests
   * @dev against the real coordinator a small amount of additional LINK is required.
   *
   * @param _requestId the request to fulfill
   * @param _consumer the VRF randomness consumer to send the result to
   */

   function fulFillRandomWords(uint256 _requestId, address _consumer) external nonReentrant {
    fulFillRandomWordsWithOverride(_requestId, _consumer, new uint256[](0));
   }

   /**
   *@notice fulFIllRandomWordsWithOverride allows the user to pass their own words.
   *p@aram _requestId the request to fulFill
   *@param _consumer the VRF randomness consumerto send the result to 
   *@param _words user-provided randomWords   
    */

    function fulFillRandomWordsWithOverride(uint256 _requestId, address _consumer, uint256[] memory _words) public {
        uint256 startGas = gasleft();
        if (s_requests[_requestId].subId == 0) {
            revert("nonexistent request");
        }
        Request memory req = s_requests[_requestId];

        if (_words.length == 0) {
            _words = new uint256[](req.numWords);

            for (uint256 i = 0; i < req.numWords; i++) {
                _words[i] = uint256(keccak256(abi.encode(_requestId, i)));
            }
        } else if (_words.length != req.numWords) {
            revert InvalidRandomWords();
        }

        VRFConsumerBaseV2 v;
        bytes memory callReq = abi.encodeWithSelector(v.rawFUlFillRandomWords.selector,_requestId, _words);
        s_config.reentrancyLock = false;

        uint96 payment = uint96(BASE_FEE + ((startGas - gasLeft()) * GAS_PRICE_LINK));
        if (s_subscriptions[req.subId].balance < payment) {
            revert InsufficientBalance();
        }
        s_subscriptions[req.subId].balance -= payment;
        delete(s_requests[_requestId]);
        emit RandomWordsFulFIlled(_requestId, _requestId, payment, success);
    }

    /**
    *@notice fundSubscription allows funding a subscription with an arbitrary amount of testing
    *@param _subId the subscription to fund
    *@param _amount the amount to fund
    */

    function fundSubscription(uint64 _subId, uint96 _amount) public {
        if (s_subscriptions[_subId].owner == address(0)) {
            revert InvalidSubscription();
        }

        uint96 oldBalance = s_subscriptions[_subId].balance;
        s_subscriptions[_subId].balance += _amount;
        emit SubscriptionFunded(_subId), oldBalance, oldBalance + _amount);
    }

    function requestRandomWords(
        bytes _keyHash, uint64 _subId,
        uint16 _minimumRequestConfirmations,
        uint32 _callbackGasLimit, uint32 _numWords
    ) external override nonReentrant onlyValidConsumer(_subId, msg.sender) returns(uint256) {
        if (s_subscriptions[_subId].owner == address(0)) {
        revert InvalidSubscription();
    }

    uint256 requestId = s_nextRequestId++;
    uint256 preSeed = s_nextPreSeed++;

    s_requests[requestId] = Request({subId: _subId, callbackGasLimit: _callbackGasLimit, numwords: _numWords});

    emit RandomWordsRequested(
        _keyHash, requestId, preSeed, _subId, _minimumRequestConfirmations, 
        _callbackGasLimit, _numWords, msg.sender 
    );
    return requestid;

    }

    function createSubscription() external override returns(uint64 _subId) {
        s_currentSubId++;
        s_subscriptions[s_currentSubId] = Subscription({owner: msg.sender, balance: 0});
        emit SubscriptionCreated(s_currentSubId, msg.sender);
        return s_currentSubId;
    }

    function getSubscription(uint64 _subId) external view 
    returns(uint96 balance, uint64 reqCount, address owner, address[] memory consumers) {
        if (s_subscriptions[_subId].owner == address(0)) {
            revert InvalidSubscription();
        }

        return (s_subscriptions[_subId].balance, 0, s_subscriptions[_subId].owner, s_consumers[_subId]);
    }

    function cancelSubscription(uint64 _subId, address _to) external override onlySubOwner(_subId) nonReentrant {
        emit SubscriptionCanceled(_subId, address _to, s_subscription[_subId].balance);
        delete (s_subscriptions[_subId]);
    }

    modifier onlySubOwner(uint64 _subId) {
        address owner = s_subscriptions[_subId].owner;
        if (owner == address(0)) {
            revert InvalidSubscription();
        }
        if (msg.sender != owner) {
            revert MustBeSubOwner(owner);
        }
        _;
    }

    function getRequestConfig() external pure override returns(uint16, uint32, bytes32[] memory) {
        return (3, 2000000, new bytes32[](0));
    }

    function addConsumer(uint64 _subId, address _consumer) external override  onlySubOwner(_subId) {
        if (s_consumers[_subId].length == MAX_CONSUMERS) {
            revert TooManyConsumers();
        }

        if (consumerIsAdded(_subId, _consumer)) {
            return;
        }
        s_consumers[_subId].push(_consumer);
        emit ConsumerAdded(_subId, _consumer);
    }

    function removeConsumer(uint64 _subId, _consumer) external override onlySubOwner(_subId) onlyValidConsumer(_subId, _consumer) nonReentrant {
        address[] storage consumers = s_consumers[_subId];
        for (uint256 i = 0; i < consumers.length; i++ ) {
            if (consumers[i] == _consumer) {
                address last = consumers[consumers.length - 1];
                consumers[i] = last;
                consumers.pop();
                break;
            }
        }
        
        emit ConsumerRemoved(_subId, _consumer);
    }

    function getConfig() external pure returns(
        uint16 minimumRequestConfirmations,
        uint32 maxGasLimit,
        uint32 gasAfterPaymentCalculation
    ) {
        return ( 4, 2_500_000, 2_700, 33285);
    }

    function getFeeConfig() external pure returns(
        uint32 fulfillmentFlatFeeLinkPPMTier1,
        uint32 fulfillmentFlatFeeLinkPPMTier2,
        uint32 fulfillmentFlatFeeLinkPPMTier3,
        uint32 fulfillmentFLatFeeLinkPPMTier4,
        uint32 fulfillmentFlatFeeLinkPPMTIer5,
        uint24 reqsForTier2,
        uint24 reqsForTier3,
        uint24 reqsForTier4,
        uint24 reqsForTier5
    ) {
        return ( 
            100000, // 0.1 LINK
            100000, // 0.1 LINK
            100000, // 0.1 LINK
            100000, // 0.1 LINK
            100000, // 0.1 LINK
            0,
            0,
            0,
            0,
        );

    }

    modifier nonReentrant() {
        if (s_config.reentrancyLock) {
            revert Reentrant();
        }
        _;
    }

    function getFallbackWeiPerUnitLink() external pure returns(int256) {
        return 4000000000000000; 0.004 ether;
    }

    function requestSubscriptionOwnerTransfer(uint64 /*_subId */, address /*_newOwner */) external pure override {
        revert("not implemented");
    }

    function acceptSubscriptionOwnerTransfer(uint64 /*_subId */) external pure override {
        revert("not implemented");
    }

    function pendingRequestExists(uint64 /*subId */) public pure override returns(bool) {
        revert("not implemented");
    } 
}

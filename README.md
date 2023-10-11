# foundry-f23-lottery
A foundry-f23 lottery project with transparent smart contracts 

### Proveably Random Raffle Contracts

#### About

This code is to create a proveably random smart contract lottery

#### What we want it to do?

1. Users can enter by paying a ticket
   2. The ticket fees are going to the winner during the draw
3. After X period of time, the lottery will automatically draw a winner
   1. And this one will be done programmatically
4. Usind chainlink VRFV and Chainlink Automation
   1. Chainlink VRF -> Randomness
   2. Chainlink Automation -> Time based trigger    

### Getting started
#### Run these tasks to install needed dependencies

     forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit

     forge install transmissions11/solmate --no-commit   

     forge install ChainAccelOrg/foundry-devops --no-commit    
 
 #### Tests
 1. Write some deploy scripts
 2. Write our tests
    1. Work on local chain
    2. Forked testnet
    3. Forked Mainnet 

#### For easy debuggging purpose,
     forge coverage --report debug
     forge test --debug function_Name 
#### create a coverage.txt file
     forge coverage --report debug > coverage.txt     

#### Tests that need to be covered ,
     Unit tests
     Integration tests
     Forked tests
     Staging tests -> On a mainnet

#### To test your smart contracts, 
     forge test 
     forge test -m function_Name -vvv
     make test   




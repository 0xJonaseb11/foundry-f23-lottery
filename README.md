Author: @Jonas-sebera

 ----------------

# foundry-f23-lottery

A foundry-f23 lottery project with transparent smart contracts

## About

This code is to create a proveably random smart contract lottery

### What we want it to do?

1. Users can enter by paying a ticket
2. The ticket fees are going to the winner during the draw
3. After X period of time, the lottery will automatically draw a winner
   1. And this one will be done programmatically
4. Usind chainlink VRFV and Chainlink Automation
   1. Chainlink VRF -> Randomness
   2. Chainlink Automation -> Time based trigger

#### Tests

 1. Write some deploy scripts
 2. Write our tests
    1. Work on local chain
    2. Forked testnet
    3. Forked Mainnet

#### For easy debuggging purpose

     forge coverage --report debug
     forge test --debug function_Name 

#### create a coverage.txt file

     forge coverage --report debug > coverage.txt     

#### Tests that need to be covered

     Unit tests
     Integration tests
     Forked tests
     Staging tests -> On a mainnet

#### To test your smart contracts

     forge test 
     forge test -m function_Name -vvv
     make test   

<!-- @format -->

# Foundry Smart Contract Lottery

# Table of contents

- [foundry-f23-lottery](#foundry-f23-lottery)
      - [Proveably Random Raffle Contracts](#proveably-random-raffle-contracts)
      - [About](#about)
      - [What we want it to do?](#what-we-want-it-to-do)
      - [Tests](#tests)
      - [For easy debuggging purpose](#for-easy-debuggging-purpose)
      - [create a coverage.txt file](#create-a-coveragetxt-file)
      - [Tests that need to be covered](#tests-that-need-to-be-covered)
      - [To test your smart contracts](#to-test-your-smart-contracts)
- [Foundry Smart Contract Lottery](#foundry-smart-contract-lottery)
- [Table of contents](#table-of-contents)
- [Getting Started](#getting-started)
  - [Start a local node](#start-a-local-node)
  - [Library](#library)
  - [Deploy](#deploy)
  - [Deploy - Other Network](#deploy---other-network)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
- [Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
  - [Scripts](#scripts)
  - [Estimate gas](#estimate-gas)
- [Formatting](#formatting)

# Getting Started

## Start a local node

```
make anvil
```

## Library

If you're having a hard time installing the chainlink library, you can optionally run this command.

```sh
forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit
```

## Deploy

This will default to your local node. You need to have it running in another terminal in order for it to deploy.

```sh
make deploy
```

## Deploy - Other Network

[See below](#deployment-to-a-testnet-or-mainnet)

## Testing

1. Unit
2. Integration
3. Forked
4. Staging

This repo I cover #1 and #3.

```sh
forge test
```

or

```sh
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```sh
forge coverage
```

# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

1. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

2. Deploy

```sh
make deploy ARGS="--network sepolia"
```

This will setup a ChainlinkVRF Subscription for you. If you already have one, update it in the `scripts/HelperConfig.s.sol` file. It will also automatically add your contract as a consumer.

3. Register a Chainlink Automation Upkeep

[You can follow the documentation if you get lost.](https://docs.chain.link/chainlink-automation/compatible-contracts)

Go to [automation.chain.link](https://automation.chain.link/new) and register a new upkeep. Choose `Custom logic` as your trigger mechanism for automation. Your UI will look something like this once completed:

![Automation](./img/automation.png)

## Scripts

After deploying to a testnet or local net, you can run the scripts.

Using cast deployed locally example:

```sh
cast send <RAFFLE_CONTRACT_ADDRESS> "enterRaffle()" --value 0.1ether --private-key <PRIVATE_KEY> --rpc-url $SEPOLIA_RPC_URL
```

or, to create a ChainlinkVRF Subscription:

```sh
make createSubscription ARGS="--network sepolia"
```

## Estimate gas

You can estimate how much gas things cost by running:

```sh
forge snapshot
```

And you'll see an output file called `.gas-snapshot`

# Formatting

To run code formatting:

```sh
forge fmt

```

---

 @Jonas-sebera

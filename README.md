# Timelock

## Introduction
This repo contains a template smart contract with timelock characteristics. There are many real world examples where someone would want to timelock funds so that they can only be released after a certain time period has elapsed. Some of these examples include:
* Equity/Token vesting for ESOP
* Futures option contracts whereby tokens get distributed if the option gets exercised
* Funds gift to a family member which should only unlock when the family member hits a certain age


## Setup dependencies
To install all the dependencies in a all project:
```
npm install --save ethers hardhat @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers web3modal @openzeppelin/contracts 
```
We will also want to install some dev dependencies for testing purposes
```
npm install --save-dev @openzeppelin/test-helpers @nomiclabs/hardhat-web3 web3
```
Don't forget to modify the hardhat.config.js file by adding the following to the top or else the test-helpers will not function properly
```
require("@nomiclabs/hardhat-web3");
```

## Usage
To test the smart contracts using the provide test file:
```
npx hardhat test
```

## Future
There are several upgrades that are available to the current template including:
* Giving the option to specify whether the duration will be in # of blocks or in human time (i.e. seconds, hours)
* Allow for the owner of the timelock deposit box to be changed
* Event based locks (i.e. integrate with Chainlink feeds so that deposit boxes are unlocked based on a real world event as opposed to a time period)

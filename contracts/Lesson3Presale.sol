// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/*
front:
https://muturgan.github.io/lesson3/
https://github.com/muturgan/muturgan.github.io/tree/master/lesson3

contract:
https://github.com/muturgan/bedrosova_lessons/blob/master/contracts/Lesson3Presale.sol
*/

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';


contract Lesson3Presale is ERC20, Ownable {

	uint256 public constant finalTotalSupply = 10000 ether;
	uint256 public constant presaleMaxSupply = 1000  ether;

	uint256 public constant presaleCost1 = 0.001 ether;
	uint256 public constant presaleCost2 = 0.002 ether;

	uint256 public immutable presaleFirstStepStartBlock;
	uint256 public immutable presaleFirstStepEndBlock;
	uint256 public immutable presaleSecondStepEndBlock;

	uint256 public presaleCounter = 0;

	enum PresaleStatus {NotStarted, PresaleStep1, PresaleStep2, PresaleFinished}


	constructor() ERC20('Lesson3Presale', 'L3P') {
		uint256 currentBlock = block.number;
		// using timestamp is not safe
		// 1 block is minted approximately every 13.2 seconds
		presaleFirstStepStartBlock = currentBlock + 23;   // ~ 5 minutes
		presaleFirstStepEndBlock = currentBlock + 13091;  // ~ 2 days
		presaleSecondStepEndBlock = currentBlock + 26182; // ~ 4 days
	}

	function buyOnPresale() external payable {
		uint256 cost = currentPresalePrice();

		uint256 amount = (msg.value * 10**18) / cost;
		require(amount >= 1, 'Too little value!');

		presaleCounter += amount;
		require(
			presaleCounter <= presaleMaxSupply,
			'Final presale supply reached!'
		);

		_mint(msg.sender, amount);
	}

	function stage() public view returns(PresaleStatus) {
		uint256 currentBlock = block.number;

		if (currentBlock < presaleFirstStepStartBlock) {
			return PresaleStatus.NotStarted;
		}
		else if (currentBlock < presaleFirstStepEndBlock) {
			return PresaleStatus.PresaleStep1;
		}
		else if (currentBlock < presaleSecondStepEndBlock) {
			return PresaleStatus.PresaleStep2;
		}
		else {
			return PresaleStatus.PresaleFinished;
		}
	}

	function currentPresalePrice() public view returns(uint256) {
		PresaleStatus stg = stage();

		require(
			stg == PresaleStatus.PresaleStep1 || stg == PresaleStatus.PresaleStep2,
			stg == PresaleStatus.NotStarted
				? 'Presale has not started yet!'
				: 'Presale has already ended!'
		);

		return stg == PresaleStatus.PresaleStep1 ? presaleCost1 : presaleCost2;
	}

	function availableForPresale() external view returns(uint256) {
		PresaleStatus stg = stage();
		return stg == PresaleStatus.PresaleStep1 || stg == PresaleStatus.PresaleStep2
			? presaleMaxSupply - presaleCounter
			: 0;
	}

	function mint(address _to, uint256 _amount) external onlyOwner {
		require(
			totalSupply() + _amount <= finalTotalSupply,
			'Final supply reached!'
		);
		_mint(_to, _amount);
	}

	function withdraw() external onlyOwner {
		payable(owner()).transfer(address(this).balance);
	}

}

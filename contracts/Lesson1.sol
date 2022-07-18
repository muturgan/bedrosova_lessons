// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';


contract Lesson1 is ERC20, Ownable
{
	uint256 public constant MAX_TOTAL_SUPPLY = 2022000000000000000000; // 2022 * 10 ** 18

	constructor(uint256 initialSupply) ERC20('Lesson1Token', 'L1T') {
		_mint(msg.sender, initialSupply * 10 ** decimals());
	}

	function mint(address _to, uint256 _amount) external onlyOwner {
		uint amount = _amount * 10 ** decimals();
		uint256 nextSupply = totalSupply() + amount;
		require(nextSupply <= MAX_TOTAL_SUPPLY, 'supply limit exceeded');
		_mint(_to, amount);
	}
}

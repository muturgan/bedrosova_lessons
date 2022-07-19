//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

contract Lesson2UpgradebleV2 is Initializable, ERC20Upgradeable, OwnableUpgradeable {
	// constructor(uint256 _initialSupply) ERC20('Lesson2Token', 'L2T') {
	// 	_mint(msg.sender, _initialSupply * 10 ** decimals());
	// 	_disableInitializers();
	// }

	// function initialize(uint256 _initialSupply) external initializer {
	// 	__ERC20_init('Lesson2Token', 'L2T');
	// 	__Ownable_init();
	// 	_mint(msg.sender, _initialSupply * 10 ** decimals());
	// }

	function version() external pure returns(uint256) {
		return 2;
	}

	function mint(address _to, uint256 _amount) external onlyOwner {
		_mint(_to, _amount);
	}
}

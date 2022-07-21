// SPDX-License-Identifier: MIT
// https://github.com/muturgan/bedrosova_lessons/blob/master/contracts/Lesson4BlackList.sol
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';


contract Lesson4BlackList is ERC20, Ownable
{
	enum PresaleStatus {NotStarted, PreSale, PresaleFinished}

	uint256 public constant MAX_TOTAL_SUPPLY = 100500 ether;
	uint256 public constant MAX_PRESALE_SUPPLY = 1050 ether;
	uint256 public constant PRESALE_PRICE = 0.001 ether;

	uint256 public immutable presaleStartBlock;
	uint256 public immutable presaleEndBlock;
	uint256 public presaleCounter = 0;

	mapping(address => bool) private blackList;
	/**
	На занятии попросили реализовывать только ту фичу которая есть в ДЗ
	(у меня black list), чтобы посмотреть как мы понимаем суть паттерна.
	И я честно пытался так и сделать.
	Но когда доделал, то осознал что friends это же просто white list с другим назывнием.
	Ну так тому и быть.
	 */
	mapping(address => bool) private myFriends;
	bool private dDay;


	constructor() ERC20('Lesson4BlackList', 'L4B') {
		uint256 currentBlock = block.number;
		// 1 block is mined approximately every 13.2 seconds
		presaleStartBlock = currentBlock + 23;  // ~ 5 minutes
		presaleEndBlock = currentBlock + 26182; // ~ 4 days
	}


	function isItAScam() external pure returns(bool) {
		return false;
	}

	function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override {
		require(addressIsPermitted(_from), 'Sender is not permitted');
		require(addressIsPermitted(_to), 'Recipient is not permitted');
		super._beforeTokenTransfer(_from, _to, _amount);
	}

	function addressIsPermitted(address _addr) internal view returns(bool) {
		return _addr == owner()
			|| _addr == address(0) // we need zero address for minting and burning
			|| (dDay ? myFriends[_addr] : !blackList[_addr]);
	}

	function transferOwnership(address _newOwner) public override onlyOwner {
		require(!blackList[_newOwner], 'new owner is blackListed');
		super._transferOwnership(_newOwner);
	}

	function renounceOwnership() public view override onlyOwner {
		revert('We are already tied up');
	}


	function isBlackListed(address _addr) external view onlyOwner returns(bool) {
		return blackList[_addr];
	}

	function addToBlackList(address _addr) public onlyOwner {
		require(_addr != owner(), 'Hey be careful!');
		require(!myFriends[_addr], 'adding a friend to the blacklist');
		blackList[_addr] = true;
	}

	function addToBlackList(address[] calldata _addresses) external onlyOwner {
		for (uint256 i; i < _addresses.length; i++) {
			addToBlackList(_addresses[i]);
		}
	}

	function removeFromBlackList(address _addr) external onlyOwner {
		blackList[_addr] = false;
	}

	function removeFromBlackList(address[] calldata _addresses) external onlyOwner {
		for (uint256 i; i < _addresses.length; i++) {
			blackList[_addresses[i]] = false;
		}
	}

	function isFriend(address _addr) external view onlyOwner returns(bool) {
		return myFriends[_addr];
	}

	function addToFriends(address _addr) public onlyOwner {
		require(!blackList[_addr], 'adding a blacklisted to friends');
		myFriends[_addr] = true;
	}

	function addToFriends(address[] calldata _addresses) external onlyOwner {
		for (uint256 i; i < _addresses.length; i++) {
			addToFriends(_addresses[i]);
		}
	}

	function removeFromFriends(address _addr) external onlyOwner {
		myFriends[_addr] = false;
	}

	function removeFromFriends(address[] calldata _addresses) external onlyOwner {
		for (uint256 i; i < _addresses.length; i++) {
			blackList[_addresses[i]] = false;
		}
	}

	function isDDay() external view onlyOwner returns(bool) {
		return dDay;
	}

	function setDDay(bool _d) external onlyOwner {
		dDay = _d;
	}


	function buyOnPresale() external payable {
		require(stage() == PresaleStatus.PreSale, 'not a presale period');

		uint256 amount = (msg.value * decimals()) / PRESALE_PRICE;
		require(amount >= 1, 'Too little value!');

		require(
			totalSupply() + amount <= MAX_TOTAL_SUPPLY,
			'Final supply reached!'
		);

		presaleCounter += amount;
		require(
			presaleCounter <= MAX_PRESALE_SUPPLY,
			'Final presale supply reached!'
		);

		_mint(msg.sender, amount);
	}

	function stage() public view returns(PresaleStatus) {
		uint256 currentBlock = block.number;

		if (currentBlock < presaleStartBlock) {
			return PresaleStatus.NotStarted;
		}
		else if (currentBlock < presaleEndBlock) {
			return PresaleStatus.PreSale;
		}
		else {
			return PresaleStatus.PresaleFinished;
		}
	}

	function availableForPresale() external view returns(uint256) {
		PresaleStatus stg = stage();
		return stg == PresaleStatus.PreSale
			? MAX_PRESALE_SUPPLY - presaleCounter
			: 0;
	}

	function mint(address _to, uint256 _amount) external onlyOwner {
		require(
			totalSupply() + _amount <= MAX_TOTAL_SUPPLY,
			'Final supply reached!'
		);
		_mint(_to, _amount);
	}

	function withdraw() external onlyOwner {
		payable(owner()).transfer(address(this).balance);
	}
}

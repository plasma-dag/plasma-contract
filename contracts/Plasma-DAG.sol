pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title PlasmaDAG
 * @author Jae-Yun Kim
 * @notice If you want to make a new PlasmaDAG blockchain, deploy this smart contract to public blockchain like Ethereum.
 * @dev Plasma with DAG structure.
 */
contract PlasmaDAG {
	using SafeMath for uint256;

	// Member variables
	address public operator;
	uint256 public totalSupply;
	string public name;

	/// Contract properties
	uint256 public remainSupply;
	uint256 public nonce;

	///TODO: optimize variable types
	struct Entry{
		uint256 index;
		uint256 value;
		uint256 nonce;
	}
	mapping(address => Entry) internal participants;
	address[] internal pList;

	/// Events
	event Block(uint256);
	event Deposit(address, uint256);
	event Withdraw(address, uint256);

	/// Constructor
	/// The smart contract is used as a vehicle to lock the Ethereum.
	constructor(string memory _name) payable public {
		require(msg.value > 0);
		operator = msg.sender;
		totalSupply = msg.value;
		name = _name;
		remainSupply = totalSupply;
		nonce = 0;
		emit Block(nonce);
	}

	/**
	 * @dev Check a user's balance.
	 * @param _addr The user account to check the balance.
	 * @return The user's balance
	 */
	function balanceOf(address _addr) public view returns (uint256) {
		return participants[_addr].value;
	}

	/**
	 * @dev Check a user's index.
	 * @param _addr The user account to check the index.
	 * @return The user's index
	 */
	function indexOf(address _addr) public view returns (uint256) {
		return participants[_addr].index;
	}

	/**
	 * @dev Check a user's nonce.
	 * @param _addr The user account to check the nonce.
	 * @return The user's nonce
	 */
	function nonceOf(address _addr) public view returns (uint256) {
		return participants[_addr].nonce;
	}

	/**
	 * @dev Put down a deposit to PlasmaDAG smart contract.
	 * @return Let sender know whether the deposit process succeed or not.
	 */
	function deposit() payable public returns (bool) {
		require(remainSupply > msg.value);
		Entry storage entry = participants[msg.sender];
		if (entry.nonce == 0) {
			// New user
			entry.index = pList.push(msg.sender);
			nonce = nonce.add(1);
		}
		entry.value = entry.value.add(msg.value);
		remainSupply = remainSupply.sub(msg.value);
		entry.nonce = entry.nonce.add(1);
		nonce = nonce.add(1);
		emit Deposit(msg.sender, msg.value);
		emit Block(nonce);
		return true;
	}

	/**
	 * @dev Withdraw value from PlasmaDAG smart contract.
	 * @param _value The value that the account wants to withdraw
	 * @return Let user know whether the withdrawal process succeed or not.
	 */
	function withdraw(uint256 _value) public returns (bool) {
		Entry storage entry = participants[msg.sender];
		require(_value <= entry.value);
		entry.value = entry.value.sub(_value);
		remainSupply = remainSupply.add(_value);
		entry.nonce = entry.nonce.add(1);
		nonce = nonce.add(1);
		emit Withdraw(msg.sender, _value);
		emit Block(nonce);
		return true;
	}
}

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
	uint256 public totalSupply_;
	string public name;

  struct BHeader {
		mapping(uint256 => bytes32) hash;
		uint height;
	}
	BHeader[] public finalize_chain;

	uint256 internal totalSupply_;

	///TODO: optimize variable types
	struct Entry{
		uint index;
		uint256 value;
		uint256 nonce;
	}
	mapping(address => Entry) internal entries;
	address[] internal addressList;

	/// Events
	event Deposit(address, uint256);
	event Mint(uint256, uint256);
	event Burn(uint256, uint256);

	/// Constructor
	/// The address of smart contract is used as a vehicle to lock the Ethereum.
  constructor(string _name) public {
    operator = msg.sender;
		totalSupply_ = msg.value;
		Entry storage entry = entries[address(this)];
		entry.value = totalSupply_;
		entry.index = 0;
		addressList.push(address(this));
		name = _name;
  }

	/**
	 * @dev Total number of tokens in existence
	 */
	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}

	/**
	 * @dev The operator can mint token at PlasmaDAG. There is no parameter, because the value is included in the transaction itself; msg.value
	 * @return true if new tokens is minted successfully.
	 */
	function mint() public payable returns (bool) {
		require(msg.sender == operator);
		totalSupply_ = totalSupply_.add(msg.value);
		entries[address(this)].value = entries[address(this)].value.add(msg.value);
		emit Mint(msg.value, totalSupply_);
		return true;
	}

	/**
	 * @dev Check a user's balance.
	 * @param _amount An amount to burn
	 * @return true if the amount of tokens are burned successfully.
	 */
	function burn(_amount) public returns (bool) {
		require(msg.sender == operator);
		require(_amount <= entries[address(this)]);
		totalSupply_ = totalSupply_.sub(_amount);
		entries[address(this)].value = entries[address(this)].value.sub(msg.value);
		operator.send(_amount);
		emit Burn(_amount, totalSupply_);
		return true;
	}

	/**
	 * @dev Put down a deposit to PlasmaDAG smart contract.
	 * @return Let sender know whether the deposit process is succeeded or not.
	 */
	function deposit() public returns (bool) {
		entries[msg.sender] = entries[msg.sender].add(msg.value);
		emit Deposit(msg.sender, msg.value);
		return true;
	}

	/**
	 * @dev Check a user's balance.
	 * @param _addr The user account to check the balance.
	 * @return The user's balance
	 */
	function balanceOf(address _addr) public view returns (uint256) {
		return entries[_addr];
	}

	/**
	 * @dev finalize transaction
	 * @param _root merkle root hash of balance tree
	 * @param _indices the indices of the updated addresses
	 * @param _balances updated balances of the addresses
	 * @param _nonces updated nonce values of the addresses
	 * @return true if the amount is equal to totalSupply_
	 */
	function finalize(bytes32 _root, address[] memory _indices, uint256[] memory _balances, uint256[] _nonces) public returns (bool) {
		uint256 amounts = 0;

		uint j = 0;
		for (uint i = 0; i < entries.length; i++) {
			if (i == _indices[j]) {
				amounts = amounts.add(_balances[_indices[j]]);
				j++;
			} else {
				amounts = amounts.add(entries[i].value);
			}
		}
		require(amounts == totalSupply_);

		Entry storage entry;
		for (uint i = 0; i < _indices.length; i++) {
			entry = entries[_indices[i]];
			entry.value = _balances[i];
			entry.nonce = _nonces[i];
		}
		
		///TODO: Merkle Proof

		return true;
	}

	/**
	 * @dev withdraw deposit
	 * @param _amount
	 * @return true if withdrawal is done successfilly.
	 */
	function withdraw(uint256 _amount) public returns (bool) {
	
	}

	/**
	 * @dev cast a challenge when there is a malicious withdrawal 
	 * @param 
	 * @return 
	 */
	function challenge() {
	
	}
}

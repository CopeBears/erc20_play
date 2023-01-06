pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract ArcadeDAO {
    using SafeMath for uint256;
    // Total supply of Arcade.DAO tokens
    uint256 private totalSupply = 10000000;

    // Ticker symbol for Arcade.DAO tokens
    string private symbol = "$PLAY - DEFLATIONARY WEB3 GAMING";

    // Mapping from Ethereum addresses to balances
    mapping(address => uint256) private balanceOf;
    mapping(address => uint256) private burnedBy;
    mapping(address => uint256) private paidTax;

    // The contract owner's Ethereum address
    address payable private owner;

    // Tax rate for token purchases and sales
    uint256 private taxRate = 4;

    // Maximum tax rate for token purchases and sales
    uint256 private maxTaxRate = 5;

    // Ethereum address of the authorized NFT contract deployer
    address private authorizedNFTcontractDeployer;

    // Constructor function
    constructor() public {
        owner = payable(msg.sender);
        balanceOf[owner] = totalSupply;
        authorizedNFTcontractDeployer = msg.sender;
    }

    function transfer(address _to, uint256 _value) public {
        // Check that the recipient is an EOA
        require(msg.sender == tx.origin);
        // Check that the sender has paid the tax for this transaction

        // Check that the sender has sufficient balance to make the transfer
        require(getBalance(msg.sender) >= _value, "Insufficient balance");
        require(_value > 0, "Invalid transfer amount");

        // Update the balances of the sender and the recipient
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }

    function getBalance(address _address) public view returns (uint256) {
        return balanceOf[_address];
    }

    function burn(uint256 _value) public {
        // Check that the caller has sufficient balance to burn the specified number of tokens
        require(_value <= getBalance(msg.sender), "Insufficient balance");

        // Transfer the burned tokens to the "dead address"
        address deadAddress = 0x0000000000000000000000000000000000000000;
        transfer(deadAddress, _value);

        // Update the burnedBy mapping
        setBurnedBy(msg.sender, getBurnedBy(msg.sender) + _value);
        totalSupply = totalSupply.sub(_value);
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getBurnedBy(address _address) public view returns (uint256) {
        return burnedBy[_address];
    }

    function getPaidTax(address _address) public view returns (uint256) {
        return paidTax[_address];
    }

    function getTaxRate() public view returns (uint256) {
        return taxRate;
    }

    function getAuthorizedNFTcontractDeployer() public view returns (address) {
        return authorizedNFTcontractDeployer;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function setAuthorizedNFTcontractDeployer(
        address _authorizedNFTcontractDeployer
    ) public {
        require(
            msg.sender == owner,
            "Only the contract owner can set the authorizedNFTcontractDeployer"
        );
        authorizedNFTcontractDeployer = _authorizedNFTcontractDeployer;
    }

    function setTaxRate(uint256 _taxRate) public {
        // Check that the caller has the necessary permissions to set the tax rate
        require(
            msg.sender == owner ||
                address(this) == authorizedNFTcontractDeployer,
            "Only the contract owner or authorized NFT contract deployer can set the tax rate"
        );

        // Check that the new tax rate is not greater than the maximum tax rate
        require(
            _taxRate <= maxTaxRate,
            "New tax rate cannot be greater than the maximum tax rate"
        );

        // Set the tax rate
        taxRate = _taxRate;
    }

    function setPaidTax(address _address, uint256 _value) public {
        // Check that the caller has the necessary permissions to set the paidTax mapping
        require(
            msg.sender == owner ||
                address(this) == authorizedNFTcontractDeployer,
            "Only the contract owner or authorized NFT contract deployer can set the paidTax mapping"
        );

        // Set the paidTax mapping for the given Ethereum address
        paidTax[_address] = _value;
    }

    function setBurnedBy(address _address, uint256 _value) public {
        // Check that the caller has the necessary permissions to set the "burnedBy" mapping
        require(
            msg.sender == owner ||
                address(this) == authorizedNFTcontractDeployer,
            "Only the contract owner or authorized NFT contract deployer can set the burnedBy mapping"
        );

        // Set the "burnedBy" mapping for the given Ethereum address
        burnedBy[_address] = _value;
    }
}

pragma solidity >=0.4.22 <0.6.0;

contract MyToken {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(uint256 initialSupply) public {
        // Give the creator all initial tokens
        balanceOf[msg.sender] = initialSupply;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // Check if the sender has enough
        require(balanceOf[msg.sender] >= _value, "Sender don't have enough token.");
        
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to], "Receiver don't have any token");
        
        // Subtract from the sender
        balanceOf[msg.sender] -= _value;
        
        // Add the same to the recipient
        balanceOf[_to] += _value;
        return true;
    }
}

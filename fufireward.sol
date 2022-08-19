pragma solidity ^0.5.17;

 
contract Fufirewards {

    address private _owner;
    mapping(address=>bool) isBlacklisted;

    mapping(address => uint8) private _owners;

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    
    modifier validOwner() {
        require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }

    
    event DepositFunds(address from, uint amount);
    event WithdrawFunds(address from, uint amount);
    event TransferFunds(address from, address to, uint amount);


    constructor() 
        public {
        _owner = msg.sender;
    }

    
    function addOwner(address owner) 
        isOwner 
        public {
        _owners[owner] = 1;
    }

    
    function removeOwner(address owner)
        isOwner
        public {
        _owners[owner] = 0;   
    }

    
    function ()
        external
        payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    
  

    function blackList(address _user) validOwner public  {
        require(!isBlacklisted[_user], "user already blacklisted");
        isBlacklisted[_user] = true;
    }
    
    function removeFromBlacklist(address _user)validOwner public  {
        require(isBlacklisted[_user], "user already whitelisted");
        isBlacklisted[_user] = false;
    }
    
    function transferTo(address payable to, uint amount) validOwner public {
        require(!isBlacklisted[to], "Recipient is backlisted");
        to.transfer(amount);
        emit TransferFunds(msg.sender, to, amount);

    }
  
        function withdraw (uint amount) validOwner public {
        require(address(this).balance >= amount);
        msg.sender.transfer(amount);
        emit WithdrawFunds(msg.sender, amount);
    }
}




//contract address - 0x9FE03c1cc0Df28a8D1F321F3C2fa1e164DB7732a   ,  0xA7Eb478f08DE6155a6a66E11c927E60B6aeb1cf5
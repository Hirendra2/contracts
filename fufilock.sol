pragma solidity ^0.5.17;

contract Fufilock {

    event LogHTLCNew(
        bytes32 indexed contractId,
        address indexed sender,
        address indexed receiver,
        uint amount,
        uint timelock
    );
    event LogHTLCWithdraw(bytes32 indexed contractId);
    event LogHTLCRefund(bytes32 indexed contractId);

    struct LockContract {
        address payable sender;
        address payable receiver;
        uint amount;
        uint timelock; 
        bool withdrawn;
        bool refunded;
    }

    modifier fundsSent() {
        require(msg.value > 0, "msg.value must be > 0");
        _;
    }
    modifier futureTimelock(uint _time) {
    
        require(_time > now, "timelock time must be in the future");
        _;
    }
  
 
    modifier withdrawable(bytes32 _contractId) {
        require(contracts[_contractId].receiver == msg.sender, "withdrawable: not receiver");
        require(contracts[_contractId].withdrawn == false, "withdrawable: already withdrawn");
        require(contracts[_contractId].timelock < now, "withdrawable: timelock time must be in the future");
        _;
    }
    modifier refundable(bytes32 _contractId) {
        require(contracts[_contractId].sender == msg.sender, "refundable: not sender");
        require(contracts[_contractId].refunded == false, "refundable: already refunded");
        require(contracts[_contractId].withdrawn == false, "refundable: already withdrawn");
        require(contracts[_contractId].timelock <= now, "refundable: timelock not yet passed");
        _;
    }

    mapping (bytes32 => LockContract) contracts;

   
    function newContract(address payable _receiver, uint _timelock)
        external
        payable
        fundsSent
        futureTimelock(_timelock)
        returns (bytes32 contractId)
    {
        contractId = sha256(abi.encodePacked(msg.sender, _receiver, msg.value, _timelock)
        );

       
        if (haveContract(contractId))
            revert("Contract already exists");

        contracts[contractId] = LockContract(
            msg.sender,
            _receiver,
            msg.value,
            _timelock,
            false,
            false
        );

        emit LogHTLCNew(
            contractId,
            msg.sender,
            _receiver,
            msg.value,
            _timelock
        );
    }

  
    function withdraw(bytes32 _contractId)
        external payable
        withdrawable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.withdrawn = true;
        c.receiver.transfer(c.amount);
        emit LogHTLCWithdraw(_contractId);
        return true;
    }

   
    function refund(bytes32 _contractId)
        external
        refundable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.refunded = true;
        c.sender.transfer(c.amount);
        emit LogHTLCRefund(_contractId);
        return true;
    }


    function getContract(bytes32 _contractId)
        public
        view
        returns (
            address sender,
            address receiver,
            uint amount,
            uint timelock,
            bool withdrawn,
            bool refunded
                    )
    {
        if (haveContract(_contractId) == false)
            return (address(0), address(0), 0, 0, false, false);
        LockContract storage c = contracts[_contractId];
        return (
            c.sender,
            c.receiver,
            c.amount,
            c.timelock,
            c.withdrawn,
            c.refunded
                    );
    }


    function haveContract(bytes32 _contractId)
        internal
        view
        returns (bool exists)
    {
        exists = (contracts[_contractId].sender != address(0));
    }

}
  


contract address = 0x31d9eACD9F11b62A574a03739aE8Dc4B1C3ef5c0
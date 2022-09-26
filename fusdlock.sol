pragma solidity ^0.5.0;

contract FEP20 {

    function totalSupply() public  returns (uint supply);
    
    function balanceOf(address _owner) public  returns (uint balance);
    
    function transfer(address _to, uint _value) public returns (bool success);
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    
    function approve(address _spender, uint _value) public returns (bool success);
    
    function allowance(address _owner, address _spender) public  returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract HHTimelockFEP20 {
    event HTLCFEP20New(
        bytes32 indexed contractId,
        address indexed sender,
        address indexed receiver,
        address tokenContract,
        uint256 amount,
        uint256 timelock
    );
    event HTLCFEP20Withdraw(bytes32 indexed contractId);
    event HTLCFEP20Refund(bytes32 indexed contractId);

    struct LockContract {
        address sender;
        address receiver;
        address tokenContract;
        uint256 amount;

        uint256 timelock;
        bool withdrawn;
        bool refunded;
    }

    modifier tokensTransferable(address _token, address _sender, uint256 _amount) {
        require(_amount > 0, "token amount must be > 0");
        require(
            FEP20(_token).allowance(_sender, address(this)) >= _amount,
            "token allowance must be >= amount"
        );
        _;
    }
    modifier futureTimelock(uint256 _time) {

        require(_time > now, "timelock time must be in the future");
        _;
    }
    modifier contractExists(bytes32 _contractId) {
        require(haveContract(_contractId), "contractId does not exist");
        _;
    }

    modifier withdrawable(bytes32 _contractId) {
        require(contracts[_contractId].timelock <= now, "refundable: timelock not yet passed");
        require(contracts[_contractId].receiver == msg.sender, "withdrawable: not receiver");
        require(contracts[_contractId].withdrawn == false, "withdrawable: already withdrawn");
        require(contracts[_contractId].refunded == false, "withdrawable: already refunded");
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

  
    function newContract(
        address _receiver,
        uint256 _timelock,
        address _tokenContract,
        uint256 _amount
    )
        external
        tokensTransferable(_tokenContract, msg.sender, _amount)
        futureTimelock(_timelock)
        returns (bytes32 contractId)
    {
        contractId = sha256(
            abi.encodePacked(
                msg.sender,
                _receiver,
                _tokenContract,
                _amount,
                _timelock
            )
        );


        if (haveContract(contractId))
            revert("Contract already exists");

        if (!FEP20(_tokenContract).transferFrom(msg.sender, address(this), _amount))
            revert("transferFrom sender to this failed");

        contracts[contractId] = LockContract(
            msg.sender,
            _receiver,
            _tokenContract,
            _amount,
            _timelock,
            false,
            false
            
        );

        emit HTLCFEP20New(
            contractId,
            msg.sender,
            _receiver,
            _tokenContract,
            _amount,
            _timelock
        );
    }

 
    function withdraw(bytes32 _contractId)
        external
        contractExists(_contractId)
        withdrawable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.withdrawn = true;
        FEP20(c.tokenContract).transfer(c.receiver, c.amount);
        emit HTLCFEP20Withdraw(_contractId);
        return true;
    }

  
    function refund(bytes32 _contractId)
        external
        contractExists(_contractId)
        refundable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.refunded = true;
        FEP20(c.tokenContract).transfer(c.sender, c.amount);
        emit HTLCFEP20Refund(_contractId);
        return true;
    }

    function getContract(bytes32 _contractId)
        public
        view
        returns (
            address sender,
            address receiver,
            address tokenContract,
            uint256 amount,
            uint256 timelock,
            bool withdrawn,
            bool refunded
        )
    {
        if (haveContract(_contractId) == false)
            return (address(0), address(0), address(0), 0,  0, false, false );
        LockContract storage c = contracts[_contractId];
        return (
            c.sender,
            c.receiver,
            c.tokenContract,
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

          function Time_call(uint time) public view returns (uint256){
        return now + time;
    }

}
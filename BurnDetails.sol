pragma solidity ^0.4.6;

contract BurnDetails {

  struct UserStruct {
    string userReferral;
    address userID;
    uint userAmount;
    uint index;
  }
  address private _owner;
  mapping(address => uint8) private _owners;
  mapping(address => UserStruct) private userStructs;
  address[] private userIndex;

  modifier validOwner() {
    require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }

  event LogNewUser   (address indexed userAddress, uint index, string userReferral, address userID,uint userAmount);
  event LogUpdateUser(address indexed userAddress, uint index, string userReferral, address userID , uint userAmount);
  event LogDeleteUser(address indexed userAddress, uint index);
      constructor() public {
        _owner = msg.sender;
    }

        function addOwner(address owner) validOwner public {
          require(_owner ==  msg.sender );
          _owners[owner] = 1;
    }
    
    function removeOwner(address owner) validOwner public {
        require(_owner ==  msg.sender );
        _owners[owner] = 0;   
    }
  
  function isUser(address userAddress) public constant returns(bool isIndeed) {
      if(userIndex.length == 0) return false;
      return (userIndex[userStructs[userAddress].index] == userAddress);
  }

  function insertUser(address userAddress, string userReferral, address userID,uint userAmount) validOwner public returns(uint index){
      if(isUser(userAddress)) revert(); 
      userStructs[userAddress].userReferral = userReferral;
      userStructs[userAddress].userID   = userID;
      userStructs[userAddress].userAmount   = userAmount;
      userStructs[userAddress].index = userIndex.push(userAddress)-1;
      emit LogNewUser(userAddress, userStructs[userAddress].index, userReferral, userID,userAmount);
      return userIndex.length-1;
  }

  function deleteUser(address userAddress) validOwner  public returns(uint index) {
      if(!isUser(userAddress))  revert(); 
      uint rowToDelete = userStructs[userAddress].index;
      address keyToMove = userIndex[userIndex.length-1];
      userIndex[rowToDelete] = keyToMove;
      userStructs[keyToMove].index = rowToDelete; 
      userIndex.length--;
      emit  LogDeleteUser( userAddress, rowToDelete);  
      emit LogUpdateUser(keyToMove, rowToDelete, userStructs[keyToMove].userReferral, userStructs[keyToMove].userID, userStructs[keyToMove].userAmount);
      return rowToDelete;
  }
  
  function getUser(address userAddress)public  constant returns(string userReferral, address userID,uint userAmount, uint index){
    if(!isUser(userAddress))  revert(); 
    return(
      userStructs[userAddress].userReferral, 
      userStructs[userAddress].userID,
      userStructs[userAddress].userAmount, 
 
      userStructs[userAddress].index);
  } 
  
  function updateUserReferral(address userAddress, string userReferral) validOwner  public returns(bool success) {
    if(!isUser(userAddress))  revert(); 
    userStructs[userAddress].userReferral = userReferral;
      emit  LogUpdateUser(userAddress, userStructs[userAddress].index, userReferral, userStructs[userAddress].userID,  userStructs[userAddress].userAmount);
      return true;
  }
  
  function updateUserID(address userAddress, address userID) validOwner public returns(bool success) 
  {
    if(!isUser(userAddress))  revert(); 
    userStructs[userAddress].userID = userID;
  emit LogUpdateUser(userAddress, userStructs[userAddress].index,userStructs[userAddress].userReferral, userID, userStructs[userAddress].userAmount);
    return true;
  }

    function updateUserAmount(address userAddress, uint userAmount) validOwner public returns(bool success) {
    if(!isUser(userAddress))  revert(); 
    userStructs[userAddress].userAmount += userAmount ;
    emit LogUpdateUser(userAddress, userStructs[userAddress].index,userStructs[userAddress].userReferral,  userStructs[userAddress].userID, userAmount);
    return true;
  }

  function getUserCount() public constant returns(uint count){
    return userIndex.length;
  }

  function getUserAtIndex(uint index) public constant returns(address userAddress){
    return userIndex[index];
  }

}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

contract profileupdate{
    
  mapping(address => uint) private addressToIndex;
  mapping(string => uint) private OrganizationToIndex;
  mapping(string => uint) private EmailIdToIndex;
  mapping(string => uint) private GenderToIndex;

  address[] private addresses;
  string[] private Organizations;
  string[] private Designations;
  string[] private EmailIds;
  string[] private ProfileTags;
  string[] private Genders;


 
function User() public {

    addresses.push(msg.sender);
    Organizations.push('self');
    Designations.push('self');
    EmailIds.push('self');
    ProfileTags.push('self');
    Genders.push('self');




    
}
    function hasUser(address userAddress) public view returns(bool hasIndeed) {
        return (addressToIndex[userAddress] > 0 || userAddress == addresses[0]);
      }
    function OrganizationTaken(string memory  Organization) public view returns(bool takenIndeed) {
        return (OrganizationToIndex[Organization] > 0  );
      }
  
  function updeteprofile(string memory Organization, string  memory Designation, string memory Emailid, string memory ProfileTag, string memory Gender) public returns(bool success){
    require(!hasUser(msg.sender));
    require(!OrganizationTaken(Organization));
    addresses.push(msg.sender);
    Organizations.push(Organization);
    Designations.push(Designation);
    EmailIds.push(Emailid);
    ProfileTags.push(ProfileTag);
    Genders.push(Gender);


    addressToIndex[msg.sender] = addresses.length - 1;
    OrganizationToIndex[Organization] = addresses.length - 1;  
    return true;
  }
    function updateOrganization(string memory Organization) public returns(bool success){
        require(hasUser(msg.sender));        
        Organizations[addressToIndex[msg.sender]] = Organization;
        return true;
      }
          function updateDesignation(string memory Designation) public returns(bool success){
        require(hasUser(msg.sender));        
        Designations[addressToIndex[msg.sender]] = Designation;
        return true;
      }

        function updateEmail(string memory Emailid) public returns(bool success){
        require(hasUser(msg.sender));        
        EmailIds[addressToIndex[msg.sender]] = Emailid;
        return true;
      } 

      function updateGender(string memory Gender) public returns(bool success){
        require(hasUser(msg.sender));        
        Genders[addressToIndex[msg.sender]] = Gender;
        return true;
      }

        function updateProfileTag(string memory ProfileTag) public returns(bool success){
        require(hasUser(msg.sender));        
        ProfileTags[addressToIndex[msg.sender]] = ProfileTag;
        return true;
      } 

 
     function getUserCount() public view returns(uint count){
        return addresses.length;
      }

      function getUserByIndex(uint index) public view returns(address userAddress, string memory Organization, string memory Designation, string memory Emailid,string memory ProfileTag, string memory Gender) {
        require(index < addresses.length);
        return(addresses[index], Organizations[index], Designations[index], EmailIds[index],ProfileTags[index], Genders[index]);
      }
    function getAddressByIndex(uint index) public view returns(address userAddress){
        require(index < addresses.length);
        return addresses[index];
      }

  function getUserByAddress(address userAddress) public view returns(uint index, string memory Organization, string  memory Designation, string memory Emailid, string memory ProfileTag, string memory Gender) {
    require(index < addresses.length);
    return(addressToIndex[userAddress], Organizations[addressToIndex[userAddress]], Designations[addressToIndex[userAddress]], EmailIds[addressToIndex[userAddress]], ProfileTags[addressToIndex[userAddress]], Genders[addressToIndex[userAddress]]);
  }
    function getIndexByAddress(address userAddress) public view returns(uint index){
        require(hasUser(userAddress));
        return addressToIndex[userAddress];
      }


    function getUserByEmailid(string memory Email) public view returns(uint index, address userAddress, string memory Designation,  string memory ProfileTag,string memory Gender) {
    require(EmailIdToIndex[Email] < addresses.length);
    return(EmailIdToIndex[Email], addresses[EmailIdToIndex[Email]], Designations[EmailIdToIndex[Email]], ProfileTags[EmailIdToIndex[Email]], Genders[EmailIdToIndex[Email]]);
  }


}
import "utils/Errors.sol";
import "permissions/AddressPropertyManager.sol";

contract PermissionManager is AddressPropertyManager, Errors {

    bytes32 public rootPermName;

    function PermissionManager(address _root, bytes32 _rootPermName){
        _addPropertyAddress(_rootPermName, _root);
        _addAddressProperty(_root, _rootPermName);
        rootPermName = _rootPermName;
    }

    // Add a permission to an account.
    function addAccountPermission(address accountAddr, bytes32 perm) returns (uint16 error){
        if(!_isPropertyAddress(msg.sender, perm) && !_hasProperty(msg.sender, rootPermName)){
            return ACCESS_DENIED;
        }
        _addAddressProperty(accountAddr, perm);
    }

    // Remove an account permission.
    // A permission can not be removed from an account that is an owner of that permission
    // (as they could just re-add themselves).
    function removeAccountPermission(address accountAddr, bytes32 perm) returns (uint16 error) {
        if(_isPropertyAddress(accountAddr, perm) || (!_isPropertyAddress(msg.sender, perm) && !_hasProperty(msg.sender, rootPermName))){
            return ACCESS_DENIED;
        }
        _removeAddressProperty(accountAddr, perm);
    }

    function addPermissionType(bytes32 perm) returns (uint16 error) {
        var add = _addProperty(perm);
        if(!add){
            error = RESOURCE_ALREADY_EXISTS;
        }
    }

    function addPermissionOwner(address accountAddr, bytes32 perm) returns (uint16 error) {
        if(!_isPropertyAddress(msg.sender, perm) && !_hasProperty(msg.sender, rootPermName)){
            return ACCESS_DENIED;
        }
        _addPropertyAddress(perm, accountAddr);
    }

    function removePermissionType(bytes32 perm) returns (uint16 error) {
        if(!_hasProperty(msg.sender, rootPermName)){
            return ACCESS_DENIED;
        }
        _removeProperty(perm);
    }

    function removePermissionOwner(address accountAddr, bytes32 perm) returns (uint16 error) {
        if(!_hasProperty(msg.sender, rootPermName)){
            return ACCESS_DENIED;
        }
        var rem = _removePropertyAddress(accountAddr, perm);
        if(!rem){
            return RESOURCE_NOT_FOUND;
        }
    }

    function hasPermission(address accountAddr, bytes32 perm) constant returns (bool hasPerm){
        return _hasProperty(accountAddr, perm);
    }

    function isPermissionOwner(address accountAddr, bytes32 perm) constant returns (bool isOwner){
        return _isPropertyAddress(accountAddr, perm);
    }

    function isPermission(bytes32 perm) constant returns (bool isPerm){
        return _isProperty(perm);
    }

    /*
    function deleteContract(){
        if(hasPermission(msg.sender, rootPermName)){
            suicide(msg.sender);
        }
    }
    */
}
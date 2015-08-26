import "Committer.sol";
import "Tagger.sol";
import "permissions/PermissionManager.sol";

contract File is Committer, Tagger {

    // Should be on a per-repo basis later.
    PermissionManager pm;

    function File(address creator) {
        pm = new PermissionManager(address(this), "root");
        pm.addAccountPermission(creator, "admin");
    }

    function addTag(bytes32 tag, bytes32 fileHash) returns (uint16 error){
        // Only editors of this contract may write to it.
        if(!isEditor()){
            return ACCESS_DENIED;
        }
        // 'latest' is reserved, and empty tags (or hashes) are not allowed.
        if(tag == "latest" || tag == 0 || fileHash == 0){
            return INVALID_PARAM_VALUE;
        }
        // Can't reference a commit that does not exist.
        if(commits[fileHash].fileHash == 0){
            return INVALID_PARAM_VALUE;
        }
        error = _addTag(tag, fileHash);
    }

    function removeTag(bytes32 tag) returns (uint16 error) {
        // Only admin of this contract may write to it.
        if(!isEditor()){
            return ACCESS_DENIED;
        }
        // 'latest' is reserved, and empty tags are not allowed.
        if(tag == "latest" || tag == 0){
            return INVALID_PARAM_VALUE;
        }
        error = _removeTag(tag);
    }

    function commit(bytes32 fileHash) returns (uint16 error){
        // Only admin of this contract may write to it.
        if(!isEditor()){
            return ACCESS_DENIED;
        }
        // empty hashes are not allowed.
        if(fileHash == 0){
            return INVALID_PARAM_VALUE;
        }
        error = _commit(fileHash, msg.sender);
        if(error == NO_ERROR){
            _updateLatest();
        }
    }

    function commitAndTag(bytes32 tag, bytes32 fileHash) returns (uint16 error){
        // Only admin of this contract may write to it.
        if(!isEditor()){
            return ACCESS_DENIED;
        }
        // 'latest' is reserved, and empty tags (or hashes) are not allowed.
        if(tag == "latest" || tag == 0 || fileHash == 0){
            return INVALID_PARAM_VALUE;
        }
        error = _commit(fileHash, msg.sender);
        if(error != NO_ERROR){
            return;
        }
        error = _addTag(tag, fileHash);
        if(error != NO_ERROR){
            return;
        }
        _updateLatest();
    }

    function isAdmin() constant returns (bool admin) {
        return pm.hasPermission(msg.sender, "admin");
    }

    function isAdmin(address addr) constant returns (bool admin) {
        return pm.hasPermission(addr, "admin");
    }

    function isEditor() constant returns (bool editor) {
        return isAdmin(msg.sender) || pm.hasPermission(msg.sender, "editor");
    }

    function isEditor(address addr) constant returns (bool editor) {
        return isAdmin(addr) || pm.hasPermission(addr, "editor");
    }

    function addEditor(address addr) returns (uint16 error) {
        return pm.addAccountPermission(addr, "editor");
    }

    function removeEditor(address addr) returns (uint16 error) {
        return pm.removeAccountPermission(addr, "editor");
    }

    /*
    function deleteFile(){
        if(isAdmin()){
            pm.deleteContract();
            suicide(msg.sender);
        }
    }
    */

    function _updateLatest() internal {
        var l = commits_bck.length;
        if(l > 0){
            var latestRef = commits_bck[l - 1];
            tags.tagMap["latest"].ref = latestRef;
        }
    }

}
import "assertions/Asserter.sol";
import "permissions/PermissionManager.sol";

contract PermissionManagerTest is Asserter {

    address constant TEST_ADDRESS = 0x13245;
    // TODO const when that works.
    bytes32 ROOT_NAME = "root";
    bytes32 TEST_PROPERTY = "testprop";

    function testCreatePermissionsManager(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        assertBytes32Equal(pm.rootPermName(), ROOT_NAME, "root name not set");
        assertTrue(pm.hasPermission(address(this), ROOT_NAME), "creator is not root");
    }

    function testCreatePermission(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        pm.addPermissionType(TEST_PROPERTY);
        assertTrue(pm.isPermission(TEST_PROPERTY), "pm doesn't have perm");
        assertTrue(pm.isPermissionOwner(address(this), TEST_PROPERTY), "perm creator isn't owner");
    }

    function testAddPermissionOwner(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        pm.addPermissionType(TEST_PROPERTY);
        pm.addPermissionOwner(TEST_ADDRESS, TEST_PROPERTY);
        assertTrue(pm.isPermissionOwner(TEST_ADDRESS, TEST_PROPERTY), "tester isn't owner");
    }

    function testRemovePermissionOwner(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        pm.addPermissionType(TEST_PROPERTY);
        pm.addPermissionOwner(TEST_ADDRESS, TEST_PROPERTY);
        pm.removePermissionOwner(TEST_ADDRESS, TEST_PROPERTY);
        assertFalse(pm.isPermissionOwner(TEST_ADDRESS, TEST_PROPERTY), "tester is owner");
    }

    function testRemovePermission(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        pm.addPermissionType(TEST_PROPERTY);
        pm.removePermissionType(TEST_PROPERTY);
        assertFalse(pm.isPermission(TEST_PROPERTY), "pm has perm");
        assertFalse(pm.isPermissionOwner(address(this), TEST_PROPERTY), "prop creator doesn't have perm");
    }

    function testAddAccountPermission(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        pm.addPermissionType(TEST_PROPERTY);
        pm.addAccountPermission(address(this), TEST_PROPERTY);
        assertTrue(pm.isPermission(TEST_PROPERTY), "pm doesn't have perm");
        assertTrue(pm.hasPermission(address(this), TEST_PROPERTY), "account doesn't have set perm");
    }

    function testRemoveAccountPermission(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        pm.addPermissionType(TEST_PROPERTY);
        pm.addAccountPermission(TEST_ADDRESS, TEST_PROPERTY);
        pm.removeAccountPermission(TEST_ADDRESS, TEST_PROPERTY);
        assertFalse(pm.hasPermission(TEST_ADDRESS, TEST_PROPERTY), "account have set perm");
    }

    function testRemoveAccountPermissionFromOwner(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        pm.addPermissionType(TEST_PROPERTY);
        pm.addAccountPermission(address(this), TEST_PROPERTY);
        pm.removeAccountPermission(address(this), TEST_PROPERTY);
        assertTrue(pm.hasPermission(address(this), TEST_PROPERTY), "owner lost perm");
    }

    /*
    function testDelete(){
        PermissionManager pm = new PermissionManager(address(this), ROOT_NAME);
        var pmAddr = address(pm);
        pmAddr.send(1);
        pm.deleteContract();
        assertUintsEqual(pmAddr.balance, 0, "balance does not match");
    }
    */

}
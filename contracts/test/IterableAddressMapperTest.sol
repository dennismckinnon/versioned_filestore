import "assertions/Asserter.sol";
import "collections/IterableAddressMapper.sol";

contract IAM is IterableAddressMapper {

    IAMap map;

    function addAddress(address addr) returns (bool had) {
        return _addAddress(map, addr);
    }

    function removeAddress(address addr) returns (bool removed) {
        return _removeAddress(map, addr);
    }

    function removeAllAddresses() returns (uint numRemoved) {
        return _removeAllAddresses(map);
    }

    function hasAddress(address addr) constant returns (bool has) {
        return _hasAddress(map, addr);
    }

    function getAddress(uint index) constant returns (address addr) {
        return _getAddress(map, index);
    }

    function getAddressKeyIndex(address addr) constant returns (int index) {
        return _getAddressKeyIndex(map, addr);
    }

    function numAddresses() constant returns (uint mapSize) {
        return _numAddresses(map);
    }
}

contract IterableAddressMapperTest is Asserter {

    address constant TEST_ADDRESS = 0x12345;
    address constant TEST_ADDRESS_2 = 0xABCDEF;
    address constant TEST_ADDRESS_3 = 0xFFFFFF;

    function testAddAddress(){
        IAM iam = new IAM();
        iam.addAddress(TEST_ADDRESS);
        assertTrue(iam.hasAddress(TEST_ADDRESS), "IAM doesn't have address.");
        assertAddressesEqual(iam.getAddress(0), TEST_ADDRESS, "IAM getAddress is 0");
        assertUintsEqual(iam.numAddresses(), 1, "IAM size not 1.");
    }

    function testRemoveAddress(){
        IAM iam = new IAM();
        iam.addAddress(TEST_ADDRESS);
        iam.removeAddress(TEST_ADDRESS);
        assertFalse(iam.hasAddress(TEST_ADDRESS), "IAM still has adddress.");
        assertAddressesEqual(iam.getAddress(0), 0, "IAM getAddress isn't 0");
        assertUintsEqual(iam.numAddresses(), 0, "IAM size not 0.");
    }

    function testAddTwoAddresses(){
        IAM iam = new IAM();
        iam.addAddress(TEST_ADDRESS);
        iam.addAddress(TEST_ADDRESS_2);
        assertTrue(iam.hasAddress(TEST_ADDRESS), "IAM doesn't have address 1.");
        assertTrue(iam.hasAddress(TEST_ADDRESS_2), "IAM doesn't have address 2.");
        assertAddressesEqual(iam.getAddress(1), TEST_ADDRESS_2, "IAM getAddress 2 is 0");
        assertUintsEqual(iam.numAddresses(), 2, "IAM size not 2.");
    }

    function testAddTwoAddressesRemoveLast(){
        IAM iam = new IAM();
        iam.addAddress(TEST_ADDRESS);
        iam.addAddress(TEST_ADDRESS_2);
        iam.removeAddress(TEST_ADDRESS_2);
        assertTrue(iam.hasAddress(TEST_ADDRESS), "IAM doesn't have address 1.");
        assertFalse(iam.hasAddress(TEST_ADDRESS_2), "IAM have address 2.");
        assertAddressesEqual(iam.getAddress(0), TEST_ADDRESS, "IAM getAddress is 0");
        assertAddressesEqual(iam.getAddress(1), 0, "IAM getAddress 2 isn't 0");
        assertUintsEqual(iam.numAddresses(), 1, "IAM size not 1.");
    }

    function testAddTwoAddressesRemoveFirst(){
        IAM iam = new IAM();
        iam.addAddress(TEST_ADDRESS);
        iam.addAddress(TEST_ADDRESS_2);
        iam.removeAddress(TEST_ADDRESS);
        assertFalse(iam.hasAddress(TEST_ADDRESS), "IAM have address 1.");
        assertTrue(iam.hasAddress(TEST_ADDRESS_2), "IAM doesn't have address 2.");
        assertAddressesEqual(iam.getAddress(0), TEST_ADDRESS_2, "IAM getAddress is not correct");
        assertAddressesEqual(iam.getAddress(1), 0, "IAM getAddress 2 isn't 0");
        assertUintsEqual(iam.numAddresses(), 1, "IAM size not 1.");
        assertIntsEqual(iam.getAddressKeyIndex(TEST_ADDRESS), -1, "address 2 still has key index");
        assertIntsEqual(iam.getAddressKeyIndex(TEST_ADDRESS_2), 0, "address has wrong key index");
    }

    function testRemoveAllAddresses(){
        IAM iam = new IAM();
        iam.addAddress(TEST_ADDRESS);
        iam.addAddress(TEST_ADDRESS_2);
        iam.addAddress(TEST_ADDRESS_3);
        iam.removeAllAddresses();
        assertFalse(iam.hasAddress(TEST_ADDRESS), "IAM still has adddress.");
        assertFalse(iam.hasAddress(TEST_ADDRESS_2), "IAM still has adddress 2.");
        assertFalse(iam.hasAddress(TEST_ADDRESS_3), "IAM still has adddress 3.");
        assertAddressesEqual(iam.getAddress(0), 0, "IAM getAddress isn't 0");
        assertUintsEqual(iam.numAddresses(), 0, "IAM size not 0.");
    }

}
import "assertions/Asserter.sol";
import "collections/PropertyMapper.sol";

contract PM is PropertyMapper {

    PMap map;

    function addProperty(bytes32 prop) returns (bool had) {
        return _addProperty(map, prop);
    }

    function removeProperty(bytes32 prop) returns (bool removed) {
        return _removeProperty(map, prop);
    }

    function removeAllProperties() returns (uint numRemoved) {
        return _removeAllProperties(map);
    }

    function hasProperty(bytes32 prop) constant returns (bool has) {
        return _hasProperty(map, prop);
    }

    function getProperty(uint index) constant returns (bytes32 prop) {
        return _getProperty(map, index);
    }

    function getPropertyKeyIndex(bytes32 prop) constant returns (int index) {
        return _getPropertyKeyIndex(map, prop);
    }

    function numProperties() constant returns (uint mapSize) {
        return _numProperties(map);
    }
}

contract PropertyMapperTest is Asserter {

    bytes32 TEST_PROPERTY = "lord";
    bytes32 TEST_PROPERTY_2 = "lard";
    bytes32 TEST_PROPERTY_3 = "lloyd";

    function testAddProperty(){

        PM pm = new PM();
        var x = TEST_PROPERTY;
        pm.addProperty(x);

        assertTrue(pm.hasProperty(TEST_PROPERTY), "IAM doesn't have property.");
        assertBytes32Equal(pm.getProperty(0), TEST_PROPERTY, "IAM getProperty is 0");
        assertUintsEqual(pm.numProperties(), 1, "IAM size not 1.");

    }

    function testRemoveProperty(){
        PM pm = new PM();
        pm.addProperty(TEST_PROPERTY);
        pm.removeProperty(TEST_PROPERTY);
        assertFalse(pm.hasProperty(TEST_PROPERTY), "IAM still has property.");
        assertBytes32Equal(pm.getProperty(0), 0, "IAM getProperty isn't 0");
        assertUintsEqual(pm.numProperties(), 0, "IAM size not 0.");
    }

    function testAddTwoProperties(){
        PM pm = new PM();
        pm.addProperty(TEST_PROPERTY);
        pm.addProperty(TEST_PROPERTY_2);
        assertTrue(pm.hasProperty(TEST_PROPERTY), "IAM doesn't have property 1.");
        assertTrue(pm.hasProperty(TEST_PROPERTY_2), "IAM doesn't have property 2.");
        assertBytes32Equal(pm.getProperty(1), TEST_PROPERTY_2, "IAM getProperty 2 is 0");
        assertUintsEqual(pm.numProperties(), 2, "IAM size not 2.");
    }

    function testAddTwoPropertiesRemoveLast(){
        PM pm = new PM();
        pm.addProperty(TEST_PROPERTY);
        pm.addProperty(TEST_PROPERTY_2);
        pm.removeProperty(TEST_PROPERTY_2);
        assertTrue(pm.hasProperty(TEST_PROPERTY), "IAM doesn't have property 1.");
        assertFalse(pm.hasProperty(TEST_PROPERTY_2), "IAM have property 2.");
        assertBytes32Equal(pm.getProperty(0), TEST_PROPERTY, "IAM getProperty is 0");
        assertBytes32Equal(pm.getProperty(1), 0, "IAM getProperty 2 isn't 0");
        assertUintsEqual(pm.numProperties(), 1, "IAM size not 1.");
    }

    function testAddTwoPropertiesRemoveFirst(){
        PM pm = new PM();
        pm.addProperty(TEST_PROPERTY);
        pm.addProperty(TEST_PROPERTY_2);
        pm.removeProperty(TEST_PROPERTY);
        assertFalse(pm.hasProperty(TEST_PROPERTY), "IAM have property 1.");
        assertTrue(pm.hasProperty(TEST_PROPERTY_2), "IAM doesn't have property 2.");
        assertBytes32Equal(pm.getProperty(0), TEST_PROPERTY_2, "IAM getProperty is not correct");
        assertBytes32Equal(pm.getProperty(1), 0, "IAM getProperty 2 isn't 0");
        assertUintsEqual(pm.numProperties(), 1, "IAM size not 1.");
        assertIntsEqual(pm.getPropertyKeyIndex(TEST_PROPERTY), -1, "property 2 still has key index");
        assertIntsEqual(pm.getPropertyKeyIndex(TEST_PROPERTY_2), 0, "property has wrong key index");
    }

    function testRemoveAllProperties(){
        PM pm = new PM();
        pm.addProperty(TEST_PROPERTY);
        pm.addProperty(TEST_PROPERTY_2);
        pm.addProperty(TEST_PROPERTY_3);
        pm.removeAllProperties();
        assertFalse(pm.hasProperty(TEST_PROPERTY), "PM still has property.");
        assertFalse(pm.hasProperty(TEST_PROPERTY_2), "PM still has property 2.");
        assertFalse(pm.hasProperty(TEST_PROPERTY_3), "PM still has property 3.");
        assertBytes32Equal(pm.getProperty(0), 0, "PM getProperty isn't 0");
        assertUintsEqual(pm.numProperties(), 0, "PM size not 0.");
    }

}
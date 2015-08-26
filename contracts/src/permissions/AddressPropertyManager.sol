import "collections/IterableAddressMapper.sol";
import "collections/PropertyMapper.sol";

// TODO make account props and props iterable.
contract AddressPropertyManager is IterableAddressMapper, PropertyMapper {

    // Address properties. These are the properties set for each account.
    mapping(address => PMap) accProps;
    // Properties. This mapping ties a property to a number of addresses. To give accounts a property,
    // the property must first be registered here, and the "issuer" must be in the list of addresses
    // for that property.
    mapping(bytes32 => IAMap) props;

    // Add a property to an account.
    function _addAddressProperty(address accountAddr, bytes32 property) internal returns (bool added){
        return _addProperty(accProps[accountAddr], property);
    }

    // Remove an account property.
    function _removeAddressProperty(address accountAddr, bytes32 property) internal returns (bool removed) {
        return _removeProperty(accProps[accountAddr], property);
    }

    function _addProperty(bytes32 property) internal returns (bool added) {
        if(_numAddresses(props[property]) > 0){
            return false;
        }
        return _addAddress(props[property], msg.sender);
    }

    function _addPropertyAddress(bytes32 property, address addr) internal returns (bool added) {
        _addAddress(props[property], addr);
    }

    function _removeProperty(bytes32 property) internal returns (bool removed) {
        if(_numAddresses(props[property]) == 0){
            return false;
        }
        _removeAllAddresses(props[property]);
        return true;
    }

    function _removePropertyAddress(address accountAddr, bytes32 property) internal returns (bool removed) {
        return _removeAddress(props[property], accountAddr);
    }

    function _hasProperty(address accountAddr, bytes32 property) internal constant returns (bool hasProp){
        return _hasProperty(accProps[accountAddr], property);
    }

    function _isPropertyAddress(address accountAddr, bytes32 property) internal constant returns (bool isOwner){
        return _hasAddress(props[property], accountAddr);
    }

    function _isProperty(bytes32 property) internal constant returns (bool isProp){
        return _numAddresses(props[property]) > 0;
    }

    function _numAccProperties(address addr) internal constant returns (uint numProps){
        return _numProperties(accProps[addr]);
    }

    function _numPropAddresses(bytes32 prop) internal constant returns (uint numAddr){
        return _numAddresses(props[prop]);
    }

}
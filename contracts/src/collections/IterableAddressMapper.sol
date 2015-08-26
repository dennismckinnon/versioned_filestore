/// @title AddressMap
/// @author Andreas Olofsson (andreas@erisindustries.com)
/// @dev IterableAddressMap is an iterable map with (address, bool) entries. Order of insertion is not preserved.
contract IterableAddressMapper {

    struct IAMElement {
        uint keyIndex;
        bool exists;
    }

    struct IAMap
    {
        mapping(address => IAMElement) data;
        address[] keys;
        uint size;
    }

    function _addAddress(IAMap storage map, address addr) internal returns (bool added)
    {
        var exists = map.data[addr].exists;
        if (exists){
            return false;
        } else {
            var keyIndex = map.keys.length++;
            map.data[addr] = IAMElement(keyIndex, true);
            map.keys[keyIndex] = addr;
            map.size++;
            return true;
        }
    }

    function _removeAddress(IAMap storage map, address addr) internal returns (bool removed)
    {
        var elem = map.data[addr];
        var exists = elem.exists;
        if (!exists){
            return false;
        }
        var keyIndex = elem.keyIndex;
        delete map.data[addr];
        var len = map.keys.length;
        if(keyIndex != len - 1){
            var addrSwap = map.keys[len - 1];
            map.keys[keyIndex] = addrSwap;
            map.data[addrSwap].keyIndex = keyIndex;
        }
        map.keys.length--;
        map.size--;
    }

    function _removeAllAddresses(IAMap storage map) internal returns (uint numRemoved){
        var l = map.keys.length;
        for(uint i = 0; i < l; i++){
            delete map.data[map.keys[i]];
        }
        delete map.keys;
        map.size = 0;
        return l;
    }

    function _hasAddress(IAMap storage map, address addr) internal constant returns (bool has){
        return map.data[addr].exists;
    }

    function _getAddress(IAMap storage map, uint index) internal constant returns (address addr){
        if(index >= map.keys.length){
            return 0;
        }
        return map.keys[index];
    }

    function _getAddressKeyIndex(IAMap storage map, address addr) internal constant returns (int index){
        var elem = map.data[addr];
        if(!elem.exists){
            return -1;
        }
        return int(elem.keyIndex);
    }

    function _numAddresses(IAMap storage map) internal constant returns (uint mapSize){
        return map.size;
    }

}
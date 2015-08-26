/// @title PropertyMap
/// @author Andreas Olofsson (andreas@erisindustries.com)
/// @dev PropertyMapper is an iterable map with (bytes32, bool) entries. Order of insertion is not preserved.
contract PropertyMapper {

    struct PMElement {
        uint keyIndex;
        bool exists;
    }

    struct PMap
    {
        mapping(bytes32 => PMElement) data;
        bytes32[] keys;
        uint size;
    }

    function _addProperty(PMap storage map, bytes32 prop) internal returns (bool added)
    {
        var exists = map.data[prop].exists;
        if (exists){
            return false;
        } else {
            var keyIndex = map.keys.length++;
            map.data[prop] = PMElement(keyIndex, true);
            map.keys[keyIndex] = prop;
            map.size++;
            return true;
        }
    }

    function _removeProperty(PMap storage map, bytes32 prop) internal returns (bool removed)
    {
        var elem = map.data[prop];
        var exists = elem.exists;
        if (!exists){
            return false;
        }
        var keyIndex = elem.keyIndex;
        delete map.data[prop];
        var len = map.keys.length;
        if(keyIndex != len - 1){
            var pSwap = map.keys[len - 1];
            map.keys[keyIndex] = pSwap;
            map.data[pSwap].keyIndex = keyIndex;
        }
        map.keys.length--;
        map.size--;
    }

    function _removeAllProperties(PMap storage map) internal returns (uint numRemoved){
        var l = map.keys.length;
        for(uint i = 0; i < l; i++){
            delete map.data[map.keys[i]];
        }
        delete map.keys;
        map.size = 0;
        return l;
    }

    function _hasProperty(PMap storage map, bytes32 prop) internal constant returns (bool has){
        return map.data[prop].exists;
    }

    function _getProperty(PMap storage map, uint index) internal constant returns (bytes32 property){
        if(index >= map.keys.length){
            return 0;
        }
        return map.keys[index];
    }

    function _getPropertyKeyIndex(PMap storage map, bytes32 prop) internal constant returns (int index){
        var elem = map.data[prop];
        if(!elem.exists){
            return -1;
        }
        return int(elem.keyIndex);
    }

    function _numProperties(PMap storage map) internal constant returns (uint mapSize){
        return map.size;
    }

}
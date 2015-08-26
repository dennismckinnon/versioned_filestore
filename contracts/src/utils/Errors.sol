// Categories offset by 1000; each with a generic message at the start. Sub-categories offset by 100.
contract Errors {

    // ********************** Normal execution **********************

    uint16 constant NO_ERROR = 0;

    // ********************** Resources **********************

    uint16 constant RESOURCE_ERROR = 1000;
    uint16 constant RESOURCE_NOT_FOUND = 1001;
    uint16 constant RESOURCE_ALREADY_EXISTS = 1002;

    // ********************** Access **********************

    uint16 constant ACCESS_DENIED = 2000;

    // ********************** Input **********************

    uint16 constant PARAMETER_ERROR = 3000;
    uint16 constant INVALID_PARAM_VALUE = 3001;
    uint16 constant NULL_PARAM_NOT_ALLOWED = 3002;
    uint16 constant INTEGER_OUT_OF_BOUNDS = 3003;
    // Arrays
    uint16 constant ARRAY_INDEX_OUT_OF_BOUNDS = 3100;

}
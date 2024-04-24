pragma solidity ^0.8.0;

import "./Roles.sol";
import "../utils/Context.sol";

contract GrocerRole is Context {
    using Roles for Roles.Role;

    event GrocerAdded(address indexed account);
    event GrocerRemoved(address indexed account);

    Roles.Role private Grocers;

    constructor() public {
        _addNewGrocer(_msgSender());
    }

    modifier grocerExists() {
        require(grocerPresent(_msgSender()));
        _;
    }

    function grocerPresent(address account) public view returns (bool) {
        return Grocers.has(account);
    }

    function addNewGrocer(address account) public grocerExists {
        _addNewGrocer(account);
    }

    function renounceExistingGrocer() public {
        _removeExistingGrocer(_msgSender());
    }

    function _addNewGrocer(address account) internal {
        Grocers.add(account);
        emit GrocerAdded(account);
    }

    function _removeExistingGrocer(address account) internal {
        Grocers.remove(account);
        emit GrocerRemoved(account);
    }
}

pragma solidity ^0.8.0;

import "./Roles.sol";
import "../utils/Context.sol";

contract CustomerRole is Context {
    
    using Roles for Roles.Role;
    event CustomerAdded(address indexed account);
    event CustomerRemoved(address indexed account);

    Roles.Role private customer;

    constructor() public {
        _addNewCustomer(_msgSender());
    }

    modifier customerExists() {
        require(customerPresent(_msgSender()));
        _;
    }

    function customerPresent(address account) public view returns (bool) {
        return customer.has(account);
    }

    function addNewCustomer(address account) public customerExists {
        _addNewCustomer(account);
    }

    function renounceExistingCustomer(address account) public {
        _removeExistingCustomer(account);
    }

    function _addNewCustomer(address account) internal {
        customer.add(account);
        emit CustomerAdded(account);
    }

    function _removeExistingCustomer(address account) internal {
        customer.remove(account);
        emit CustomerRemoved(account);
    }
}

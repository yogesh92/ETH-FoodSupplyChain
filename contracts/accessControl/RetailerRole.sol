pragma solidity ^0.8.0;

import "./Roles.sol";
import "../utils/Context.sol";

contract RetailerRole is Context {
    using Roles for Roles.Role;

    event RetailerAdded(address indexed account);
    event RetailerRemoved(address indexed account);

    Roles.Role private Retailers;


    constructor() public {
        _addNewRetailer(_msgSender());
    }


    modifier retailerExists() {
        require(retailerPresent(_msgSender()));
        _;
    }


    function retailerPresent(address account) public view returns (bool) {
        return Retailers.has(account);
    }


    function addNewRetailer(address account) public retailerExists {
        _addNewRetailer(account);
    }


    function renounceExistingRetailer() public {
        _removeExistingRetailer(_msgSender());
    }


    function _addNewRetailer(address account) internal {
       Retailers.add(account);
        emit RetailerAdded(account);
    }

    function _removeExistingRetailer(address account) internal {
       Retailers.remove(account);
        emit RetailerRemoved(account);
    }
}

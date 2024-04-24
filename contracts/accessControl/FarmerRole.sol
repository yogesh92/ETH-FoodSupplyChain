pragma solidity ^0.8.0;

import "./Roles.sol";
import "../utils/Context.sol";

contract FarmerRole is Context {
    using Roles for Roles.Role;

    event FarmerAdded(address indexed account);
    event FarmerRemoved(address indexed account);

    Roles.Role private farmers;

    constructor() public {
        _addNewFarmer(_msgSender());
    }

    modifier farmerExists() {
        require(farmerPresent(_msgSender()));
        _;
    }

    function farmerPresent(address account) public view returns (bool) {
        return farmers.has(account);
    }

    function addNewFarmer(address account) public farmerExists {
        _addNewFarmer(account);
    }

    function renounceExistingFarmer() public {
        _removeExistingFarmer(_msgSender());
    }

    function _addNewFarmer(address account) internal {
        farmers.add(account);
        emit FarmerAdded(account);
    }

    function _removeExistingFarmer(address account) internal {
        farmers.remove(account);
        emit FarmerRemoved(account);
    }
}

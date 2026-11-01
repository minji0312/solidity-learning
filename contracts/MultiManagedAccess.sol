// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract MultiManagedAccess {
    address public owner;
    address[] public managers;
    mapping(address => bool) public confirmed;

    constructor(address _owner, address[] memory _managers) {
        require(_managers.length >= 3, "At least 3 managers required");
        owner = _owner;
        for (uint256 i = 0; i < _managers.length; i++) {
            managers.push(_managers[i]);
        }
    }

    function isManager(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < managers.length; i++) {
            if (managers[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    function allConfirmed() public view returns (bool) {
        for (uint256 i = 0; i < managers.length; i++) {
            if (!confirmed[managers[i]]) {
                return false;
            }
        }
        return true;
    }

    function reset() internal {
        for (uint256 i = 0; i < managers.length; i++) {
            confirmed[managers[i]] = false;
        }
    }

    function confirm() external {
        require(isManager(msg.sender), "You are not a manager");
        confirmed[msg.sender] = true;
    }

    modifier onlyAllConfirmed() {
        require(isManager(msg.sender), "You are not a manager");
        require(allConfirmed(), "Not all confirmed yet");
        reset();
        _;
    }
}
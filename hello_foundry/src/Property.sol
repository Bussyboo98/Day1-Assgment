// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PropertyManagement is AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IERC20 public propertyPaymentToken;
    uint256 public propertyCount;

    struct Property {
        uint256 propertyId;
        string propertyName;
        string propertyLocation;
        uint256 propertyPrice;
        address propertyCreator;
        uint256 createdTimestamp;
        bool isActive;
        bool isForSale;
    }

    //error mesages
    error NotPropertyOwner();
    error PropertyDoesNotExist();
    error NotForSale();
    error CannotBuyOwnProperty();
    error PaymentFailed();

    mapping(uint256 => Property) public properties;

    event PropertyCreated(uint256 id, string propertyName, string propertyLocation, address creator,
        uint256 price,uint256 timestamp);

    event PropertyRemoved(uint256  id);
    event PropertyPurchased(uint256  id, address oldOwner,  address newOwner );

    constructor(address _tokenAddress) {
        propertyPaymentToken = IERC20(_tokenAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    modifier propertyExists(uint256 _id) {
        if (properties[_id].propertyCreator == address(0)) {
            revert PropertyDoesNotExist();
        }
        _;
    }

    modifier onlyPropertyOwner(uint256 _id) {
        if (properties[_id].propertyCreator != msg.sender) {
            revert NotPropertyOwner();
        }
        _;
    }

   //create the property
    function createProperty(string memory _propertyName, string memory _propertyLocation, uint256 _propertyPrice) public {
        require(_propertyPrice == 0, "Invalid Price");
        

        propertyCount++;
        properties[propertyCount] = Property({
            propertyId: propertyCount,
            propertyName: _propertyName,
            propertyLocation: _propertyLocation,
            propertyPrice: _propertyPrice,
            propertyCreator: msg.sender,
            createdTimestamp: block.timestamp,
            isActive: true,
            isForSale: true
        });
        emit PropertyCreated(propertyCount, _propertyName, _propertyLocation, msg.sender, _propertyPrice,block.timestamp);
    }

    //remove property by creator
    function removeProperty(uint256 _id) publicpropertyExists(_id) onlyPropertyOwner(_id){
        delete properties[_id];

        emit PropertyRemoved(_id);
    }

 
    //buying of properties
    function buyProperty(uint256 _id) public propertyExists(_id){
        Property storage buy_property = properties[_id];

        if (!buy_property.isForSale) {
            revert NotForSale();
        }

        if (msg.sender == buy_property.propertyCreator) {
            revert CannotBuyOwnProperty();
        }

        bool success = propertyPaymentToken.transferFrom(
            msg.sender,
            buy_property.propertyCreator,
            buy_property.propertyPrice
        );

        if (!success) {
            revert PaymentFailed();
        }

        address oldOwner = buy_property.propertyCreator;

        buy_property.propertyCreator = msg.sender;
        buy_property.isForSale = false;

        emit PropertyPurchased(_id, oldOwner, msg.sender);
    }

    //admin 
    function updatePaymentToken(address _newToken) public onlyRole(ADMIN_ROLE){
        propertyPaymentToken = IERC20(_newToken);
    }


    function getProperty(uint256 _id) public view returns (Property memory) {
        return properties[_id];
    }

}

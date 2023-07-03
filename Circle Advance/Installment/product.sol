// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./order.sol";

contract Product {
    address public seller;
    string public title;
    string public description;
    uint256 public price;
    address public sellerWallet;
    Order[] public orders;
    mapping(address => uint256) public orderIDs;
    mapping(address => bool) public isCustomer;

    constructor(
        address _seller,
        string memory _title,
        string memory _description,
        uint256 _price,
        address _sellerWallet
    ) {
        seller = _seller;
        title = _title;
        description = _description;
        price = _price;
        sellerWallet = _sellerWallet;
    }

    function placeOrder(
        address _customerAddress,
        uint256 _orderQuantity,
        bool fullPayment
    ) external {
        uint256 newOrderID = orders.length;
        Order newOrder = new Order(
            _customerAddress,
            sellerWallet,
            _orderQuantity * price,
            address(this),
            _orderQuantity
        );
        orders.push(newOrder);
        orderIDs[address(newOrder)] = newOrderID;
        isCustomer[_customerAddress] = true;
        if (fullPayment) {
            newOrder.payFull(_customerAddress);
        } else {
            newOrder.payInstallment(_customerAddress);
        }
    }

    function payInstallement(
        address _customerAddress,
        address _orderAddress
    ) external {
        uint256 orderID = orderIDs[_orderAddress];
        return orders[orderID].payInstallment(_customerAddress);
    }

    function payRemainder(
        address _customerAddress,
        address _orderAddress
    ) external {
        uint256 orderID = orderIDs[_orderAddress];
        return orders[orderID].payFull(_customerAddress);
    }

    function getOrdersForUser(
        address _customerAddress
    ) external view returns (address[] memory _orderAddresses) {
        _orderAddresses = new address[](orders.length);
        if (!isCustomer[_customerAddress]) {
            return _orderAddresses;
        }
        uint256 index = 0;
        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].payer() == _customerAddress) {
                _orderAddresses[index] = address(orders[i]);
                index++;
            }
        }
        return _orderAddresses;
    }

    function getOrdersWithPendingPaymentForUsers(
        address _customerAddress
    ) external view returns (address[] memory _orderAddresses) {
        _orderAddresses = new address[](orders.length);
        if (!isCustomer[_customerAddress]) {
            return _orderAddresses;
        }
        uint256 index = 0;
        for (uint256 i = 0; i < orders.length; i++) {
            if (
                orders[i].payer() == _customerAddress &&
                orders[i].getRemainingAmountDue() > 0
            ) {
                _orderAddresses[index] = address(orders[i]);
                index++;
            }
        }
        return _orderAddresses;
    }

    function getAllOrders(
        address _userAddress
    ) external view returns (address[] memory orderAddresses) {
        require(_userAddress == seller, "User is not the product seller!");
        orderAddresses = new address[](orders.length);
        for (uint256 i = 0; i < orders.length; i++) {
            orderAddresses[i] = address(orders[i]);
        }
        return orderAddresses;
    }

    function getOrderData(
        address[] memory _orderAddresses,
        address _userAddress
    )
        external
        view
        returns (
            address[] memory payer,
            uint256[] memory amountPayable,
            uint256[] memory orderAmount,
            uint256[] memory payableLeft
        )
    {
        payer = new address[](_orderAddresses.length);
        amountPayable = new uint256[](_orderAddresses.length);
        orderAmount = new uint256[](_orderAddresses.length);
        payableLeft = new uint256[](_orderAddresses.length);
        uint256 index = 0;
        for (uint256 i = 0; i < _orderAddresses.length; i++) {
            uint256 orderID = orderIDs[_orderAddresses[i]];
            Order order = orders[orderID];
            if (order.payer() == _userAddress) {
                payer[index] = order.payer();
                amountPayable[index] = order.amountPayable();
                orderAmount[index] = order.orderAmount();
                payableLeft[index] = order.getRemainingAmountDue();
                index++;
            }
        }
        return (payer, amountPayable, orderAmount, payableLeft);
    }

    function getPaymentHistory(
        address _orderAddress,
        address _userAddress
    )
        external
        view
        returns (
            uint256[] memory paymentTimestamps,
            uint256[] memory paymentAmount
        )
    {
        uint256 orderID = orderIDs[_orderAddress];
        Order order = orders[orderID];
        require(
            order.payer() == _userAddress || seller == _userAddress,
            "User not authorized to view payment history!"
        );
        return order.getPaymentHistory();
    }
}

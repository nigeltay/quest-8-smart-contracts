// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./product.sol";

contract ProductManager {
    Product[] public products;
    mapping(address => uint256) public productIDs;

    function createProduct(
        string memory _title,
        string memory _description,
        uint256 _price,
        address _sellerWallet
    ) external {
        uint256 productID = products.length;
        Product product = new Product(
            msg.sender,
            _title,
            _description,
            _price,
            _sellerWallet
        );
        products.push(product);
        productIDs[address(product)] = productID;
    }

    function getAllProducts()
        external
        view
        returns (address[] memory productAddresses)
    {
        productAddresses = new address[](products.length);
        for (uint256 i = 0; i < products.length; i++) {
            productAddresses[i] = address(products[i]);
        }
        return productAddresses;
    }

    function getProductsWithUserOrder()
        external
        view
        returns (address[] memory productAddresses)
    {
        productAddresses = new address[](products.length);
        uint index = 0;
        for (uint256 i = 0; i < products.length; i++) {
            if (products[i].isCustomer(msg.sender)) {
                productAddresses[index] = address(products[i]);
                index++;
            }
        }
        return productAddresses;
    }

    function getOrdersForUserWithPendingPayment()
        external
        view
        returns (
            address[] memory productAddresses,
            address[] memory orderAddresses
        )
    {
        productAddresses = new address[](products.length);
        orderAddresses = new address[](products.length);
        uint index = 0;
        for (uint256 i = 0; i < products.length; i++) {
            if (products[i].isCustomer(msg.sender)) {
                address[] memory orders = products[i]
                    .getOrdersWithPendingPaymentForUsers(msg.sender);
                for (uint256 x = 0; x < orders.length; x++) {
                    productAddresses[index] = address(products[i]);
                    orderAddresses[index] = orders[x];
                    index++;
                }
            }
        }
        return (productAddresses, orderAddresses);
    }

    function getOrdersForUser()
        external
        view
        returns (
            address[] memory productAddresses,
            address[] memory orderAddresses
        )
    {
        productAddresses = new address[](products.length);
        orderAddresses = new address[](products.length);
        uint index = 0;
        for (uint256 i = 0; i < products.length; i++) {
            if (products[i].isCustomer(msg.sender)) {
                address[] memory orders = products[i].getOrdersForUser(
                    msg.sender
                );
                for (uint256 x = 0; x < orders.length; x++) {
                    productAddresses[index] = address(products[i]);
                    orderAddresses[index] = orders[x];
                    index++;
                }
            }
        }
        return (productAddresses, orderAddresses);
    }

    function getSellerProducts()
        external
        view
        returns (address[] memory productAddresses)
    {
        productAddresses = new address[](products.length);
        uint index = 0;
        for (uint256 i = 0; i < products.length; i++) {
            if (products[i].seller() == msg.sender) {
                productAddresses[index] = address(products[i]);
                index++;
            }
        }
        return productAddresses;
    }

    function getOrdersFromSellerProduct(
        address _productAddress
    ) external view returns (address[] memory orderAddresses) {
        uint256 productID = productIDs[_productAddress];
        return products[productID].getAllOrders(msg.sender);
    }

    function getOrdersData(
        address _productAddress,
        address[] memory _orderAddresses
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
        uint256 productID = productIDs[_productAddress];
        return products[productID].getOrderData(_orderAddresses, msg.sender);
    }

    function getPaymentHistory(
        address _productAddress,
        address _orderAddress
    ) external view returns (uint256[] memory, uint256[] memory) {
        uint256 productID = productIDs[_productAddress];
        return products[productID].getPaymentHistory(_orderAddress, msg.sender);
    }

    function getProductInfo(
        address[] memory _productAddresses
    )
        external
        view
        returns (
            address[] memory seller,
            string[] memory title,
            string[] memory description,
            uint256[] memory price,
            address[] memory sellerWallet
        )
    {
        seller = new address[](_productAddresses.length);
        title = new string[](_productAddresses.length);
        description = new string[](_productAddresses.length);
        price = new uint256[](_productAddresses.length);
        sellerWallet = new address[](_productAddresses.length);
        for (uint256 i = 0; i < _productAddresses.length; i++) {
            uint256 productID = productIDs[_productAddresses[i]];
            Product product = products[productID];
            seller[i] = product.seller();
            title[i] = product.title();
            description[i] = product.description();
            price[i] = product.price();
            sellerWallet[i] = product.sellerWallet();
        }
        return (seller, title, description, price, sellerWallet);
    }

    function placeOrderForProduct(
        address _productAddress,
        uint256 _orderQuantity,
        bool fullPayment
    ) external {
        uint256 productID = productIDs[_productAddress];
        return
            products[productID].placeOrder(
                msg.sender,
                _orderQuantity,
                fullPayment
            );
    }
}

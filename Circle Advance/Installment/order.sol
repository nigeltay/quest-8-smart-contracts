// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface USDC {
    function balanceOf(address account) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Order {
    address public payer;
    address public paymentAddress;
    uint256 public amountPayable;
    uint256[] public paymentTimestamps;
    uint256[] public paymentAmount;
    address public product;
    uint256 public orderAmount;
    USDC public USDc;
    address usdcAvaxAddress = 0x5425890298aed601595a70AB815c96711a31Bc65;

    constructor(
        address _payer,
        address _paymentAddress,
        uint256 _amountPayable,
        address _productAddress,
        uint256 _orderAmount
    ) {
        payer = _payer;
        paymentAddress = _paymentAddress;
        amountPayable = _amountPayable;
        product = _productAddress;
        orderAmount = _orderAmount;
        USDc = USDC(usdcAvaxAddress);
    }

    function getRemainingAmountDue() public view returns (uint256) {
        uint256 amountPaid = 0;
        for (uint256 i = 0; i < paymentAmount.length; i++) {
            amountPaid = amountPaid + paymentAmount[i];
        }
        return amountPayable - amountPaid;
    }

    function payFull(address _payerAddress) external {
        require(_payerAddress == payer, "Payer address does not match!");
        uint256 amountDue = getRemainingAmountDue();
        require(
            USDc.balanceOf(_payerAddress) > amountDue,
            "Insufficient Balance!"
        );
        require(amountDue != 0, "Order is already paid off!");
        USDc.transferFrom(_payerAddress, address(this), amountDue);
        paymentTimestamps.push(block.timestamp);
        paymentAmount.push(amountDue);
        uint256 newAmountDue = getRemainingAmountDue();
        if (newAmountDue == 0) {
            USDc.transfer(paymentAddress, USDc.balanceOf(address(this)));
        }
    }

    function payInstallment(address _payerAddress) external {
        require(_payerAddress == payer, "Payer address does not match!");
        require(
            paymentAmount.length <= 2,
            "Exceed allowable installment amount!"
        );
        uint256 installmentAmount = amountPayable / 3;
        uint256 amountDue = getRemainingAmountDue();
        require(
            USDc.balanceOf(_payerAddress) > installmentAmount,
            "Insufficient Balance!"
        );
        require(amountDue != 0, "Order is already paid off!");
        USDc.transferFrom(_payerAddress, address(this), installmentAmount);
        paymentTimestamps.push(block.timestamp);
        paymentAmount.push(installmentAmount);
        uint256 newAmountDue = getRemainingAmountDue();
        if (newAmountDue == 0) {
            USDc.transfer(paymentAddress, USDc.balanceOf(address(this)));
        }
    }

    function getPaymentHistory()
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        return (paymentTimestamps, paymentAmount);
    }
}

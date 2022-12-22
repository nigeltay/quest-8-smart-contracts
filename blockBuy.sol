// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

// Abstract
interface USDC {
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract BlockBuy {
    // Variables needed
    /**
    ==================
    Variables
    -----------------
    - start time
    - end time
    - List of buyers address
    - Price
    - Creator
    ==================
    Functions 
    ------------------
    - Constructor (Done)
    - Place order (Done)
    - withdraw Funds (Done)
    - Blockbuy information

    Events
    ---------
    - Place new order
    - withdraw funds
     */

    uint256 public endTime; // Timestamp of the end of the auction (in seconds)
    uint256 public startTime; // The block timestamp which marks the start of the auction
    address payable[] public buyers; // List of buyers addresses
    uint256 public price; // The starting price for the auction
    address public seller; // Seller's address
    string public productName;
    string public productDescription;
    USDC public USDc;

    enum BlockBuyState {
        OPEN,
        ENDED
    }

    // Auction constructor
    constructor(
        address _seller,
        uint256 _endTime,
        uint256 _price,
        string memory _productName,
        string memory _productDescription
    ) {
        USDc = USDC(0x07865c6E87B9F70255377e024ace6630C1Eaa37F); // Smart contract address for the usdc token on testnet
        seller = _seller; // The address of the blockbuy creator
        endTime = block.timestamp + _endTime; // The timestamp which marks the end of the blockbuy (now + 30 days = 30 days from now)
        startTime = block.timestamp; // The timestamp which marks the start of the blockbuy
        price = _price; //The setting of the price of product
        productName = _productName;
        productDescription = _productDescription;
    }

    function placeOrder() external payable returns (bool) {
        /* 
            conditions
            - Money sent in must match the amount
            - Buyer cannot be seller
            - Blockbuy is still open 
            - Sender must not have a current order
        */
        // require(msg.value == price);
        require(msg.sender != seller);
        require(getBlockBuyState() == BlockBuyState.OPEN); // The auction must be open
        require(hasCurrentBid(msg.sender) == false);
        USDc.transferFrom(msg.sender, address(this), price);

        buyers.push(payable(msg.sender));

        emit NewOrder(msg.sender);

        return true;
    }

    function withdrawFunds() external returns (bool) {
        require(getBlockBuyState() == BlockBuyState.ENDED); // The auction must be ended by either a direct buy or timeout
        require(msg.sender == seller); // The auction creator can only withdraw the funds
        USDc.transfer(seller, price * buyers.length); // Transfers funds to the creator
        emit WithdrawFunds(); // Emit a withdraw funds event
        emit GroupBuyClosed();
        return true;
    }

    // Get the auction state
    function getBlockBuyState() public view returns (BlockBuyState) {
        if (block.timestamp >= endTime) return BlockBuyState.ENDED; // The auction is over if the block timestamp is greater than the end timestamp, return ENDED
        return BlockBuyState.OPEN; // Otherwise return OPEN
    }

    function hasCurrentBid(address buyer) public view returns (bool) {
        bool hasBuyer = false;
        for (uint256 i = 0; i < buyers.length; i++) {
            // for each auction
            if (buyers[i] == buyer) {
                hasBuyer = true;
            }
        }
        return hasBuyer;
    }

    function getAllOrders()
        external
        view
        returns (address payable[] memory _buyers)
    {
        return buyers;
    }

    event NewOrder(address newBuyer);
    event WithdrawFunds();
    event GroupBuyClosed();
}

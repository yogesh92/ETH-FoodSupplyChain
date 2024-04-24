pragma solidity ^0.8.0;

import "../ownership/Ownable.sol";
import "../accessControl/FarmerRole.sol";
import "../accessControl/RetailerRole.sol";
import "../accessControl/GrocerRole.sol";
import "../accessControl/CustomerRole.sol";

contract SupplyChain is
    Ownable,
    FarmerRole,
    RetailerRole,
    GrocerRole,
    CustomerRole
{
    
    uint256 productID;

    address owner;

    uint256 stockUnit;

    mapping(uint256 => Item) items;

    mapping(uint256 => Txblocks) itemsHistory;

    enum State {
        ProduceByFarmer, 
        ForSaleByFarmer, 
        PurchasedByRetailer, 
        ShippedByFarmer, 
        ReceivedByRetailer, 
        ProcessedByRetailer, 
        PackageByRetailer, 
        ForSaleByRetailer, 
        PurchasedByGrocer, 
        ShippedByRetailer, 
        ReceivedByGrocer, 
        ForSaleByGrocer, 
        PurchasedByCustomer 
    }

    State constant defaultState = State.ProduceByFarmer;

    struct Item {
        uint256 stockUnit; 
        uint256 productID; 
        address ownerID; 
        address farmerID; 
        string farmName; 
        string farmInformation; 
        string productNotes; 
        uint256 productDate; 
        uint256 productPrice; 
        State itemState; 
        address retailerID; 
        address grocerID; 
        address customerID; 
    }

    struct Txblocks {
        uint256 FTD; 
        uint256 DTR; 
        uint256 RTC; 
    }

    event ProduceByFarmer(uint256 productID); 
    event ForSaleByFarmer(uint256 productID); 
    event PurchasedByRetailer(uint256 productID); 
    event ShippedByFarmer(uint256 productID); 
    event ReceivedByRetailer(uint256 productID); 
    event ProcessedByRetailer(uint256 productID); 
    event PackagedByRetailer(uint256 productID); 
    event ForSaleByRetailer(uint256 productID); 
    event PurchasedByGrocer(uint256 productID); 
    event ShippedByRetailer(uint256 productID); 
    event ReceivedByGrocer(uint256 productID); 
    event ForSaleByGrocer(uint256 productID); 
    event PurchasedByCustomer(uint256 productID); 

    modifier only_Owner() {
        require(_msgSender() == owner);
        _;
    }

    modifier verifyCaller(address _address) {
        require(_msgSender() == _address);
        _;
    }


    modifier checkValue(uint256 _productID, address payable addressToFund) {
        uint256 _price = items[_productID].productPrice;
        uint256 amountToReturn = msg.value - _price;
        addressToFund.transfer(amountToReturn);
        _;
    }

    modifier harvestedByFarmer(uint256 _productID) {
        require(items[_productID].itemState == State.ProduceByFarmer);
        _;
    }

    modifier readyForSaleByFarmer(uint256 _productID) {
        require(items[_productID].itemState == State.ForSaleByFarmer);
        _;
    }

    modifier retailerPurchases(uint256 _productID) {
        require(items[_productID].itemState == State.PurchasedByRetailer);
        _;
    }

    modifier farmerShips(uint256 _productID) {
        require(items[_productID].itemState == State.ShippedByFarmer);
        _;
    }

    modifier retailerRecieves(uint256 _productID) {
        require(items[_productID].itemState == State.ReceivedByRetailer);
        _;
    }

    modifier retailerProcesses(uint256 _productID) {
        require(items[_productID].itemState == State.ProcessedByRetailer);
        _;
    }

    modifier retailerPackages(uint256 _productID) {
        require(items[_productID].itemState == State.PackageByRetailer);
        _;
    }

    modifier retailerReadyForSale(uint256 _productID) {
        require(items[_productID].itemState == State.ForSaleByRetailer);
        _;
    }

    modifier retailerShips(uint256 _productID) {
        require(items[_productID].itemState == State.ShippedByRetailer);
        _;
    }

    modifier grocerPurchases(uint256 _productID) {
        require(items[_productID].itemState == State.PurchasedByGrocer);
        _;
    }

    modifier grocerReceives (uint256 _productID) {
        require(items[_productID].itemState == State.ReceivedByGrocer);
        _;
    }

    modifier readyForSaleByGrocer (uint256 _productID) {
        require(items[_productID].itemState == State.ForSaleByGrocer);
        _;
    }

    modifier customerPurchases (uint256 _productID) {
        require(items[_productID].itemState == State.PurchasedByCustomer);
        _;
    }

    constructor() public payable {
        owner = _msgSender();
        stockUnit = 1;
        productID = 1;
    }

    function kill() public {
        if (_msgSender() == owner) {
            address payable ownerAddressPayable = _make_payable(owner);
            selfdestruct(ownerAddressPayable);
        }
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }

    function produceItemByFarmer(
        uint256 _productID,
        string memory _farmName,
        string memory _farmInformation,
        uint256 _price
    )
        public farmerExists 
    {
        address retailerID; 
        address grocerID; 
        address customerID; 
        Item memory freshProduct; 
        freshProduct.stockUnit = stockUnit; 
        freshProduct.productID = _productID; 
        freshProduct.ownerID = _msgSender(); 
        freshProduct.farmerID = _msgSender(); 
        freshProduct.farmName = _farmName; 
        freshProduct.farmInformation = _farmInformation; 
        freshProduct.productID = _productID + stockUnit; 
        freshProduct.productPrice = _price; 
        freshProduct.productDate = block.timestamp;
        freshProduct.itemState = defaultState; 
        freshProduct.retailerID = retailerID; 
        freshProduct.grocerID = grocerID; 
        freshProduct.customerID = customerID; 
        items[_productID] = freshProduct; 
        uint256 placeholder; 
        Txblocks memory txBlock; 
        txBlock.FTD = placeholder; 
        txBlock.DTR = placeholder;
        txBlock.RTC = placeholder;
        itemsHistory[_productID] = txBlock; 

        stockUnit = stockUnit + 1;

        emit ProduceByFarmer(_productID);
    }


    function farmerSellsItem(uint256 _productID, uint256 _price)
        public
        farmerExists 
        harvestedByFarmer(_productID) 
        verifyCaller(items[_productID].ownerID) 
    {
        items[_productID].itemState = State.ForSaleByFarmer;
        items[_productID].productPrice = _price;
        emit ForSaleByFarmer(_productID);
    }

    function retailerBuysItem(uint256 _productID)
        public
        payable
        retailerExists 
        readyForSaleByFarmer(_productID) 
    {
        address payable ownerAddressPayable = _make_payable(
            items[_productID].farmerID
        ); 
        ownerAddressPayable.transfer(items[_productID].productPrice); 
        items[_productID].ownerID = _msgSender(); 
        items[_productID].retailerID = _msgSender(); 
        items[_productID].itemState = State.PurchasedByRetailer; 
        itemsHistory[_productID].FTD = block.number; 
        emit PurchasedByRetailer(_productID);
    }

 
    function farmerShipsProduct(uint256 _productID)
        public
        payable
        farmerExists 
        retailerPurchases(_productID)
        verifyCaller(items[_productID].farmerID) 
    {
        items[_productID].itemState = State.ShippedByFarmer; 
        emit ShippedByFarmer(_productID);
    }

 
    function retailerReceivesProduct(uint256 _productID)
        public
        retailerExists 
        farmerShips(_productID)
        verifyCaller(items[_productID].ownerID) 
    {
        items[_productID].itemState = State.ReceivedByRetailer; 
        emit ReceivedByRetailer(_productID);
    }


    function retailerPackagesProduct(uint256 _productID)
        public
        retailerExists 
        retailerProcesses(_productID)
        verifyCaller(items[_productID].ownerID) 
    {
        items[_productID].itemState = State.PackageByRetailer;
        emit PackagedByRetailer(_productID);
    }

    function retailerSellsProduct(uint256 _productID, uint256 _price)
        public
        retailerExists 
        retailerPackages(_productID)
        verifyCaller(items[_productID].ownerID) 
    {
        items[_productID].itemState = State.ForSaleByRetailer;
        items[_productID].productPrice = _price;
        emit ForSaleByRetailer(productID);
    }

    function productPurchasedByGrocer(uint256 _productID)
        public
        payable
        grocerExists 
        retailerReadyForSale(_productID)
        checkValue(_productID, payable(_msgSender()))
    {
        address payable ownerAddressPayable = _make_payable(
            items[_productID].retailerID
        );
        ownerAddressPayable.transfer(items[_productID].productPrice);
        items[_productID].ownerID = _msgSender();
        items[_productID].itemState = State.PurchasedByRetailer;
        itemsHistory[_productID].DTR = block.number;
        emit PurchasedByGrocer(_productID);
    } 

    function itemShippedByRetailer(uint256 _productID)
        public
        retailerExists 
        grocerPurchases(_productID)
        verifyCaller(items[_productID].retailerID) 
    {
        items[_productID].itemState = State.ShippedByRetailer;
        emit ShippedByRetailer(_productID);
    }

    function receivedItemByGrocer(uint256 _productID)
        public
        grocerExists 
        retailerShips(_productID)
        verifyCaller(items[_productID].ownerID) 
    {
        items[_productID].itemState = State.ReceivedByRetailer;
        emit ReceivedByGrocer(_productID);
    }

    function sellItemByGrocer(uint256 _productID, uint256 _price)
        public
        grocerExists
        grocerReceives(_productID)
        verifyCaller(items[_productID].ownerID) 
    {
        items[_productID].itemState = State.ForSaleByRetailer;
        items[_productID].productPrice = _price;
        emit ForSaleByGrocer(_productID);
    }

    function customerBuysItem(uint256 _productID)
        public
        payable
        customerExists 
        readyForSaleByGrocer(_productID)
        checkValue(_productID, payable(_msgSender()))
    {
        items[_productID].customerID = _msgSender();
        address payable ownerAddressPayable = _make_payable(
            items[_productID].retailerID
        );
        ownerAddressPayable.transfer(items[_productID].productPrice);
        items[_productID].ownerID = _msgSender();
        items[_productID].customerID = _msgSender();
        items[_productID].itemState = State.PurchasedByCustomer;
        itemsHistory[_productID].RTC = block.number;
        emit PurchasedByCustomer(_productID);
    }

    function fetchItemBuffer1(uint256 _productID)
        public
        view
        returns (
            uint256 itemstockUnit,
            uint256 itemproductID,
            address ownerID,
            address farmerID,
            string memory farmName,
            string memory farmInformation,
            uint256 productDate
        )
    {
        Item memory item = items[_productID];

        return (
            item.stockUnit,
            item.productID,
            item.ownerID,
            item.farmerID,
            item.farmName,
            item.farmInformation,
            item.productDate
        );
    }

    function fetchItemBuffer2(uint256 _productID)
        public
        view
        returns (
            uint256 itemstockUnit,
            uint256 itemproductID,
            uint256 productID,
            string memory productNotes,
            uint256 productPrice,
            uint256 productDate,
            State itemState,
            address RetailerID,
            address retailerID,
            address consumerID
        )
    {
        Item memory item = items[_productID];

        return (
            item.stockUnit,
            item.productID,
            item.productID,
            item.productNotes,
            item.productPrice,
            item.productDate,
            item.itemState,
            item.grocerID,
            item.retailerID,
            item.customerID
        );
    }

    function fetchitemHistory(uint256 _productID)
        public
        view
        returns (
            uint256 blockfarmerToRetailer,
            uint256 blockRetailerToRetailer,
            uint256 blockRetailerToConsumer
        )
    {
        Txblocks memory txblock = itemsHistory[_productID];
        return (txblock.FTD, txblock.DTR, txblock.RTC);
    }
}

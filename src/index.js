import React, { useState, useEffect } from "react";
import MyContract from "../../build/contracts/ETH-FoodSupplyChain.json";
import Web3 from "web3";



function App() {
  const [web3, setWeb3] = useState(undefined);
  const [account, setAccount] = useState("");
  const [contract, setContract] = useState(undefined);

  useEffect(() => {
    const init = async () => {
      try {
        await loadWeb3();
        await loadData();
      } catch (error) {
        console.error("Error initializing the app:", error);
      }
    };
    init();
  }, []);

  const loadWeb3 = async () => {
    if (window.ethereum) {
      try {
        const web3Instance = new Web3(window.ethereum);
        setWeb3(web3Instance);
      } catch (error) {
        console.error("Error loading Web3:", error);
      }
    } else {
      console.error("MetaMask not found");
    }
  };

  const loadData = async () => {
    try {
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      setAccount(accounts[0]);

      const networkId = await web3.eth.net.getId();
      const deployedNetwork = MyContract.networks[networkId];
      const contractInstance = new web3.eth.Contract(
        MyContract.abi,
        deployedNetwork && deployedNetwork.address
      );
      setContract(contractInstance);
    } catch (error) {
      console.error("Error loading blockchain data:", error);
    }
  };

  async function addNewRole(role, address) {
    try {
      const hasRole = await contract[`is${role}`](address);
      if (!hasRole) {
        await contract[`add${role}`](address);
      }
    } catch (error) {
      console.error(`Error adding ${role} role for ${address}: ${error}`);
      throw error;
    }
  }

  const harvestProduct = async (
    productCode,
    farmName,
    farmInformation,
    productNotes,
    productPrice
  ) => {
    try {
      const item = await contract.produceItemByFarmer(
        productCode,
        farmName,
        farmInformation,
        farmLatitude,
        farmLongitude,
        productNotes,
        productPrice
      );
      return item;
    } catch (error) {
      console.error(
        `Failed to harvest produce with given code ${productCode}:`,
        error
      );
      throw error;
    }
  };
  async function sellTheItem(productCode, price, role) {
    try {
      const sell = await contract[`sellItemBy${role}`](productCode, price);
      return sell;
    } catch (error) {
      console.error(
        `Not able to sell item with productCode ${productCode} and price ${price} as ${role}:`,
        error
      );
      throw error;
    }
  }

  async function buyItem(productCode, role) {
    try {
      await contract[`purchaseItemBy${role}`](productCode);
    } catch (error) {
      console.error(
        `not able to buy item with productCode ${productCode} as ${role}:`,
        error
      );
      throw error;
    }
  }

  async function sendItem(productCode, role) {
    try {
      await contract[`shippedItemBy${role}`](productCode);
    } catch (error) {
      console.error(
        `not able to send with productCode ${productCode} as ${role}:`,
        error
      );
      throw error;
    }
  }

  async function packageItemByRetailer(productCode) {
    try {
      await contract.packageItemByRetailer(productCode);
    } catch (error) {
      console.error(
        `Failed to package item with productCode ${productCode}:`,
        error
      );
      throw error;
    }
  }

  const fetchItemBuffer1 = async (productCode) => {
    try {
      const item = await contract.fetchItemBuffer1.call(productCode);
      return item;
    } catch (error) {
      console.error(
        `Error fetching item buffer one for product code ${productCode}:`,
        error
      );
      throw error;
    }
  };

  const getItemBuffer2= async (productCode) => {
    try {
      const item = await contract.fetchItemBuffer1.call(productCode);
      return item;
    } catch (error) {
      console.error(
        `Error fetching item buffer two for product code ${productCode}:`,
        error
      );
      throw error;
    }
  };

  const getItemHistory = async (productCode) => {
    try {
      const history = await contract.fetchItemHistory.call(productCode);
      return history;
    } catch (error) {
      console.error(
        `Error fetching item history for product code ${productCode}:`,
        error
      );
      throw error;
    }
  };

  return (
    <div>
      <h1>Food Supply Chain</h1>
      <div class="container">
        <div class="box">
          <p>
            Product is harvested and purchased by retailer
          </p>
        </div>
        <div class="arrow"></div>
        <div class="box">
          <p>Product is shipped by farmer</p>
        </div>
        <div class="arrow"></div>
        <div class="box">
          <p>
            Retailer gets it and gets it ready
          </p>
        </div>
        <div class="arrow"></div>
        <div class="box">
          <p>Grocer purchases the product from Retailer</p>
        </div>
        <div class="arrow"></div>
        <div class="arrow"></div>
        <div class="box">
          <p>Grocer get the goods and puts it in their marketplace</p>
        </div>
        <div class="arrow"></div>
        <div class="box">
          <p>Customer then buys the product</p>
        </div>
      </div>
    </div>
  );
}
export default App;

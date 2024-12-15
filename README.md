
---

# **MultiChainNFT Smart Contract**

### **Overview**
The **MultiChainNFT** smart contract is an advanced NFT platform that supports:
- **Minting NFTs** with unique metadata.
- **Multi-chain compatibility**, allowing NFTs to be bridged across multiple blockchains.
- **Token swapping** functionality using decentralized exchanges (DEXs).
- **Bridging** functionality for seamless NFT transfer between supported blockchains.
- **Support for Ethereum, Binance Smart Chain (BSC), Avalanche, Polygon, Arbitrum, and Optimism.**

---

### **Key Features**
1. **NFT Minting:**
   - Mint unique NFTs with metadata stored via `tokenURI` (e.g., IPFS links).
   - Enforce a `maxSupply` to limit the number of NFTs minted.
   
2. **Multi-Chain Support:**
   - Bridge NFTs across blockchains.
   - Supported blockchains: Ethereum, BNB Chain, Avalanche, Polygon, Arbitrum, and Optimism.

3. **Token Swapping:**
   - Swap tokens via integrated DEX Router.
   - Supports any ERC-20 token pairs.

4. **Bridging NFTs:**
   - Burn the NFT on the source chain and remint on the destination chain using an external bridge protocol.

5. **Funds Management:**
   - Receive and withdraw funds for minting fees or bridging costs.
   - Automatic transfer to the owner's wallet.

6. **Pause and Unpause Contract:**
   - Emergency control to halt or resume contract functionality.

---

### **Technologies Used**
- **Solidity:** Programming language for writing the smart contract.
- **OpenZeppelin:** Industry-standard library for ERC721, access control, and security.
- **DEX Integration:** Supports token swaps via DEX Router (e.g., Uniswap, PancakeSwap).
- **Bridge Integration:** Uses external bridging protocols to send messages across chains.

---

### **Setup and Deployment**
1. **Prerequisites:**
   - Install [Node.js](https://nodejs.org/) and [Hardhat](https://hardhat.org/).
   - Install a wallet (e.g., MetaMask) configured for Ethereum and other supported blockchains.

2. **Install Dependencies:**
   ```bash
   npm install @openzeppelin/contracts
   ```

3. **Deployment Steps:**
   - Configure `ownerWallet`, `dexRouter`, and `bridgeContract` in the constructor.
   - Deploy the contract on your desired blockchain:
     ```bash
     npx hardhat run scripts/deploy.js --network <network_name>
     ```
   - Update `dexRouter` and `bridgeContract` if needed using admin functions.

4. **Supported Networks:**
   - Ethereum (Mainnet/Testnets)
   - Binance Smart Chain (BSC)
   - Polygon
   - Avalanche
   - Arbitrum
   - Optimism

---

### **How to Use**
1. **Mint NFTs:**
   - Call the `mintNFT` function with a `tokenURI` (e.g., IPFS link).
   - Example:
     ```javascript
     contract.mintNFT("ipfs://your-token-metadata-uri");
     ```

2. **Swap Tokens:**
   - Use the `swapTokens` function to exchange tokens via DEX.
   - Example parameters:
     ```javascript
     contract.swapTokens(
       tokenInAddress,
       tokenOutAddress,
       amountIn,
       amountOutMin,
       recipient,
       deadline
     );
     ```

3. **Bridge NFTs:**
   - Burn your NFT on the source chain using `bridgeNFT` and remint it on the destination chain.
   - Example:
     ```javascript
     contract.bridgeNFT(tokenId, destChainId, recipientAddress, { value: bridgeFee });
     ```

4. **Withdraw Funds:**
   - Owner can call `withdrawFunds` to transfer all contract balance to the `ownerWallet`.

5. **Pause/Unpause Contract:**
   - Pause: `contract.pause()`
   - Unpause: `contract.unpause()`

---

### **Contract Structure**
1. **Key Functions:**
   - `mintNFT`: Mint new NFTs with a unique `tokenURI`.
   - `swapTokens`: Swap tokens using the DEX router.
   - `bridgeNFT`: Burn NFT on source chain and send bridging data to the destination chain.
   - `withdrawFunds`: Withdraw ETH from the contract.
   - `pause` and `unpause`: Emergency controls for pausing contract operations.

2. **Key Variables:**
   - `maxSupply`: Maximum number of NFTs that can be minted.
   - `ownerWallet`: The wallet to receive funds.
   - `dexRouter`: Address of the DEX router for swaps.
   - `bridgeContract`: Address of the external bridge protocol.

---

### **Supported Chains**
| Chain ID | Name           |
|----------|----------------|
| 1        | Ethereum       |
| 56       | Binance Smart Chain (BSC) |
| 137      | Polygon        |
| 43114    | Avalanche      |
| 42161    | Arbitrum       |
| 10       | Optimism       |

---

### **Admin Functions**
- `updateDEXRouter(address newRouter)`: Change the DEX Router address.
- `updateBridgeContract(address newBridge)`: Change the bridging protocol address.
- `pause() / unpause()`: Pause or unpause contract operations.

---

### **Security Features**
- Uses OpenZeppelin libraries for:
  - Access control (`Ownable`).
  - Secure token transfers (`SafeMath`).
  - ERC721 standards (`ERC721URIStorage`).
- Pausable functionality for emergency cases.

---

### **Future Enhancements**
- Integrate additional chain support (e.g., Solana, Fantom).
- Add governance mechanisms for owner-independent upgrades.
- Implement advanced NFT metadata utilities (e.g., royalties, fractional ownership).

---

### **License**
This project is licensed under the **MIT License**.

---


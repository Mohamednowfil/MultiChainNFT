// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDEXRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IBridge {
    function sendMessage(bytes calldata message, uint256 destChainId) external payable;
}

contract MultiChainNFT is ERC721URIStorage, Ownable, Pausable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIdCounter;

    uint256 public maxSupply;
    address public ownerWallet;
    address public dexRouter; // DEX Router for swaps
    address public bridgeContract; // Bridging protocol contract
    mapping(uint256 => string) public chainNames; // ChainID to Chain Name

    event NFTMinted(address indexed minter, uint256 tokenId, string tokenURI);
    event SwapExecuted(address indexed user, uint256 amountIn, uint256 amountOut);
    event NFTBridged(uint256 tokenId, uint256 destChainId, address recipient);
    event FundsTransferred(address indexed recipient, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        address _ownerWallet,
        address _dexRouter,
        address _bridgeContract
    ) ERC721(name, symbol) {
        maxSupply = _maxSupply;
        ownerWallet = _ownerWallet;
        dexRouter = _dexRouter;
        bridgeContract = _bridgeContract;

        // Initialize chain names
        chainNames[1] = "Ethereum";
        chainNames[56] = "BNB Chain";
        chainNames[137] = "Polygon";
        chainNames[43114] = "Avalanche";
        chainNames[42161] = "Arbitrum";
        chainNames[10] = "Optimism";
    }

    // Update DEX Router
    function updateDEXRouter(address newRouter) external onlyOwner {
        require(newRouter != address(0), "Invalid router address");
        dexRouter = newRouter;
    }

    // Update Bridge Contract
    function updateBridgeContract(address newBridge) external onlyOwner {
        require(newBridge != address(0), "Invalid bridge address");
        bridgeContract = newBridge;
    }

    // Mint NFT
    function mintNFT(string memory tokenURI) external whenNotPaused {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId < maxSupply, "Max supply reached");

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _tokenIdCounter.increment();

        emit NFTMinted(msg.sender, tokenId, tokenURI);
    }

    // Swap Tokens using DEX
    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) external whenNotPaused {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(dexRouter, amountIn);

        address;
        path[0] = tokenIn;
        path[1] = tokenOut;

        IDEXRouter(dexRouter).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );

        emit SwapExecuted(msg.sender, amountIn, amountOutMin);
    }

    // Bridge NFT to another chain
    function bridgeNFT(uint256 tokenId, uint256 destChainId, address recipient) external whenNotPaused {
        require(ownerOf(tokenId) == msg.sender, "Not the token owner");
        require(bytes(chainNames[destChainId]).length > 0, "Unsupported destination chain");

        // Burn the NFT on the source chain
        _burn(tokenId);

        // Bridge the token via external bridge protocol
        bytes memory message = abi.encode(tokenId, recipient);
        IBridge(bridgeContract).sendMessage{value: msg.value}(message, destChainId);

        emit NFTBridged(tokenId, destChainId, recipient);
    }

    // Receive funds from swaps or bridge fees
    receive() external payable {
        emit FundsTransferred(ownerWallet, msg.value);
    }

    // Withdraw funds to the owner wallet
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(ownerWallet).transfer(balance);
        emit FundsTransferred(ownerWallet, balance);
    }

    // Pause contract
    function pause() external onlyOwner {
        _pause();
    }

    // Unpause contract
    function unpause() external onlyOwner {
        _unpause();
    }
}

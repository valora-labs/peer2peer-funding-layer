export const ValoraSwapV3ABI = [
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "initialOwner",
                "type": "address"
            },
            {
                "internalType": "address payable",
                "name": "feeWallet",
                "type": "address"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "fee",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "address",
                "name": "referrer",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "address",
                "name": "referee",
                "type": "address"
            }
        ],
        "name": "SwapFromReferral",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "FEE_WALLET",
        "outputs": [
            {
                "internalType": "address payable",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "SWAP_HANDLER",
        "outputs": [
            {
                "internalType": "contract SwapHandler",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "pause",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "unpause",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "string",
                "name": "fromNetworkId",
                "type": "string"
            },
            {
                "internalType": "contract IERC20",
                "name": "fromToken",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "fromAmount",
                "type": "uint256"
            },
            {
                "internalType": "string",
                "name": "toNetworkId",
                "type": "string"
            },
            {
                "internalType": "contract IERC20",
                "name": "toToken",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "target",
                "type": "address"
            },
            {
                "internalType": "bytes",
                "name": "data",
                "type": "bytes"
            },
            {
                "internalType": "uint256",
                "name": "fee",
                "type": "uint256"
            },
            {
                "internalType": "address",
                "name": "referrer",
                "type": "address"
            }
        ],
        "name": "swap",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
    }
];
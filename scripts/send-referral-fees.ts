import { createPublicClient, createWebSocketTransport, parseAbiItem } from 'viem';
import { celo } from 'viem/chains';
import { ValoraSwapV3ABI } from '../abis/ValoraSwapV3';

// Replace with your contract address and ABI

// Replace with your WebSocket provider URL
const transport = createWebSocketTransport('wss://forno.celo.org/ws');

const client = createPublicClient({
    chain: celo,
    transport,
});

client.onLogs({
    address: contractAddress,
    event: ValoraSwapV3ABI[1],
}, (log) => {
    const { referrer, referee, amount } = log.args;
    console.log(`SwapFromReferral event detected:`);
    console.log(`Referrer: ${referrer}`);
    console.log(`Referee: ${referee}`);
    console.log(`Amount: ${amount.toString()}`);
    console.log(`Log: ${JSON.stringify(log)}`);
});

console.log('Listening for SwapFromReferral events...');
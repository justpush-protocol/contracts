import JustPushV1 from '../build/contracts/JustPushV1.json';
import { networkId, network } from './constants';
import { getTronWeb } from './utils';
require('dotenv').config();
const main = async () => {
    const tronweb = getTronWeb(network);
    const abi = JustPushV1.abi;
    const address = JustPushV1.networks[networkId].address;
    const contract = await tronweb.contract(abi, address);

    const groupId = 'cb5edeb6-a8a1-466a-aa6c-0d01d88fa68e';
    const receiver = 'TBtNuDxgnwpVQKxAdmXeCdBm6LRiyCUYu1'
    const title = 'You are about to liquidate';
    const content = 'You just swapped some stuff';

    await contract.sendNotification(groupId, receiver, title, content).send();
    console.log('Notification sent');
};

main().catch(console.error).then(() => console.log("Done!"));
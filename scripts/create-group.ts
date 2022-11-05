import JustPushV1 from '../build/contracts/JustPushV1.json';
import { networkId, network } from './constants';
import {v4 as uuidv4} from 'uuid';
import { getTronWeb } from './utils';
require('dotenv').config();
const main = async () => {
    const tronweb = getTronWeb(network);
    const abi = JustPushV1.abi;
    const address = JustPushV1.networks[networkId].address;
    const contract = await tronweb.contract(abi, address);
    const groupId = uuidv4();
    const owner = tronweb.defaultAddress.base58;
    const data = JSON.stringify({
        name: 'JustPush 2',
        description: 'JustPush 2',
    });
    await contract.createGroup(groupId, owner, data).send();
    console.log('Group created');

    const group = await contract.getGroup(groupId).call();
    console.log(group);

};

main().catch(console.error).then(() => console.log("Done!"));
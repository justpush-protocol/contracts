import JustPushV1 from '../build/contracts/JustPushV1.json';
import { networkId, network } from './constants';
import { getTronWeb } from './utils';
require('dotenv').config();
const main = async () => {
    const tronweb = getTronWeb(network);
    const abi = JustPushV1.abi;
    // const address = JustPushV1.networks[networkId].address;
    // const contract = await tronweb.contract(abi, address);
    // const res = await contract.initalize(2).send();
    // const item = await contract.item().send();
    // console.log(item.toNumber());
};

main().catch(console.error).then(() => console.log("Done!"));
const TronWeb = require('tronweb');
export const getTronWeb = (network: string) => {
    const host = network === 'tron' ? 'https://api.trongrid.io' : `https://api.${network}.trongrid.io`;

    const privateKey = process.env.PRIVATE_KEY;
    if (!privateKey || privateKey === '') {
        throw new Error('PRIVATE_KEY is not defined');
    }
    const tronProApiKey = process.env.TRON_PRO_API;
    const tronWeb = new TronWeb({
        fullHost: host,
        // headers: tronProApiKey ? { "TRON-PRO-API-KEY": tronProApiKey } : {},
        privateKey,
    });
    return tronWeb;
};

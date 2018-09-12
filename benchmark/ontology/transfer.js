'use strict';

module.exports.info = 'transfer';
const Util = require('../../src/comm/util.js');
const log = Util.log;
const readline = require('readline');
const fs = require('fs');

let txNum, txIndex;
let bc;
let txHash = [], txData = [];
let sendTx = true; // false means that client monitor only
let cxt;

// read tx from file, or use sdk to generate tx
module.exports.init = async function (blockchain, context, args) {
    if (!args.hasOwnProperty('sendTx')) {
        return Promise.reject(new Error('sendTx init - "sendTx" is missed in the arguments'));
    }
    sendTx = args.sendTx;
    bc = blockchain;
    cxt = context;
    txIndex = -1;
    if (sendTx) {
        await bc.bcObj.initAsset();
        txNum = args.txNum;
        let fielName = './transfer' + args.clientIndex + '.txt';
        log('start read %d transfer tx from %s', txNum, fielName);
        const read = readline.createInterface({
            input: fs.createReadStream(fielName)
        });
        read.on('line', (line) => {
            let lineContent = line.split(',');
            txHash.push(lineContent[0]);
            txData.push(lineContent[1]);
        });
        while (txData.length < txNum / 2) {
            await Util.sleep(1000).then(() => {
            });
        }
        // read.close();
        log('read transfer tx %d down', txData.length);
    }
    return Promise.resolve(sendTx);
};


// should sendTx one time in one invoke
module.exports.run = function () {
    txIndex++;
    if (txIndex === 10000) {
        txHash = txHash.slice(txIndex);
        txData = txData.slice(txIndex);
        txIndex = 0;
    }
    return bc.sendTx(cxt, txHash[txIndex], txData[txIndex]);
};

module.exports.end = function () {
    txHash = [];
    txData = [];
    return Promise.resolve();
};

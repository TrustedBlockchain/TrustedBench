'use strict';

module.exports.info = 'invoke contract';
const Util = require('../../src/comm/util.js');
const log = Util.log;
const fs = require('fs');
const readline = require('readline');

let txNum, txIndex;
let bc;
let txHash = [], txData = [];
let invokeContract = true; // false means that client monitor only
let cxt;

// read tx from file, or use sdk to generate tx
module.exports.init = async function (blockchain, context, args) {
    if (!args.hasOwnProperty('invokeContract')) {
        return Promise.reject(new Error('sendTx init - "invokeContract" is missed in the arguments'));
    }
    invokeContract = args.invokeContract;
    bc = blockchain;
    cxt = context;
    txIndex = -1;
    if (invokeContract) {
        txNum = args.txNum;
        let fielName = './invoke' + args.clientIndex + '.txt';
        log('start read invoke %d tx from %s', txNum, fielName);
        const read = readline.createInterface({
            input: fs.createReadStream(fielName)
        });
        read.on('line', (line) => {
            let lineContent = line.split(',');
            txHash.push(lineContent[0]);
            txData.push(lineContent[1]);
        });
        while (txData.length < txNum) {
            await Util.sleep(1000).then(() => {
            });
        }
        read.close();
        log('read invoke tx %d down', txData.length);
    }
    return Promise.resolve(invokeContract);
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

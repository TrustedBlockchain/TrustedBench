'use strict';

let fs = require('fs');
let path = require('path');
let sign = require('./sign');

let addresses;
let bc;
let contx;
let amount;
module.exports.init = function (blockchain, context, args) {
    if (!args.hasOwnProperty('path')) {
        return Promise.reject(new Error('zig.transfer - "path" is missed in the arguments'));
    }

    if (!args.hasOwnProperty('amount')) {
        return Promise.reject(new Error('zig.transfer - "amount" is missed in the arguments'));
    }

    let file_path = args.path.toString();
    amount = args.amount.toString();
    addresses = JSON.parse(fs.readFileSync(path.join(__dirname, file_path), 'utf-8')).sign;
    bc = blockchain;
    contx = context;
    return Promise.resolve();
};

module.exports.run = function () {
    let sender = addresses[Math.floor(Math.random() * addresses.length)];
    let receiver = addresses[Math.floor(Math.random() * addresses.length)];
    let txIdObject = contx.client.newTransactionID();
    const ccId = 'token';
    const fcn = 'transfer';
    const feeLimit = '100000000000';
    const msg = 'test';
    const type = 'ZIG';
    let senderSpec = {
        sender: Buffer.from(sender.address),
        fee_limit: Buffer.from(feeLimit),
        msg: Buffer.from(msg),
        tx_id: Buffer.from(txIdObject.getTransactionID())
    };
    let signature = sign.signTX([receiver.address, type, amount], sender.private_key, senderSpec, fcn, ccId);
    return bc.invokeSmartContract(contx, ccId, '1.0', {
        verb: fcn,
        to: receiver.address,
        type: type,
        amount: amount
    }, 30, {signature: signature, txIdObject: txIdObject, senderSpec: senderSpec});
};

module.exports.end = function (results) {
    return Promise.resolve();
};


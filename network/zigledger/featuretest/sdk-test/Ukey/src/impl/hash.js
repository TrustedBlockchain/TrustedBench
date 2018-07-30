/*
Copyright Ziggurat Corp. 2018 All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

/**
 * Created by zhangtailin on 2018/7/10.
 */

var ethUtils = require('ethereumjs-util');
var config = require('../config.json');

let chaincode = require('../chaincode.json');
let protobufRoot = require('protobufjs').Root;
let root = protobufRoot.fromJSON(chaincode);
var SignContent = root.lookupType('SignContent');
var ChaincodeSpec = root.lookupType('ChaincodeSpec');

function sha256(ccId, fcn, arg, msg, feeLimit, senderAddress, txId) {
    var args = [];
    var senderSpec = {
        sender: Buffer.from(senderAddress),
        feeLimit: Buffer.from(feeLimit),
        txId: Buffer.from(txId)
    };
    if (msg && msg != "") {
        senderSpec.msg = Buffer.from(msg)
    }

    args.push(Buffer.from(fcn ? fcn : 'invoke', 'utf8'));
    for (var i = 0; i < arg.length; i++) {
        args.push(Buffer.from(arg[i], 'utf8'));
    }

    var invokeSpec = {
        type: ChaincodeSpec.Type.GOLANG,
        chaincodeId: {
            name: ccId
        },
        input: {
            args: args
        }
    };
    var signContent = {
        chaincodeSpec: invokeSpec,
        senderSpec: senderSpec
    };

    var encodeMessage = SignContent.encode(SignContent.create(signContent)).finish();
    var signHash = ethUtils.sha256(Buffer.from(encodeMessage));
    return signHash.toString('hex');
}

function sha256_data(fcn, args, key, address) {
    return queryCounter(address).then((results) => {
        let counter = results.data;
        return Promise.resolve(sha256(config.chaincodeId, fcn, args, "", counter, config.feeLimit, address));
    }).catch(err => {
        return Promise.reject(err);
    });
}

function queryCounter(address) {
    let data = {
        from_address: address,
    };
    return fetch(config.server_address + "/query-counter", {
        method: "POST",
        headers: {
            "Content-Type": 'application/json'
        },
        body: JSON.stringify(data)
    }).then((result) => {
        return result.json();
    }).catch(err => {
        return Promise.reject(err);
    });
}

module.exports.sha256 = sha256;
module.exports.queryCounter = queryCounter;
module.exports.sha256_data = sha256_data;

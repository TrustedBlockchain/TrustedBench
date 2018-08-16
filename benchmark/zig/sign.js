/* eslint-disable require-jsdoc */
'use strict';

let grpc = require('grpc');
require('es6-promise').polyfill();
require('isomorphic-fetch');
let path = require('path');
let _ccProto = grpc.load(path.join(__dirname, './protos/peer/chaincode.proto')).protos;
let ethUtils = require('ethereumjs-util');

function signTX(arg, priKey, senderSpec,fcn,ccId) {
    let args = [];
    args.push(Buffer.from(fcn, 'utf8'));
    for (let i = 0; i < arg.length; i++) {
        args.push(Buffer.from(arg[i], 'utf8'));
    }
    let invokeSpec = {
        type: _ccProto.ChaincodeSpec.Type.GOLANG,
        chaincode_id: {
            name: ccId
        },
        input: {
            args: args
        }
    };
    let cciSpec = new _ccProto.ChaincodeInvocationSpec();
    let signContent = new _ccProto.SignContent();
    signContent.setChaincodeSpec(invokeSpec);
    signContent.setSenderSpec(senderSpec);
    signContent.id_generation_alg = cciSpec.id_generation_alg;
    let signHash = ethUtils.sha256(signContent.toBuffer());
    let sigrsv = ethUtils.ecsign(signHash, Buffer.from(priKey, 'hex'));

    return Buffer.concat([
        ethUtils.setLengthLeft(sigrsv.r, 32),
        ethUtils.setLengthLeft(sigrsv.s, 32),
        ethUtils.toBuffer(sigrsv.v - 27)
    ]);
}

module.exports.signTX = signTX;




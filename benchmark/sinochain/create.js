'use strict';

module.exports.info = 'create account';

let bc, ctx;

let seqnum;

module.exports.init = function(blockchain, context, args) {

    bc = blockchain;
    ctx = context;
    let startIndex = args.txNum * args.clientIndex;
    // let endIndex = args.txNum * (args.clientIndex + 1);
    seqnum = startIndex;

    return Promise.resolve();
};

module.exports.run = function() {
    return bc.bcObj.sinoSendToCloud(ctx, {
        Seqnum: (++seqnum),
        Payload: new Buffer('{"name": "mycc", "args": ["create", "' + seqnum + '", "10"]}')
    });
};

module.exports.end = function() {
    return Promise.resolve();
};
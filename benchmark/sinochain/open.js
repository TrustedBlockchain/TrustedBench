'use strict';

module.exports.info = 'open account';

let bc, ctx;

let seqnum;

module.exports.init = function(blockchain, context, args) {

    bc = blockchain;
    ctx = context;
    ctx.txNum = args.txNum;
    let startIndex = args.txNum * args.clientIndex;
    // let endIndex = args.txNum * (args.clientIndex + 1);
    seqnum = startIndex;

    return Promise.resolve();
};

/* module.exports.run = function() {
    return bc.bcObj.sinoSendToCloud(ctx, {
        Seqnum: (++seqnum),
        Payload: new Buffer('{"name": "simple", "args": ["open", "' + seqnum + '", "10"]}')
    });
}; */

const dic = 'abcdefghijklmnopqrstuvwxyz';
/**
 * Generate string by picking characters from dic variable
 * @param {*} number character to select
 * @returns {String} string generated based on @param number
 */
function get26Num(number){
    let result = '';
    while(number > 0) {
        result += dic.charAt(number % 26);
        number = parseInt(number/26);
    }
    return result;
}

let prefix;
/**
 * Generate unique account key for the transaction
 * @returns {String} account key
 */
function generateAccount() {
    // should be [a-z]{1,9}
    if(typeof prefix === 'undefined') {
        prefix = get26Num(process.pid);
    }
    return prefix + get26Num(seqnum + 1);
}

module.exports.run = function() {
    return bc.bcObj.sinoSendToCloud(ctx, {
        Seqnum: (++seqnum),
        Payload: new Buffer('{"name": "simple", "args": ["open", "' + generateAccount() + '", "10"]}')
    });
};

module.exports.end = function() {
    return Promise.resolve();
};
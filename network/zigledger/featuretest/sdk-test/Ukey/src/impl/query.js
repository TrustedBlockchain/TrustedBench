/*
Copyright Ziggurat Corp. 2018 All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

/**
 * Created by zhangtailin on 2018/6/15.
 */

var config = require('../config.json');

function invoke(sender, ccId, fcn, args, msg, feeLimit, sig) {
    let data = {
        cc_id: ccId,
        fcn: fcn,
        sender: sender,
        args: args,
        message: msg,
        fee_limit: feeLimit,
        sig: sig
    };
    return fetch(config.server_address + "/invoke", {
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

function query(ccId, fcn, args) {
    let data = {
        cc_id: ccId,
        fcn: fcn,
        args: args
    };
    return fetch(config.server_address + "/query", {
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

module.exports.invoke = invoke;
module.exports.query = query;

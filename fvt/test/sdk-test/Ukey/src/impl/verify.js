/*
Copyright Ziggurat Corp. 2018 All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

/**
 * Created by zhangtailin on 2018/6/25.
 */

var config = require('../config.json');
// var hardware_address = 'https://localhost.xiaoqiao.cat:21727';

function listKeys() {
    return fetch(config.hardware_address + '/list-keys', {
        method: "GET",
        headers: {
            "Content-Type": 'application/json'
        }
    }).then((result) => {
        return result.json();
    }).catch(err => {
        return Promise.reject(err);
    });
}

function verifyPIN(key, pin) {
    if (!pin || pin.length < 4 || pin.length > 10) {
        return Promise.reject('invalid pin');
    }

    let pin_length = dataLengthCalc(pin);
    let new_pin = stringFill(pin, pin_length * 2, 'F');
    let data = {
        "apdu": 'DF2000000' + pin_length.toString(16) + new_pin,
        "reader": key
    };

    return fetch(config.hardware_address + "/apdu", {
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

function changePIN(key, oldpin, newpin) {
    if (!oldpin || !newpin || oldpin.length < 4 || newpin.length < 4
        || oldpin.length > 10 || newpin.length > 10) {
        return Promise.reject('invalid pin');
    }

    let pin_length = dataLengthCalc(oldpin);
    let new_pin_length = dataLengthCalc(newpin);

    let last_len = pin_length > new_pin_length ? pin_length * 2 : new_pin_length * 2;
    oldpin = stringFill(oldpin, last_len, 'F');
    newpin = stringFill(newpin, last_len, 'F');

    let data = {
        "apdu": 'DF2100000' + last_len.toString(16) + oldpin + newpin,
        "reader": key
    };

    return fetch(config.hardware_address + "/apdu", {
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

function getPublicKeyAndAddress(key) {
    let data = {
        "apdu": 'DF020000',
        "reader": key
    };

    return fetch(config.hardware_address + "/apdu", {
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

function signTx(key, dataHash) {
    let apdu = 'DF08010020' + dataHash;
    let data = {
        "apdu": apdu.toUpperCase(),
        "reader": key
    };

    return fetch(config.hardware_address + "/apdu", {
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

function _fetch(fetch, timeout) {
    return Promise.race([
        fetch,
        new Promise(function (resolve, reject) {
            setTimeout(() => reject(new Error('request timeout')), timeout);
        })
    ]);
}

function stringFill(fstr, flen, fchar) {
    let index = flen - fstr.length;
    for (let i = 0; i < index; i++) {
        fstr += fchar;
    }
    return fstr;
}

function dataLengthCalc(data) {
    let data_mod = data.length % 2;
    let data_len = data.length / 2;
    return (data_mod === 1) ? parseInt(data_len) + 1 : data_len;
}

module.exports.listKeys = listKeys;
module.exports.verifyPIN = verifyPIN;
module.exports.changePIN = changePIN;
module.exports.getPublicKeyAndAddress = getPublicKeyAndAddress;
module.exports.signTx = signTx;


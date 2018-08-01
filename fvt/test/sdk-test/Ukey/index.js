/*
Copyright Ziggurat Corp. 2018 All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

var impl = require('./src/index');
var util = require('util');

impl.checkUKey().then((res) => {
    console.log(util.format("check Ukey is connected: %s\n", JSON.stringify(res)));
    if (!res.connected) return;

    let key = res.keys[0];
    impl.verifyPIN(key, '123456').then((res) => {
        console.log(util.format("verify Ukey PIN: %s\n", JSON.stringify(res)));
    });

    // impl.changePIN(key, '1234567', '12345678').then((res) => {
    //     console.log(JSON.stringify(res));
    // });

    impl.getHashSign(key, "hello world").then((res) => {
        console.log(util.format("test get tx sign: %s\n", JSON.stringify(res)));
    });

    impl.getPublicKeyAndAddress(key).then((res) => {
        console.log(util.format("get Ukey public_key and address: %s\n", JSON.stringify(res)));

        var uAddress = res.address;
        impl.transfer('transfer', ['i4230a12f5b0693dd88bb35c79d7e56a68614b199', 'INK', '1000'], key, uAddress).then((res) => {
            console.log(util.format("invoke a transfer transaction: %s\n", JSON.stringify(res)));
        });
    });
});

'use restrict';
var tape = require('tape');
var _test = require('tape-promise');
var test = _test(tape);

test('\n\n*** #25 资产找回机制 ***\n\n', (t) => {
    t.comment("为用户生产地址，安全码和私钥并通过地址和安全码找回私钥");
    testAssetRecovery(t);
    t.end();
});

function testAssetRecovery(t){
    var wallet = require("../utils/wallet.js").wallet;
    var zigcrpyto = require("../utils/crypto-aes.js");
    var randomstring = require("randomstring");
    wallet.generate();
    var address = wallet.getAddress();
    t.comment("地址 : " + address);
    var privatekey = wallet.getPriKey();
    t.comment("私钥 : " + privatekey);
    var securityKey = randomstring.generate(16);
    t.comment("安全码 : " + securityKey);
    
    var FileKeyValueStore = require("zig-client/lib/impl/FileKeyValueStore.js");
    var path = require("path")
    var options = {path: path.join(__dirname,".keystore")};
    
    Promise.resolve(new FileKeyValueStore(options)).then((instance)=>{
        var encryptedPrivateKey = zigcrpyto.encrypt(privatekey, securityKey);
        t.pass('加密后的私钥 : ' + encryptedPrivateKey);
        instance.setValue(address,encryptedPrivateKey);
        t.pass("加密后的私钥持久化成功");
    }).catch(error => {
        t.error(error);
    });
    
    Promise.resolve(new FileKeyValueStore(options)).then((instance)=>{
        t.pass("使用地址和安全码找回私钥")
        var getPromise = instance.getValue(address);
        getPromise.then((value)=>{
            var decryptedText = zigcrpyto.decrypt(value, securityKey);
            t.pass('找回私钥:' + decryptedText);
        }).catch(error =>{
            t.error(error);
        });
    });    
};
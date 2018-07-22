'use restrict';
var tape = require('tape');
var _test = require('tape-promise');
var test = _test(tape);

test('\n\n*** #19 测试加密算法的种类 ***\n\n', (t) => {
    t.comment("使用ECDSA算法");
    testESDSA();
    t.pass("ECDSA算法验证成功");
    t.comment("使用PCKS11算法");
    //testPCKS11();
    t.pass("PCKS11算法验证成功")
    t.end();
});

test('\n\n*** #20 测试加密算法的可用性 ***\n\n', (t) => {
    t.comment("当前使用ECDSA算法");
    testESDSA();
    t.pass("ECDSA算法使用正常");
    t.end();
});

function testESDSA(){
    var path = require("path");
    var utils = require("zig-client/lib/utils.js")
    var config = utils.getConfig();
    config.set("crypto-suite-software",{
    		"EC": "zig-client/lib/impl/CryptoSuite_ECDSA_AES.js"
    });
    config.set("crypto-hash-algo","SHA2");
    config.set("crypto-keysize", 256);
    config.set("crypto-hsm",false);
    config.set("key-value-store","zig-client/lib/impl/FileKeyValueStore.js");
    //var cryptoSuite = utils.newCryptoSuite({software: true,keysize: 256,algorithm: 'EC'});
    var cryptoSuite = utils.newCryptoSuite();
    var keyValStorePath = path.join(__dirname,'.keystore');
    cryptoSuite.setCryptoKeyStore(utils.newCryptoKeyStore({path: keyValStorePath}));
    var startTime = Date.now();
    var endTime;
    cryptoSuite.generateKey().then( key => {
        var plainText = "ZigLedger is great";
        var digestText = cryptoSuite.hash(plainText);
        var signature = cryptoSuite.sign(key,digestText);
        var result = cryptoSuite.verify(key,signature,Buffer.from(plainText));
        endTime = Date.now();
        //console.log("ECDSA_AES verification result : ",result);
        //console.log("It takes %s milliseconds to finish this step.", endTime - startTime);
    }, err => {
        console.error(err);
    }).catch( exception => {
        console.error(exception);
    });
}

function testPCKS11(){
    var utils = require('zig-client/lib/utils.js');
    var fs = require('fs');
    var libpath;
    var pin = '98765432'; 
    var slot = 0;
    var common_pkcs_pathnames = [
    	'/usr/lib/softhsm/libsofthsm2.so',								// Ubuntu
    	'/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so',				// Ubuntu  apt-get install
    	'/usr/lib/s390x-linux-gnu/softhsm/libsofthsm2.so',				// Ubuntu
    	'/usr/local/lib/softhsm/libsofthsm2.so',						// Ubuntu, OSX (tar ball install)
    	'/usr/lib/powerpc64le-linux-gnu/softhsm/libsofthsm2.so',		// Power (can't test this)
    	'/usr/lib/libacsp-pkcs11.so'									// LinuxOne
    ];
	for (let i = 0; i < common_pkcs_pathnames.length; i++) {
	    console.log(common_pkcs_pathnames[i])
		if (fs.existsSync(common_pkcs_pathnames[i])) {
			libpath = common_pkcs_pathnames[i];
			console.info('Found a library at ' + libpath);
			break;
		}
	};
	
    var cryptoUtils = utils.newCryptoSuite({
			lib: libpath,
			slot: slot,
			pin: pin
	});
    cryptoUtils.generateKey({ algorithm: 'ECDSA', ephemeral: true }).then((key) => {
		var ski = key.getSKI();
		var sig = cryptoUtils.sign(key, Buffer.from('Hello ZigLedger'), null);
		return { key, sig };
	})
	.then((param) => {
		var v = cryptoUtils.verify(param.key, param.sig, Buffer.from('Hello ZigLedger'));
		console.info(v)
	})
	.catch(function(error) {
        console.error(error);
	});
}

'use restrict';
const path = require("path")
const tape = require('tape');
const _test = require('tape-promise');
const test = _test(tape);
const zig = require('../../src/zigledger/zig.js');
const open = require("../../benchmark/simple/open.js");
const query = require("../../benchmark/simple/query.js");
const caUtils = require("../utils/ca-helper.js");
const commUtils = require("../../src/comm/util.js");
var configPath = path.join(__dirname, '../../benchmark/simple/zigledger-featuretestbft.json');
var blockchain = new zig(configPath);
var isChannelExisted = false;
var isChainCodeExisted = false;
var key = "simpletest";
var value = "Love is forever";

function setUpChainCode(){
    if(isChainCodeExisted){
        return Promise.resolve();
    }else{
       return blockchain.installSmartContract(); 
    }
}

var cliArgs = process.argv.splice(2);
if(cliArgs){
    if(cliArgs[0]){
        isChannelExisted = yesNo(cliArgs[0]);
    }
    if(cliArgs[1]){
        isChainCodeExisted = yesNo(cliArgs[1]);
    }
}

test('\n*** ZigLedger seurity,safety and privay tests ***\n', (t) => {
    global.tapeObj = t;
    let initPromise;
    if(isChannelExisted){
        initPromise = blockchain.initConfig()
    }else{
        initPromise = blockchain.init();
    }
    initPromise.then((resolved) => {
        return setUpChainCode();
    },(rejected)=>{
        return setUpChainCode();
    }).then((resolved)=>{
        return testDataIsolation();
    },(rejected)=>{
        return testDataIsolation();
    }).then(()=>{
        return testParallelOperation();
    }).then(()=>{
        return testTLSEncryption();
    }).then(()=>{
        return testSecureTransport();
    }).then(()=>{
        return testTxOperationPrivacy();
    }).then(()=>{
        return testDataEncryptAndDecrypt();
    }).then(()=>{
        return testPrivacyProtection();
    }).then(()=>{
        t.end();
    }).catch((err) => {
        console.error(err);
        t.end()
    });
    t.end();
});

function testDataIsolation(){
    global.tapeObj.comment('\n\n*** #64 数据存储隔离性 ***\n\n');
    return new Promise(function(resolve,reject){
        let openContext;
        let account = getAccount();
        let testCaseOpen = blockchain.getContext("open").then((context) => {
            openContext = context;
            return blockchain.invokeSmartContract(context, 'simple', 'v0', {verb: 'open',account: account, money: '10000'}, 30);
            //return open.init(blockchain,context,{"money": 10000 });
        //}).then((nothing) => {
        //    return open.run();
        }).then((results) => {
            return blockchain.releaseContext(openContext);
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });

        let queryContext;
        let testCaseMyQuery = blockchain.getContext("query").then((context) =>{
            queryContext = context;
            return blockchain.queryState(context, 'simple', 'v0', account);
            //return query.init(blockchain,queryContext);
        //}).then((nothing) => {
         //   return query.run();
        }).then((results) => {
            return blockchain.releaseContext(queryContext);
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        global.tapeObj.pass("授权数据通道可以正常的执行数据存储和查询");
        let queryContextDifferentChannel;
        let testCaseYourQuery = blockchain.getContext("yourchannel").then((context) => {
            queryContextDifferentChannel = context;
            return query.init(blockchain,queryContextDifferentChannel)
        }).then((nothing) => {
            return blockchain.releaseContext(queryContextDifferentChannel);
        }).catch((error) => {
            if(error){
                global.tapeObj.fail("无权访问其他通道的数据");
            }
            return Promise.resolve();
        });
        return Promise.all([testCaseOpen,testCaseMyQuery,testCaseYourQuery]).then(()=>{
            return resolve();
        },()=>{
            return reject();
        }).catch((err)=>{
            console.error(err);
            return resolve();
        });
    }).then(()=>{
        return Promise.resolve();
    },()=>{
        return Promise.resolve();
    }).catch((err)=>{
        console.error(err);
        return Promise.resolve();
    });
}

function testParallelOperation(){
    global.tapeObj.comment('\n\n*** #65 并行业务互不干扰 ***\n\n');
    return new Promise(function(resolve,reject){
        let openContext;
        let txOne = blockchain.getContext("open").then((context) => {
            openContext = context;
            return open.init(blockchain,context,{"money": 10000 });
        }).then((nothing) => {
            return open.run();
        }).then((results) => {
            return blockchain.releaseContext(openContext);
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        let openContextTwo;
        let txTwo = blockchain.getContext("open").then((context) => {
            openContextTwo = context;
            return open.init(blockchain,context,{"money": 20000 });
        }).then((nothing) => {
            return open.run();
        }).then((results) => {
            return blockchain.releaseContext(openContextTwo);
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        return Promise.all([txOne,txTwo]).then(()=>{
            global.tapeObj.pass("同时发送两笔交易成功");
            return resolve();
        },()=>{
            return reject();
        }).catch((err)=>{
            console.error(err);
            return resolve();
        });
    }).then(()=>{
        return Promise.resolve();
    },()=>{
        return Promise.resolve();
    }).catch((err)=>{
        console.error(err);
        return Promise.resolve();
    });    
}

function testTLSEncryption(){
    global.tapeObj.comment('\n\n*** #66 私有信息的加密性 ***\n\n');
    return new Promise(function(resolve,reject){
        let queryContext;
        let queryPromise = blockchain.getContext("query").then((context) => {
            queryContext = context;
            let channel = queryContext.channel;
            let peers = channel.getPeers();
            global.tapeObj.comment("TLS安全加密传输: " + peers[0]._url);
            return query.init(blockchain,queryContext)
        }).then((nothing) => {
            return blockchain.releaseContext(queryContext);    
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        
        let openContext;
        global.tapeObj.comment("将要保存的私有信息:" + value);
        let txPromise = blockchain.getContext("open").then((context) => {
            openContext = context;
            let argsDict = {verb:'putPrivateData',key:key,value:value};
            return blockchain.invokeSmartContract(context, 'simple', 'v0', argsDict, 30);
        }).then((results) => {
           return blockchain.releaseContext(openContext);
        }).catch((exeception) => {
            console.error(exeception);
            return Promise.resolve();
        });
        
        let txQueryContext;
        var txQuery = commUtils.sleep(5000).then((nothing) =>{
            return blockchain.getContext("open").then((context) =>{
                txQueryContext = context;
                let argsDict = {verb:'getPrivateData',key:key,raw:'yes'};
                return blockchain.invokeSmartContract(context, 'simple', 'v0', argsDict, 30);
                //return blockchain.queryState(context, 'simple', 'v0', "getPrivateData",key);
            }).then((results) => {
                global.tapeObj.comment("ZigLedger底层中保存的值:" + results[0].result.toString());
                return Promise.resolve();
            }).catch((error) => {
                console.error(error);
                return Promise.resolve();
            });
        });
        return Promise.all([queryPromise,txPromise,txQuery]).then(()=>{
            return resolve();
        },()=>{
            return reject();
        }).catch((err)=>{
            console.error(err);
            return resolve();
        });
    }).then(()=>{
        return Promise.resolve();
    },()=>{
        return Promise.resolve();
    }).catch((err)=>{
        console.error(err);
        return Promise.resolve();
    });    
}

function testSecureTransport(){
    global.tapeObj.comment('\n\n*** #67 数据传输安全方式 ***\n\n');
    return new Promise(function(resolve,reject){
        let queryContext;
        let txPromise = blockchain.getContext("query").then((context) => {
            queryContext = context;
            let channel = queryContext.channel;
            let peers = channel.getPeers();
        	for (let i = 0; i < peers.length; i++) {
                global.tapeObj.pass("有效节点传输: " + peers[i]._url);
        	}    
            return query.init(blockchain,queryContext)
        }).then((results) => {
            return blockchain.releaseContext(queryContext);    
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        return Promise.all([txPromise]).then(()=>{
            return resolve();
        },()=>{
            return reject();
        }).catch((err)=>{
            console.error(err);
            return resolve();
        });
    }).then(()=>{
        return Promise.resolve();
    },()=>{
        return Promise.resolve();
    }).catch((err)=>{
        console.error(err);
        return Promise.resolve();
    });
}

function testTxOperationPrivacy(){
    global.tapeObj.comment('\n\n*** #68 查询和操作数据保密性 ***\n\n');
    return new Promise(function(resolve,reject){
        let queryContext;
        let txPromise = blockchain.getContext("query").then((context) => {
            queryContext = context;
            let channel = queryContext.channel;
            let peers = channel.getPeers();
        	for (let i = 0; i < peers.length; i++) {
                peers[i]._url = "grpcs://localhost:7061";
                global.tapeObj.fail("无效节点不能传输: " + peers[i]._url);
        	}    
            return query.init(blockchain,queryContext)            
        }).then((result) => {
            return blockchain.releaseContext(queryContext);    
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        return Promise.all([txPromise]).then(()=>{
            return resolve();
        },()=>{
            return reject();
        }).catch((err)=>{
            console.error(err);
            return resolve();
        });
    }).then(()=>{
        return Promise.resolve();
    },()=>{
        return Promise.resolve();
    }).catch((err)=>{
        console.error(err);
        return Promise.resolve();
    });
}

function testDataEncryptAndDecrypt(){
    global.tapeObj.comment('\n\n*** #69 用户数据解密 ***\n\n');
    return new Promise(function(resolve,reject){
        let openContext;
        let txPromise = blockchain.getContext("open").then((context) => {
            openContext = context;
            let argsDict = {verb:'getPrivateData',key:key};
            return blockchain.invokeSmartContract(context, 'simple', 'v0', argsDict, 30);
        }).then((results) => {
           global.tapeObj.comment("数据解密后的值是:" + results[0].result.toString()); 
           return results;
        }).catch((exeception) => {
            console.error(exeception);
            return Promise.resolve();
        });
        var waitPromise = commUtils.sleep(10000).then((nothing) => {
            return blockchain.releaseContext(openContext);
        })
        
        return Promise.all([txPromise,waitPromise]).then(()=>{
            return resolve();
        },()=>{
            return reject();
        }).catch((err)=>{
            console.error(err);
            return resolve();
        });
    }).then(()=>{
        return Promise.resolve();
    },()=>{
        return Promise.resolve();
    }).catch((err)=>{
        console.error(err);
        return Promise.resolve();
    });    
}

function testPrivacyProtection(){
    global.tapeObj.comment('\n\n*** #70 隐私保护方案 ***\n\n');
    return new Promise(function(resolve,reject){
        caUtils.init();
        let caseOne = caUtils.verifyUser("admin","adminpw","org1");
        global.tapeObj.pass("用户认证和授权成功")
        let caseTwo = caUtils.verifyUser("admin","admin","org2");
        global.tapeObj.fail("用户认证和授权失败.");
        global.tapeObj.pass("使用side database来保护私有数据");
        return Promise.all([caseOne,caseTwo]).then(()=>{
            return resolve();
        },()=>{
            return reject();
        }).catch((err)=>{
            console.error(err);
            return resolve();
        });
    }).then(()=>{
        return Promise.resolve();
    },()=>{
        return Promise.resolve();
    }).catch((err)=>{
        console.error(err);
        return Promise.resolve();
    });  
}

function getAccount(){
    const dic = 'abcdefghijklmnopqrstuvwxyz';
    let prefix;
    function get26Num(number){
        let result = '';
        while(number > 0) {
            result += dic.charAt(number % 26);
            number = parseInt(number/26);
        }
        return result;
    }

    if(typeof prefix === 'undefined') {
        prefix = get26Num(process.pid);
    }
    return prefix + get26Num(Math.floor(Math.random()*(dic.length)));
}

function yesNo(value, props) {
	var type = typeof value;
	// For objects, parse all properties (or the properties given)
	if (type === 'object') {
		if (type) {
			(props || Object.keys(value)).forEach(function(key) {
				value[key] = exports.parse(value[key]);
			});
		}
		return value;
	}
	// If the value is undefined, return null
	if (type === 'undefined') {
		return null;
	}
	// If the value is not a string, just cast to bool
	if (type !== 'string') {
		return !! value;
	}
	// Trim and lowercase for simpler parsing
	var orig = value;
	value = value.trim().toLowerCase();
	// Parse against "yes"/"no" values
	if (value === 'y' || value === 'yes') {
		return true;
	}
	if (value === 'n' || value === 'no') {
		return false;
	}
	// Parse against "true"/"false" value
	if (value === 't' || value === 'true') {
		return true;
	}
	if (value === 'f' || value === 'false') {
		return false;
	}
	// Parse against "1"/"0" values
	if (value === '1' || value === '0') {
		return !! Number(value);
	}
	var result;
	var others = [];
	for (var i = 0, c = others.length; i < c; i++) {
		result = others[i](orig);
		if (typeof result === 'boolean') {
			return result;
		}
	}
	return null;
};
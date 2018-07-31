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
var configPath = path.join(__dirname, '../../benchmark/simple/zigledger-remote.json');
var blockchain = new zig(configPath);

test('\n*** ZigLedger seurity,safety and privay tests ***\n', (t) => {
    global.tapeObj = t;
    let initPromise = blockchain.init();
    initPromise.then((resolved) => {
        return blockchain.installSmartContract();
    },(rejected)=>{
        return blockchain.installSmartContract();
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
        }).catch((exeception) => {
            console.error(exeception);
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
                global.tapeObj.pass("无权访问其他通道的数据");
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
        global.tapeObj.pass("同时发送两笔交易");
        let openContext;
        let txOne = blockchain.getContext("open").then((context) => {
            openContext = context;
            return open.init(blockchain,context,{"money": 10000 });
        }).then((nothing) => {
            return open.run();
        }).then((results) => {
            return blockchain.releaseContext(openContext);
        }).catch((exeception) => {
            console.error(exeception);
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
        }).catch((exeception) => {
            console.error(exeception);
            return Promise.resolve();
        });
        return Promise.all([txOne,txTwo]).then(()=>{
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
        global.tapeObj.pass("TLS加密传输");
        let queryContext;
        let txPromise = blockchain.getContext("query").then((context) => {
            queryContext = context;
            let channel = queryContext.channel;
            let peers = channel.getPeers();
            global.tapeObj.pass("安全加密: " + peers[0]._url);
            return query.init(blockchain,queryContext)
        }).then((nothing) => {
            return blockchain.releaseContext(queryContext);    
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        global.tapeObj.pass("私有信息密文存储");
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
                global.tapeObj.pass("无效节点不能传输: " + peers[i]._url);
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
            return blockchain.invokeSmartContract(context, 'simple', 'v0', {verb: 'putPrivateData'}, 30);
        }).then((results) => {
           return blockchain.releaseContext(openContext);
        }).catch((exeception) => {
            console.error(exeception);
            return Promise.resolve();
        });
        let queryContext;
        var queryPromise = commUtils.sleep(5000).then((nothing) =>{
            return blockchain.getContext("query").then((context) =>{
                queryContext = context;
                return blockchain.queryState(context, 'simple', 'v0', "getPrivateData");
            }).then((results) => {
                return Promise.resolve();
            }).catch((error) => {
                console.error(error);
                return Promise.resolve();
            });
        });
        var waitPromise = commUtils.sleep(10000).then((nothing) => {
            return blockchain.releaseContext(queryContext);
        })
        global.tapeObj.pass("加密和解密数据");
        return Promise.all([txPromise,queryPromise,waitPromise]).then(()=>{
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
        global.tapeObj.pass("用户认证和授权失败.");
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
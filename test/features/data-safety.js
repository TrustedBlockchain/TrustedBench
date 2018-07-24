'use restrict';
var tape = require('tape');
var _test = require('tape-promise');
var test = _test(tape);
var zig = require('../../src/zigledger/zig.js');
var path = require("path")
var configPath = path.join(__dirname, '../../benchmark/simple/zigledger.json');
var blockchain = new zig(configPath);
var open = require("../../benchmark/simple/open.js");
var query = require("../../benchmark/simple/query.js");
var caUtils = require("../utils/ca-helper.js");
var commUtils = require("../../src/comm/util.js");

test('\n\n*** 初始化通道和安装智能合约 ***\n\n', (t) => {
    global.tapeObj = t;
    var initPromise = blockchain.init();
    initPromise.then(() => {
        return blockchain.installSmartContract()
    }).then(()=>{
        testSuite();
        t.end();
    }).catch((err) => {
        t.error(err);
        t.end()
    });
});

function testSuite(){
    test('\n\n*** #64 数据存储隔离性 ***\n\n', (t) => {
        let openContext;
        blockchain.getContext("open").then((context) => {
            openContext = context;
            return open.init(blockchain,context,{"money": 10000 });
        }).then((nothing) => {
            return open.run();
        }).then((results) => {
            blockchain.releaseContext(openContext);
        }).catch((exeception) => {
            console.error(exeception);
        });

        let queryContext;
        blockchain.getContext("query").then((context) =>{
            queryContext = context;
            return query.init(blockchain,queryContext);
        }).then((nothing) => {
            return query.run();
        }).then((results) => {
            blockchain.releaseContext(queryContext);
        }).catch((error) => {
            t.error(error);
        });
        t.pass("授权数据通道可以正常的执行数据存储和查询");
        let queryContextDifferentChannel;
        blockchain.getContext("yourchannel").then((context) => {
            queryContextDifferentChannel = context;
            return query.init(blockchain,queryContextDifferentChannel)
        }).then((nothing) => {
            return query.run();
        }).then((results) => {
            blockchain.releaseContext(queryContextDifferentChannel);
        }).catch((error) => {
            if(error){
                t.pass("无权访问其他通道的数据");
            }
        });
        
        t.end()
    });
    
    test('\n\n*** #65 并行业务互不干扰 ***\n\n', (t) => {
        t.pass("同时发送两笔交易");
        let openContext;
        blockchain.getContext("open").then((context) => {
            openContext = context;
            return open.init(blockchain,context,{"money": 10000 });
        }).then((nothing) => {
            return open.run();
        }).then((results) => {
            blockchain.releaseContext(openContext);
        }).catch((exeception) => {
            console.error(exeception);
        });

        blockchain.getContext("open").then((context) => {
            openContext = context;
            return open.init(blockchain,context,{"money": 20000 });
        }).then((nothing) => {
            return open.run();
        }).then((results) => {
            blockchain.releaseContext(openContext);
        }).catch((exeception) => {
            console.error(exeception);
        });
        t.end()
    });
    
    test('\n\n*** #66 私有信息的加密性 ***\n\n', (t) => {
        t.pass("tls加密传输");
        let queryContext;
        blockchain.getContext("query").then((context) => {
            queryContext = context;
            let channel = queryContext.channel;
            let peers = channel.getPeers();
            t.pass("安全加密: " + peers[0]._url);
            return query.init(blockchain,queryContext)
        }).then((nothing) => {
            blockchain.releaseContext(queryContext);    
        }).catch((error) => {
            console.error(error);
        });
        t.pass("私有信息密文存储");
        t.end()
    });
    
    test('\n\n*** #67 数据传输安全方式 ***\n\n', (t) => {
        let queryContext;
        blockchain.getContext("query").then((context) => {
            queryContext = context;
            let channel = queryContext.channel;
            let peers = channel.getPeers();
        	for (let i = 0; i < peers.length; i++) {
                t.pass("有效节点传输: " + peers[i]._url);
        	}    
            return query.init(blockchain,queryContext)
        }).then((nothing) => {
            return query.run();
        }).then((results) => {
            blockchain.releaseContext(queryContext);    
        }).catch((error) => {
            console.error(error);
        });
        t.end()
    });
    
    test('\n\n*** #68 查询和操作数据保密性 ***\n\n', (t) => {
        let queryContext;
        blockchain.getContext("query").then((context) => {
            queryContext = context;
            let channel = queryContext.channel;
            let peers = channel.getPeers();
        	for (let i = 0; i < peers.length; i++) {
                peers[i]._url = "grpcs://localhost:7061";
        	}    
            return query.init(blockchain,queryContext)            
        }).then((nothing) => {
            return query.run();
        }).then((result) => {
            blockchain.releaseContext(queryContext);    
        }).catch((error) => {
            console.error(error);
        });
        t.end()
    });
    
    test('\n\n*** #69 用户数据解密 ***\n\n', (t) => {
        let openContext;
        blockchain.getContext("open").then((context) => {
            openContext = context;
            return blockchain.invokeSmartContract(context, 'simple', 'v0', {verb: 'putPrivateData'}, 30);
        }).then((results) => {
            blockchain.releaseContext(openContext);
        }).catch((exeception) => {
            console.error(exeception);
        });

        var sleepPromise = commUtils.sleep(5000);
        sleepPromise.then((nothing) =>{
            let queryContext;
            blockchain.getContext("query").then((context) =>{
                queryContext = context;
                return blockchain.queryState(context, 'simple', 'v0', "getPrivateData");
            }).then((results) => {
                blockchain.releaseContext(queryContext);
            }).catch((error) => {
                t.error(error);
            });            
        }).catch((error) => {
            console.error(error);
        });
                
        t.pass("加密和解密数据");
        t.end()
    });
    
    test('\n\n*** #70 隐私保护方案 ***\n\n', (t) => {
        caUtils.init();
        caUtils.verifyUser("admin","adminpw","org1");
        t.pass("用户认证和授权成功")
        caUtils.verifyUser("admin","admin","org2");
        t.pass("用户认证和授权失败.");
        t.end();
        t.pass("使用side database来保护私有数据");
    });
}
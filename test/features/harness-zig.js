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
test('\n\n*** 初始化ZigLedger网络 ***\n\n', (t) => {
    global.tapeObj = t;
    var initPromise = blockchain.init();
    initPromise.then(() => {
        t.comment("finish the channel initialization");
        return blockchain.installSmartContract()
    }).then(()=>{
        t.comment("finish the smart contract steps");
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

        t.comment("finish the invoke operation");
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
        
        t.comment("finsih the query operation");
        
        let queryContextDifferentChannel;
        blockchain.getContext("query").then((context) => {
            queryContextDifferentChannel = context;
            queryContextDifferentChannel.channel = "yourchannel";
            return query.init(blockchain,queryContextDifferentChannel)
        }).then((nothing) => {
            return query.run();
        }).then((results) => {
            blockchain.releaseContext(queryContextDifferentChannel);
        }).catch((error) => {
            console.error(error);
        });
        
        t.end()
    });
}

/*
test('\n\n*** 使用证书授权来维护数据安全 ***\n\n',(t) => {
    caUtils.init();
    caUtils.verifyUser("admin","adminpw","org1");
    t.pass("用户认证和授权成功")
    caUtils.verifyUser("admin","admin","org2");
    t.pass("用户认证和授权失败.");
    t.end();
});
*/
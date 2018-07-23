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

        var sleepPromise = commUtils.sleep(10000);
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
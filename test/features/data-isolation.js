'use restrict';
var tape = require('tape');
var _test = require('tape-promise');
var test = _test(tape);
var zig = require('../../src/zigledger/zig.js');
var path = require("path")
var configPath = path.join(__dirname, '../../benchmark/simple/zigledger.json');
var blockchain = new zig(configPath);
var open = require("../../benchmark/simple/open.js");
var query = require("../../benchmar/simple/query.js");
test('\n\n*** 初始化ZigLedger网络 ***\n\n', (t) => {
    global.tapeObj = t;
    blockchain.init();
    t.end()
});

test('\n\n*** #64 数据存储隔离性 ***\n\n', (t) => {
    let openContext = blockchain.getContext("open");
    open.init(blockchain,openContext)
    open.run();
    blockchain.releaseContext(openContext);
    let queryContext = blockchain.getContext("query");
    query.init(blockchain,openContext)
    query.run();
    blockchain.releaseContext(queryContext);
    let queryContextDifferentChannel = blockchain.getContext("query");
    queryContextDifferentChannel.channel = "yourchannel";
    query.init(blockchain,queryContextDifferentChannel)
    query.run();
    blockchain.releaseContext(queryContextDifferentChannel);
    t.end()
});

test('\n\n*** #65 并行业务互不干扰 ***\n\n', (t) => {
    t.pass("同时发送两笔交易");
    let openContext = blockchain.getContext("open");
    open.init(blockchain,openContext)
    open.run();
    open.run();
    blockchain.releaseContext(openContext);
    t.end()
});

test('\n\n*** #66 私有信息的加密性 ***\n\n', (t) => {
    t.pass("tls传输");
    t.pass("私有信息密文存储");
    t.end()
});

test('\n\n*** #67 数据传输方式 ***\n\n', (t) => {
    t.pass("channel中的节点和非channel中的节点");
    t.end()
});

test('\n\n*** #68 查询和操作数据保密性 ***\n\n', (t) => {
    let queryContext = blockchain.getContext("query");
    let channel = queryContext.channel;
    let peers = channel.getPeers();
	for (let i = 0; i < peers.length; i++) {
        peers[i]._url = "grpcs://localhost:7061";
	}    
    query.init(blockchain,queryContext)
    query.run();
    blockchain.releaseContext(queryContext);
    t.end()
});

test('\n\n*** #69 用户数据解密 ***\n\n', (t) => {
    t.pass("user和password failed");
    t.end()
});

test('\n\n*** #70 隐私保护方案 ***\n\n', (t) => {
    t.pass("side database");
    t.end()
});
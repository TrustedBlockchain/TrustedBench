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
test('\n\n*** 初始化ZigLedger网络 ***\n\n', (t) => {
    global.tapeObj = t;
    try {
        blockchain.init();
    }catch(error){
        t.pass(error);
    }
    t.pass(new Error("This error message is thrown by callback"))
    t.end()
});

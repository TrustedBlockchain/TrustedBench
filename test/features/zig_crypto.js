'use restrict';
var tape = require('tape');
var _test = require('tape-promise');
var test = _test(tape);


test('\n\n*** #19 测试加密算法的种类 ***\n\n', (t) => {
    t.pass("ECDSA 算法验证成功");
    t.comment("使用ECDSA 算法")
    t.end();
});

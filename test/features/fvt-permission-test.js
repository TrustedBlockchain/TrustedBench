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
var isChannelExisted = true;
var isChainCodeExisted = true;
var key = "simpletest";

var user1 = "alice";
var user2 = "bob";

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

test('\n*** ZigLedger 用户授权和数据权限测试 ***\n', (t) => {
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
        return testHasPermission();
    },(rejected)=>{
        return testHasPermission();
    }).then(()=>{
        return testDataPermission();
    }).then(()=>{
        t.end();
    }).catch((err) => {
        console.error(err);
        t.end()
    });
    t.end();
});

function testHasPermission(){
    global.tapeObj.comment('\n\n*** 验证Bob是否拥有Alice的授权 ***\n\n');
    return new Promise(function(resolve,reject){
        let openContext;
        let permissionPromise = blockchain.getContext("open").then((context) => {
            openContext = context;
            return blockchain.invokeSmartContract(context, 'simple', 'v0', {verb: 'hasPermission',user1: user1, user2: user1}, 30);
        }).then((results) => {
            if(!results[0].result.toString()){
                global.tapeObj.fail("Bob没有Alice的授权，无法访问Alice的数据");
            }
            return blockchain.releaseContext(openContext);
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        return Promise.all([permissionPromise]).then(()=>{
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

function testDataPermission(){
    return new Promise(function(resolve,reject){
        let grantContext ;
        global.tapeObj.comment('\n\n*** Alice 授权给 Bob ***\n\n');
        let grantPromise = blockchain.getContext("open").then((context) => {
            grantContext = context;
            let argsDict = {verb:'grantPermission',user1:user1,user2:user2};
            return blockchain.invokeSmartContract(context, 'simple', 'v0', argsDict, 30);
        }).then((results) => {
            if(results && results[0].status == 'success'){
                global.tapeObj.pass('Alice授权Bob成功');
            }
            return blockchain.releaseContext(grantContext);
        }).catch((error) => {
            console.error(error);
            return Promise.resolve();
        });
        
        let openContext;
        
        let txPromise = commUtils.sleep(2000).then(()=>{
            return blockchain.getContext("open").then((context) => {
                openContext = context;
                let argsDict = {verb:'getPrivateData',key:key};
                return blockchain.invokeSmartContract(context, 'simple', 'v0', argsDict, 30);
            }).then((results) => {
               global.tapeObj.pass("Bob获得的数据值是 :" + results[0].result.toString()); 
               return results;
            }).catch((error) => {
                console.error(error);
                return Promise.resolve();
            });
        })
        
        var waitPromise = commUtils.sleep(10000).then((nothing) => {
            return blockchain.releaseContext(openContext);
        })
        return Promise.all([grantPromise,txPromise,waitPromise]).then(()=>{
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
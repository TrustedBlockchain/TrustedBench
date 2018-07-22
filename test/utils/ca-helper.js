'use restrict';

const Client = require("zig-client");
const copService = require('zig-ca-client/lib/FabricCAClientImpl.js');
const User = require('zig-client/lib/User.js');
const commUtils = require('../../src/comm/util.js');
const Constants = require('../../src/zigledger/constant.js');
const path = require("path");
const fs = require('fs-extra');
const tlsOptions = {
    trustedRoots: [],
    verify: false
};

let ORGS

module.exports.init = function(){
    var configPath = path.join(__dirname, '../../benchmark/simple/zigledger.json');
    Client.addConfigFile(configPath);
    const fa = Client.getConfigSetting('zigledger');
    ORGS = fa.network;
}

const tempdir = Constants.tempdir;

module.exports.getTempDir = function() {
    fs.ensureDirSync(tempdir);
    return tempdir;
};

// directory for file based KeyValueStore
module.exports.KVS = path.join(tempdir, 'hfc-test-kvs');
module.exports.storePathForOrg = function(org) {
    return module.exports.KVS + '_' + org;
};

module.exports.verifyUser = function(username, password,userOrg) {
    const caUrl = ORGS[userOrg].ca.url;
    let client = new Client();
    return client.getUserContext(username, true)
        .then((user) => {
            return new Promise((resolve, reject) => {
                if (user && user.isEnrolled()) {
                    return resolve(user);
                }

                const member = new User(username);
                let cryptoSuite = client.getCryptoSuite();
                if (!cryptoSuite) {
                    cryptoSuite = Client.newCryptoSuite();
                    if (userOrg) {
                        cryptoSuite.setCryptoKeyStore(Client.newCryptoKeyStore({path: module.exports.storePathForOrg(ORGS[userOrg].name)}));
                        client.setCryptoSuite(cryptoSuite);
                    }
                }
                member.setCryptoSuite(cryptoSuite);

                // need to enroll it with CA server
                const cop = new copService(caUrl, tlsOptions, ORGS[userOrg].ca.name, cryptoSuite);

                return cop.enroll({
                    enrollmentID: username,
                    enrollmentSecret: password
                }).then((enrollment) => {
                    return member.setEnrollment(enrollment.key, enrollment.certificate, ORGS[userOrg].mspid);
                }).then(() => {
                    let skipPersistence = false;
                    if (!client.getStateStore()) {
                        skipPersistence = true;
                    }
                    return client.setUserContext(member, skipPersistence);
                }).then(() => {
                    return resolve(member);
                }).catch((err) => {
                    commUtils.log('Failed to verify user. Error: ' + (err.stack ? err.stack : err));
                });
            });
        });
}


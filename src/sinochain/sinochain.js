'use strict';

const BlockchainInterface = require('../comm/blockchain-interface.js');
const TxStatus = require('../comm/transaction');
const commUtil = require('../comm/util.js');

const grpc = require('grpc');
const common_proto = grpc.load(__dirname + '/common/cloud.proto').common;

/**
 * Implements {BlockchainInterface} for sinochain cloud server
 */
class Sinochain extends BlockchainInterface {

    /**
     * Create a new instance of the {Sinochain} class
     * @param {string} config_path The path of the Sinochain configuration file.
     */
    constructor(config_path) {
        super(config_path);
        this.config = require(this.configPath);
        this.servers = this.config.sinochain.cloud.servers;
        this.channel = this.config.sinochain.channel;
        this.client = new common_proto.CloudBD(this.getRandomServer(), grpc.credentials.createInsecure());
        this.deliver = this.client.deliver();
        this.context = null;
        this.connected = true;
        this.results = {};
        this.lastTimeout = null;
        this.receivedEnd = false;
        this.receivedCount = 0;
        this.lastDataTime = null;
        let that = this;
        this.deliver.on('data', env => {
            if (that.lastTimeout !== null) {
                clearTimeout(that.lastTimeout);
            }
            that.receivedCount++;
            let invokeStatus = that.results[env.seqnum];
            if (invokeStatus) {
                if (env.status === 'SUCCESS') {
                    invokeStatus.SetStatusSuccess();
                    //invokeStatus.SetFinalTime(new Date());
                    invokeStatus.SetFinalTime(env.endTime);
                } else {
                    invokeStatus.SetStatusFail();
                    invokeStatus.SetFinalTime(env.endTime);
                }
                // that.results[env.seqnum] = invokeStatus;
                if (that.context && that.context.engine) {
                    that.context.engine.addResult(invokeStatus);
                }
                that.lastDataTime = env.endTime;
                delete this.results[env.seqnum];
            }
            if (that.context && that.context.txNum) {
                if (that.receivedCount === that.context.txNum) {
                    that.setToFail(that);
                    return;
                }
            }
            that.lastTimeout = setTimeout(function() {
                that.setToFail(that);
            }, 10000);
        }).on('end', function() {
            that.sinoDisconnectFromCloud();
        }).on('error', err => {
            that.sinoDisconnectFromCloud();
        });
    }

    /**
     * set all not back to fail
     * @param {Object} that this object
     */
    setToFail(that) {
        for (let seqnum in that.results) {
            let invokeStatus = that.results[seqnum];
            if (invokeStatus) {
                invokeStatus.SetStatusFail();
                invokeStatus.SetFinalTime(that.lastDataTime);
                if (that.context && that.context.engine) {
                    that.context.engine.addResult(invokeStatus);
                }
            }
        }
        that.receivedEnd = true;
    }

    /**
     * sinochain no need init
     * @returns {Promise} The return promise
     */
    init() {
        return Promise.resolve();
    }

    /**
     * sinochain no need install smart contract
     * @return {Promise} The return promise.
     */
    installSmartContract() {
        return Promise.resolve();
    }

    /**
     * sinochain no need context
     * @param {string} name The name of the callback module as defined in the configuration files.
     * @param {object} args Unused.
     * @return {object} The assembled Fabric context.
     */
    getContext(name, args) {
        return Promise.resolve();
    }

    /**
     * repease grpc connection
     * @param {object} context The Fabric context to release.
     * @return {Promise} The return promise.
     */
    releaseContext(context) {
        this.results = {};
        this.sinoDisconnectFromCloud();
        return Promise.resolve();
    }

    /**
     * wait for invoke result
     * @param {integer} seqnum the seqnum wait for
     * @param {integer} checkTimes the result check times
     * @returns {Object<TxStatus>} the result wapper
     */
    /* waitForInvokeBack(seqnum, checkTimes) {
        return commUtil.sleep(1000).then(() => {
            if (this.results[seqnum]) {
                if (this.results[seqnum].Get('status') !== 'submitted') {
                    let invokeStatus = this.results[seqnum];
                    this.results[seqnum] = null;
                    return invokeStatus;
                }
                if (checkTimes > 30) {
                    let invokeStatus = this.results[seqnum];
                    invokeStatus.SetStatusFail();
                    this.results[seqnum] = null;
                    return invokeStatus;
                }
                return this.waitForInvokeBack(seqnum, (checkTimes + 1));
            } else {
                let invokeStatus = new TxStatus(seqnum);
                invokeStatus.SetStatusFail();
                return invokeStatus;
            }
        });
    } */

    /**
     * send data to cloud
     * @param {Object} context context object
     * @param {Object} payload data send to sinochain cloud
     * @returns {Object} the invoke result
     */
    sinoSendToCloud(context, payload) {
        if (this.context === null) {
            this.context = context;
        }
        let env = new common_proto.Envelope();
        env.seqnum = payload.Seqnum;
        env.payload = payload.Payload;
        env.channel = this.channel;
        let invokeStatus = new TxStatus(env.seqnum);
        invokeStatus.Set('status', 'submitted');
        if (this.sinoIsConnectionOpen()) {
            this.deliver.write(env);
            if (context.engine) {
                context.engine.submitCallback(1);
            }
            invokeStatus.Set('status', 'submitted');
            this.results[env.seqnum] = invokeStatus;
            // invokeStatus = this.waitForInvokeBack(env.seqnum, 1);
            return Promise.resolve(invokeStatus);
        } else {
            //invokeStatus.SetFlag();
            invokeStatus.SetErrMsg('Connection is closed.');
            invokeStatus.SetStatusFail();
            if (context.engine) {
                context.engine.addResult(invokeStatus);
            }
            return Promise.resolve(invokeStatus);
        }
    }

    /**
     * whether the connection is open
     * @returns {boolean} true if connected
     */
    sinoIsConnectionOpen() {
        return this.connected;
    }

    /**
     * disconnect from sinochain cloud server
     */
    sinoDisconnectFromCloud() {
        if (this.connected) {
            this.deliver.end();
        }
    }

    /**
     * wait for sinochain cloud data
     * @returns {Promise} the Promise
     */
    async sinoWaitRecv() {
        while(!this.receivedEnd) {
            await commUtil.sleep(1000);
        }
        return Promise.resolve();
        /* if (this.receivedEnd) {
            return Promise.resolve();
        }
        return commUtil.sleep(1000).then(() => {
            // commUtil.log('wait for received end...');
            return this.sinoWaitRecv();
        }); */
    }

    /**
     * return a random cloud server address, for request load balance
     * @returns {string} sinochain cloud server address
     */
    getRandomServer() {
        let randomIndex = Math.floor(Math.random() * this.servers.length);
        return this.servers[randomIndex];
    }
}

module.exports = Sinochain;
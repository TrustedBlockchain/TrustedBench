var ethUtils = require('ethereumjs-util');
var crypto = require('crypto');

class PrivKeyWallet {
    constructor() {
    }

    generate() {
        this.priKey = crypto.randomBytes(32);
        this.pubKey = ethUtils.privateToPublic(this.priKey);
        this.address = ethUtils.publicToAddress(this.pubKey);
    }

    getPriKey() {
        return this.priKey.toString('hex');
    }
    
    getAddress() {
        return ethUtils.toChecksumAddress(`${this.address.toString('hex')}`).toLowerCase().replace('0x', 'i')
    }
    
}

exports.wallet = new PrivKeyWallet();
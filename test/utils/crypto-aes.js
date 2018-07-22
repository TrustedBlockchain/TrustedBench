'use restrict';
var crypto = require('crypto');
const ENCODE_UTF8 = 'utf-8';
const ALGORITHM = 'des-ede3-cbc';
const ENCODE_BASE64 = 'base64';
const ENCODE_ASCII = 'ascii';
const ENCODE_BINARY = 'binary';

function encrypt(text, key) {
    var key = new Buffer(key, ENCODE_UTF8);
    var cipher = crypto.createCipher(ALGORITHM, key);
    var encoded = cipher.update(text, ENCODE_ASCII, ENCODE_BASE64);
    encoded += cipher.final(ENCODE_BASE64);
    return encoded;
}

function decrypt(encryptedText, key) {
    var key = new Buffer(key, ENCODE_UTF8);
    var encrypted = new Buffer(encryptedText, ENCODE_BASE64);
    var decipher = crypto.createDecipher(ALGORITHM, key);
    var decoded = decipher.update(encrypted, ENCODE_BINARY, ENCODE_ASCII);
    decoded += decipher.final(ENCODE_ASCII);
    return decoded;
}

module.exports.encrypt = encrypt;
module.exports.decrypt = decrypt;


const crypto = require('crypto');
const algorithm = 'aes-256-ctr';
const key = "6fa979f20126cb08aa645a8f495f6d85";
const iv = '77895ad36a5d0126';
// const iv = crypto.randomBytes(16);


module.exports = {
    encrypt : function (text){
        let cipher = crypto.createCipheriv(algorithm, key, iv);
        let encrypted = cipher.update(text, 'utf8', 'base64');
        encrypted += cipher.final('base64');
        return encrypted;

    },
    decrypt : function (encrypted){
        let decipher = crypto.createDecipheriv(algorithm, key, iv);
        let decrypted = decipher.update(encrypted, 'base64', 'utf8');
        return (decrypted + decipher.final('utf8'));
    }
}

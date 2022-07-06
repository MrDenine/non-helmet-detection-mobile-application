const encrypt_decrypt_tools = require('../utils/encrypt_decrypt_tools');

module.exports = {
    getUserData : function(req,res){
        const {cookies} = req;
        return JSON.parse(encrypt_decrypt_tools.decrypt(cookies.UDT));
    },
    getUserRole : function(req){
        const {cookies} = req;
        return JSON.parse(encrypt_decrypt_tools.decrypt(cookies.UDT)).role;
    }
}
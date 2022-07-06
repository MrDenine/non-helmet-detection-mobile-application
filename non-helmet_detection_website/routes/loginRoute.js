const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const axios = require('axios');
const config = require('../config');
const encrypt_decrypt_tools = require('../utils/encrypt_decrypt_tools');
const cookieParser = require('cookie-parser');

router.use(bodyParser.urlencoded({extended : false}));
router.use(bodyParser.json());
router.use(cookieParser());

router.post('/',function(req,res,next){
    var username = req.body.Username; 
    var password = req.body.Password;
    if(username && password){
        //call postLogin
        axios
        .post(config.servurl + '/Login/PostLogin',{
            email : username,
            password : password,
        })
        .then(function (response) {
            if(response.data.status == "Succeed"){
                var userid = response.data.data[0].id;
                //call getUserdata
                axios
                .get(config.servurl + '/GetDataUser/'+ response.data.data[0].id)
                .then(function(response){
                    //get userdata
                    userdata = response.data.data[0];
                    userdata.id = userid;
                    userdata_enc = encrypt_decrypt_tools.encrypt(JSON.stringify(response.data.data[0]));
                    
                    // //setCookie
                    res.cookie('UDT', userdata_enc, config.cookie_options);
                    res.status(200).send(response.data);
                    return;
                })
                .catch(function(response){
                    res.status(400).send(response.data);
                    return;
                });
            } else {
                res.status(200).send(response.data); //echo
                return;
            }
        })
        .catch(function (error) {
            res.status(400).send(error); 
            return;
        });
    }
});


module.exports = router;

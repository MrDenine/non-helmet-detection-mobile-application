const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const axios = require('axios');
const config = require('../config');
const encrypt_decrypt_tools = require('../utils/encrypt_decrypt_tools');

router.use(bodyParser.urlencoded({extended : false}));
router.use(bodyParser.json());

router.use(cookieParser());

router.post('/',function(req,res,next){
    var email = req.body.Email;
    var firstname = req.body.Firstname;
    var lastname = req.body.Lastname;
    var password = req.body.Password;
    var datetime = req.body.Datetime;
   
   
    axios
    .post(config.servurl + '/Register/PostRegister',{
        email : email,
        firstname : firstname,
        lastname : lastname,
        password: password,
        datetime : datetime,
    })
    .then(function(response){
        res.status(200).send(response.data);
    })
    .catch(function (error) {
        res.status(400).send(error);
        return;
    });
    
})


module.exports = router;
const express = require('express');
const router = express.Router();
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');
const axios = require('axios');
const config = require('../config');
const encrypt_decrypt_tools = require('../utils/encrypt_decrypt_tools');
const {validateCookieExist ,validateAdminRoute,validateDpmRoute,validateMember,accessCookieExist} = require('../middleware/validation_user');

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());
router.use(cookieParser());

router.get('/',accessCookieExist,function(req,res,next){
    res.render('index',{data:'index'});

});

module.exports = router;
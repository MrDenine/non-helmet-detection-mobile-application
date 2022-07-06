const express = require('express');
const router = express.Router();
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');
const axios = require('axios');
const config = require('../config');
const multer = require('multer');
const FormData = require('form-data');
const fs = require('fs');
const encrypt_decrypt_tools = require('../utils/encrypt_decrypt_tools');
const {validateCookieExist ,validateAdminRoute,validateDpmRoute,validateMember,accessCookieExist} = require('../middleware/validation_user');
const {getUserRole,getUserData} = require('../utils/initial_data_tools');
const upload = multer({ dest:'./profiles' })

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());
router.use(cookieParser());

router.get('/',function(req,res,next){
    res.render('account_management',{title : 'account_management', udt : getUserData(req) , role : getUserRole(req)});
});

router.post('/search',(req,res)=>{
    axios.get(config.servurl+'/GetDataOther/getDataUserStaticAll')
    .then(function (response) {
        // handle success
        res.send(response.data);
    })
    .catch(function (error) {
      // handle error
      res.send(error);
    })
})


module.exports = router;
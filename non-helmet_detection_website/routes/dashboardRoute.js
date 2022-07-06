const express = require('express');
const router = express.Router();
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');
const axios = require('axios');
const config = require('../config');
const encrypt_decrypt_tools = require('../utils/encrypt_decrypt_tools');
const {validateCookieExist ,validateAdminRoute,validateDpmRoute,validateMember,accessCookieExist} = require('../middleware/validation_user');
const {getUserRole,getUserData} = require('../utils/initial_data_tools');

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());
router.use(cookieParser());

router.get('/',validateCookieExist,function(req,res,next){
    if(getUserRole(req) == 2){
        res.render('dashboard_admin' ,{title : 'dashboard_users)', udt : getUserData(req) , role : getUserRole(req)});
    } else {
        res.render('dashboard_user' ,{title : 'dashboard_user', udt : getUserData(req) , role : getUserRole(req)});
    }
});

router.post('/getobjuser',function(req,res){
    axios.get(config.servurl + '/DetectedImage/getDataDetectedImage/'+ "110")
    .then(function(response){
        res.send(response.data);
        return;
    })
    .catch(function(error){
        res.send(error); 
        return;
    });
})
router.get('/getcount',function(req,res){
    axios.get(config.servurl + '/DetectedImage/getAmountRider/'+ "110")
    .then(function(response){
        res.send(response.data);
        return;
    })
    .catch(function(error){
        res.send(error); 
        return;
    });
})
router.get('/getstatistic',function(req,res){
    axios.get(config.servurl + '/GetDataOther/staticFromStatus')
    .then(function(response){
        res.send(response.data);
        return;
    })
    .catch(function(error){
        res.send(error); 
        return;
    });
})
module.exports = router;
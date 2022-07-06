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

router.get('/',function(req,res,next){
    res.render('detection_result',{title:'detection_result',udt : getUserData(req) , role : getUserRole(req)});
});

router.post('/submit',(req,res)=>{
  axios.post(config.servurl+'/ManageData/UpdateDataObj',{
    id_object : req.body.obj_id,
    id_admin : getUserData(req).id,
    status : req.body.status,
    licence_number : req.body.licence_number,
    description : req.body.description,
    datetime : req.body.datetime,
  })
  .then(function (response) {
      // handle success
      res.send(response.data);
  })
  .catch(function (error) {
    // handle error
    res.send(error);
  })
})

router.post('/search',(req,res)=>{
    axios.post(config.servurl+'/GetDataOther/getDataObjDetect',{
      search_value : req.body.search
    })
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
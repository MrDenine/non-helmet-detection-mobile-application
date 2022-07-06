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
    res.render('profile',{title : 'profile', udt : getUserData(req) , role : getUserRole(req)});
});
router.get('/getUser',function(req,res){
    axios.get(config.servurl + '/GetDataUser/'+ getUserData(req).id)
    .then(function(response){
        res.send(response.data);
        return;
    })
    .catch(function(error){
        res.send(error); 
        return;
    });
});

router.post('/postUpdateUser',function(req,res){
    var post_id = getUserData(req).id;
    var post_firstname = req.body.firstname;
    var post_lastname = req.body.lastname;
    var post_date = req.body.date;
    axios
    .post(config.servurl + '/EditProfile/PostEditProfile',{
        user_id : post_id ,
        firstname : post_firstname,
        lastname :post_lastname,
        datetime : post_date,
    })
    .then(function(response){
        res.status(200).send(response.data); 
        return;
    })
    .catch(function (error) {
        res.send(error); 
        return;
    });
});

//action => /UploadImageProfile
//post => /UploadImageProfile?post=true
//delete => /UploadImageProfile?clrimage=ce2786da9b29f4de11f942806841f14d

router.post('/UploadImageProfile',upload.single('file'),(req,res,next)=>{
    if(req.query.post){
      //request
      var post_filename = req.body.filename;
      console.log(post_filename);
      //post
      var form = new FormData();
      form.append('file',fs.readFileSync('./profiles/'+post_filename) ,getUserData(req).id +'_'+ Date.now() +'.jpg');
      form.append('user_id',getUserData(req).id)
      axios({
        method: 'post',
        url: config.servurl + '/EditProfile/uploadImageProfile',
        data: form,
        headers: {
            'Content-Type': `multipart/form-data; boundary=${form._boundary}`
        }
      })
      .then(function(response){
          res.status(200).send(response.data); 
          return;
      })
      .catch(function (error) {
          res.send(error); 
          return;
      });
    } else if(req.query.clrimage) {
      //delete
      let path = "./profiles/" + req.query.clrimage;

      //ลบรูปเก่า
      fs.unlink(path, function (err) {
        if (err) {
          console.error(err);
        } else {
          console.log("File removed:", path);
        }
      });
    }
    else{
      //action
      res.status(200).send(req.file); 
      return;
    }
})

module.exports = router;
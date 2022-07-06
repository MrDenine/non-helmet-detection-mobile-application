const express = require('express');
const router = express.Router();
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');
const config = require('../config');
const axios = require('axios');
var datetime = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
router.use(cookieParser());
router.use(bodyParser.urlencoded({extended : false}));
router.use(bodyParser.json());

router.get('/:id/:e',function(req,res,next){
    if(req.params.id){
        //post request otp by req.params.id
        axios
         .post(config.servurl + '/OTP/PostReqOTP',{
            email : req.params.e ,
            datetime : datetime,
            user_id : req.params.id,
            type : 1
         })
         .then(function(response){
            if(response.data.status == "Succeed"){
                res.render('otp',{mail:req.params.e,id:req.params.id});
            }else{
                res.status(400).send(response.data);
            }
         })
         .catch(function(error){
            res.status(400).send(response.data);
            return;
         })
    }else{
        res.status(404).send('404 not found');
        return;
    }
});

router.post('/:id/:e/verify',function(req,res,next){
    var OTP = req.body.otp;
    if(req.params.id){
        axios
        .post(config.servurl + '/OTP/PostCheckOTP',{
           otp:OTP, 
           email : req.params.e ,
           datetime : datetime,
           type : 1,
           user_id : req.params.id
        })
        .then(function(response){
            res.status(200).send(response.data);
            return;
        })
        .catch(function(error){
           res.status(400).send(response.data);
           return;
        })
    } else{
        res.status(404).send('404 not found');
        return;
    }
})

module.exports = router;
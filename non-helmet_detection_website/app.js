//Imports
const express = require('express');
const axios = require('axios');
const path = require('path');
const app = express();
const config = require('./config');
try{
    //Static File
    app.use(express.static('public'));
    app.use('/', express.static(__dirname));

    //connection service validate 
    axios.get(config.servurl)
        .then(function (res){
            //log result
            console.log('\x1b[36m%s\x1b[0m','[API] '+ res.data.data +' :D');

            //Define Routing Path
            var indexRoute = require('./routes/indexRoute');
            var loginRoute = require('./routes/loginRoute'); 
            var registerRoute = require('./routes/registrationRoute')
            var otpRoute = require('./routes/otpRoute');
            var forgotPasswordRoute = require('./routes/forgotPasswordRoute');
            var dashboardRoute = require('./routes/dashboardRoute');
            var detectionResultRoute = require('./routes/detectionResultRoute');
            var reportRoute = require('./routes/reportRoute');
            var profileRoute = require('./routes/profileRoute');
            var accountRoute = require('./routes/accountRoute');

            //Static Routes File
            app.use('/',indexRoute);
            app.use('/login',loginRoute);
            app.use('/register',registerRoute);
            app.use('/otp',otpRoute);
            app.use('/forgotPassword',forgotPasswordRoute);
            app.use('/dashboard',dashboardRoute);
            app.use('/detection-result',detectionResultRoute);
            app.use('/report',reportRoute);
            app.use('/profile',profileRoute);
            app.use('/useraccount',accountRoute);
            //Set Views engine
            //app.set('views', './views');
            app.set('views',[
                path.join(__dirname,'views'),
                path.join(__dirname,'views/page')
            ]);
            app.set('view engine' , 'ejs');

            //Listen on port 3000
            app.listen(config.port,()=> console.info(`[SERVER] Listening on port ${config.port}`));
        })
        .catch(function (err){
            app.get('/',function(req,res){
                res.status(404);
            })
            console.log(err);
            process.exit(1);
        });

    module.exports = app;
}catch (e){
    console.log('\x1b[36m%s\x1b[0m','Exception:'+ e)
}

const config = {};

config.port = 8000; //website port
config.servurl = 'http://128.199.96.80:5000'; //service url/port
config.weburl = 'http://localhost:8000/';
config.cookie_options = {
    maxAge: 86400 * 1000, // 24 hours
    httpOnly: true, // http only, prevents JavaScript cookie access
    secure: true, // cookie must be sent over https / ssl
    path:"/"
}
config.cookie_test = {
    maxAge: 60 * 1000, // 1 minute
    httpOnly: true, // http only, prevents JavaScript cookie access
    secure: true, // cookie must be sent over https / ssl
    path:"/"
}

module.exports = config;
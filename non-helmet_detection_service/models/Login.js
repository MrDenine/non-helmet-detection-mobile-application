const db = require("../dbconnection");

var Login = {
  checkPassword: function (email, callback) {
    //console.log(username);
    return db.query(
      `SELECT password FROM db_project."users" where email = $1 AND active = 1 AND is_verified = 1`,
      [email],
      callback
    );
  },

  getIdUser: function (email, hashPW, callback) {
    return db.query(
      `SELECT id FROM db_project."users" 
      WHERE email = $1 AND password = $2 AND active = 1 AND is_verified = 1`,
      [email, hashPW],
      callback
    );
  },
};
module.exports = Login;

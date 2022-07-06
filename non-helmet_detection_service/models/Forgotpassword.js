const db = require("../dbconnection");

var ForgotPW = {
  updatePassword: function (new_hashPW, data, callback) {
    let datetime = data.datetime;
    let email = data.email;
    return db.query(
      `UPDATE db_project."users"
      SET password = $1, update_at = $2
      WHERE email = $3 AND active = 1 AND is_verified = 1`,
      [new_hashPW, datetime, email],
      callback
    );
  },
};
module.exports = ForgotPW;

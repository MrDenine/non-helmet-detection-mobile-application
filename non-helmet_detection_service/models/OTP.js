const db = require("../dbconnection");

var GetDataUser = {
  getcheckEmail: function (email, callback) {
    return db.query(
      `SELECT id FROM db_project."users" WHERE email = $1 AND active = 1 AND is_verified = 1`,
      [email],
      callback
    );
  },
  insertOTP: function (user_id, data, otp, callback) {
    let datetime = data.datetime;
    return db.query(
      `UPDATE db_project."users" SET otp = $1, update_at = $2 WHERE id = $3 AND active = 1`,
      [otp, datetime, user_id],
      callback
    );
  },
  getDataOTP: function (user_id, otp, callback) {
    return db.query(
      `SELECT update_at + (interval '5 minute') AS datetimeotp FROM db_project."users" 
      WHERE id = $1 AND otp = $2 AND active = 1`,
      [user_id, otp],
      callback
    );
  },
  setActiveAc: function (user_id, data, callback) {
    let datetime = data.datetime;
    return db.query(
      `UPDATE db_project."users"
      SET otp = null, update_at = $1, is_verified = 1
      WHERE id = $2 AND active = 1`,
      [datetime, user_id],
      callback
    );
  },
};
module.exports = GetDataUser;

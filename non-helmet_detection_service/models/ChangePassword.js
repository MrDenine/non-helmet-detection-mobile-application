const db = require("../dbconnection");

var ChangePW = {
  checkPassword: function (user_id, callback) {
    //console.log(username);
    return db.query(
      `SELECT password FROM db_project."users" where id = $1 AND active = 1 AND is_verified = 1`,
      [user_id],
      callback
    );
  },

  updatePassword: function (user_id, new_hashPW, data, callback) {
    let datetime = data.datetime;
    return db.query(
      `UPDATE db_project."users"
      SET password = $1, update_at = $2
      WHERE id = $3 AND active = 1 AND is_verified = 1`,
      [new_hashPW, datetime, user_id],
      callback
    );
  },
};
module.exports = ChangePW;

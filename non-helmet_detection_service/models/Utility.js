const db = require("../dbconnection");

var UtilityDB = {
  getcheckEmail: function (email, callback) {
    return db.query(
      `SELECT id, is_verified FROM db_project."users" WHERE email = $1 AND active = 1`,
      [email],
      callback
    );
  },
};
module.exports = UtilityDB;

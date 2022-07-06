const db = require("../dbconnection");

var GetDataUser = {
  getdataUser: function (user_id, callback) {
    return db.query(
      `SELECT email, firstname, lastname, image_profile, role FROM db_project."users" 
      WHERE id = $1 AND active = 1 AND is_verified = 1`,
      [user_id],
      callback
    );
  },
};
module.exports = GetDataUser;

const db = require("../dbconnection");

var EditProfile = {
  updateProfile: function (data, callback) {
    let user_id = data.user_id;
    let firstname = data.firstname;
    let lastname = data.lastname;
    let datetime = data.datetime;
    return db.query(
      `UPDATE db_project."users"
      SET firstname = $1, lastname = $2, update_at = $3
      WHERE id = $4 AND active = 1 AND is_verified = 1`,
      [firstname, lastname, datetime, user_id],
      callback
    );
  },

  updateImage: function (image_profile, user_id, callback) {
    return db.query(
      `UPDATE db_project."users"
      SET image_profile = $1
      WHERE id = $2 AND active = 1 AND is_verified = 1`,
      [image_profile, user_id],
      callback
    );
  },
};
module.exports = EditProfile;

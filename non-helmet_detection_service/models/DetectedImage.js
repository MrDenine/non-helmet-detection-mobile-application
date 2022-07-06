const db = require("../dbconnection");

var UploadDetectedImage = {
  insertDataDetectedImg: function (data, text_license, filename, callback) {
    let user_id = data.user_id;
    let datetime = data.datetime;
    let latitude = data.latitude;
    let longitude = data.longitude;
    let detection_at = data.detection_at;
    return db.query(
      `INSERT INTO db_project.object_detection(
        request_user, image_detection, licence_number, latitude, longitude, detection_at, status, active, create_at, update_by, update_at)
        VALUES ($1, $2, $3, $4, $5, $6, 10, 1, $7, $8, $9)`,
      [
        user_id,
        filename,
        text_license,
        latitude,
        longitude,
        detection_at,
        datetime,
        user_id,
        datetime,
      ],
      callback
    );
  },

  getAmountRider: function (callback) {
    return db.query(
      `SELECT request_user, detection_at, create_at, update_at FROM db_project.object_detection WHERE active = 1`,
      callback
    );
  },

  getDataDetectedImage: function (user_id, callback) {
    return db.query(
      `SELECT id, image_detection, latitude, longitude, detection_at, status, active, update_at
      FROM db_project.object_detection
      WHERE request_user = $1 AND active = 1 ORDER BY update_at DESC`,
      [user_id],
      callback
    );
  },
};
module.exports = UploadDetectedImage;

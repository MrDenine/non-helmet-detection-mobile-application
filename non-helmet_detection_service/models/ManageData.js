const db = require("../dbconnection");

var ManageData = {
  updateDataObj: function (data, callback) {
    return db.query(
      `UPDATE db_project.object_detection
      SET licence_number = $1, status = $2, update_by = $3, update_at = $4
      WHERE id = $5 AND active = 1`,
      [
        data.licence_number,
        data.status,
        data.id_admin,
        data.datetime,
        data.id_object,
      ],
      callback
    );
  },

  insertDataReport: function (data, callback) {
    return db.query(
      `INSERT INTO db_project.report(request_object_detection, approve_by, description, active, create_at, update_at)
      VALUES ($1, $2, $3, 1, $4, $5)`,
      [
        data.id_object,
        data.id_admin,
        data.description,
        data.datetime,
        data.datetime,
      ],
      callback
    );
  },

  delDataDetected: function (data, callback) {
    return db.query(
      `UPDATE db_project.object_detection
      SET active = 0, update_by = $1, update_at = $2
      WHERE id = $3 AND active = 1`,
      [data.id_admin, data.datetime, data.id_object],
      callback
    );
  },
};
module.exports = ManageData;

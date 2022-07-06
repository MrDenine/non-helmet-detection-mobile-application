const db = require("../dbconnection");

var Register = {
  postdataUser: function (data, password, callback) {
    let email = data.email;
    let firstname = data.firstname;
    let lastname = data.lastname;
    let role = data.role;
    let datetime = data.datetime;
    return db.query(
      `INSERT INTO db_project."users"(
        email, firstname, lastname, password, role, active, create_at, update_at, is_verified)
        VALUES ($1, $2, $3, $4, $5, 1, $6, $7, 0) RETURNING id AS user_id`,
      [email, firstname, lastname, password, role, datetime, datetime],
      callback
    );
  },
};
module.exports = Register;

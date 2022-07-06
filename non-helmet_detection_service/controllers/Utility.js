const UtilityDB = require("../models/Utility");

exports.getcheckEmail = (email) => {
  return new Promise((resolve, reject) => {
    try {
      UtilityDB.getcheckEmail(email, (err, rows) => {
        if (rows != null) {
          resolve(rows.rows);
        } else {
          resolve(null);
        }
      });
    } catch (err) {
      console.log(err);
      resolve(null);
    }
  });
};



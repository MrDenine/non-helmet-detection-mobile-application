const express = require("express");
const router = express.Router();
const GetDataUser = require("../models/GetDataUser");

router.get("/:user_id?", async function (req, res, next) {
  let user_id = req.params.user_id;
  let getdata = await getdataUser(user_id);
  if (getdata != null) {
    res.json({ status: "Succeed", data: getdata });
  } else res.json({ status: "Failed", data: "Error Code" });
});

async function getdataUser(user_id) {
  return new Promise((resolve, reject) => {
    try {
      GetDataUser.getdataUser(user_id, (err, rows) => {
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
}

module.exports = router;

const express = require("express");
const bcrypt = require("bcrypt");
const router = express.Router();
const ChangePW = require("../models/ChangePassword");

router.post("/PostChangePW", async function (req, res, next) {
  var current_password = req.body.current_password;
  var new_password = req.body.new_password;
  var user_id = req.body.user_id;
  let checkPW = await checkPassword(user_id); //เช็ครหัสผ่าน
  if (checkPW != false) {
    let hashPW = checkPW[0].password; //รหัสผ่านใน DB
    const match = await bcrypt.compare(current_password, hashPW); //เปรียบเทียบรหัสผ่าน
    if (match) {
      let new_hashPW = await bcrypt.hash(new_password, 10);
      let result = await updatePassword(user_id, new_hashPW, req.body); //อัปเดตรหัสผ่าน
      if (result) {
        res.json({ status: "Succeed", data: "Succeed" });
      } else {
        res.json({ status: "Failed", data: "Error Update password fail" });
      }
    } else res.json({ status: "Failed", data: "Incorrect password" });
  } else res.json({ status: "Failed", data: "Error Check password fail" });
});

async function checkPassword(user_id) {
  return new Promise((resolve, reject) => {
    try {
      ChangePW.checkPassword(user_id, (err, rows) => {
        if (rows != null) {
          resolve(rows.rows);
        } else {
          resolve(false);
        }
      });
    } catch (err) {
      console.log(err);
      resolve(false);
    }
  });
}

async function updatePassword(user_id, new_hashPW, data) {
  return new Promise((resolve, reject) => {
    try {
      ChangePW.updatePassword(user_id, new_hashPW, data, (err, rows) => {
        if (err) {
          console.log(err);
          resolve(false);
        } else {
          resolve(true);
        }
      });
    } catch (err) {
      console.log(err);
      resolve(false);
    }
  });
}

module.exports = router;

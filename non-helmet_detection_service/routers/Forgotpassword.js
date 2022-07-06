const express = require("express");
const router = express.Router();
var nodemailer = require("nodemailer");
const Register = require("../models/Register");
const ForgotPW = require("../models/Forgotpassword");
const bcrypt = require("bcrypt");

router.post("/PostCreatePW", async function (req, res, next) {
  var new_password = req.body.new_password;

  let new_hashPW = await bcrypt.hash(new_password, 10);
  let result = await updatePassword(new_hashPW, req.body); //อัปเดตรหัสผ่าน
  if (result) {
    res.json({ status: "Succeed", data: "Succeed" });
  } else {
    res.json({ status: "Failed", data: "Error Update password fail" });
  }
});

async function updatePassword(new_hashPW, data) {
  return new Promise((resolve, reject) => {
    try {
      ForgotPW.updatePassword(new_hashPW, data, (err, rows) => {
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

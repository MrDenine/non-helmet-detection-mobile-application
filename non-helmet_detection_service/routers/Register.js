const express = require("express");
const bcrypt = require("bcrypt");
const router = express.Router();
const Register = require("../models/Register");
const Utility = require("../controllers/Utility");

router.post("/PostRegister", async function (req, res, next) {
  let email = req.body.email;

  let checkEmail = await Utility.getcheckEmail(email); //เช็คอีเมล

  //เช็คว่าอีเมลซ้ำไหม
  if (checkEmail.length > 0) {
    if (checkEmail[0].is_verified == 1) {
      res.json({ status: "Failed", data: "Duplicate_Email" });
    } else {
      res.json({
        status: "Failed",
        data: "Email is not verified",
        userID: checkEmail[0].id,
      });
    }
  } else {
    //เข้ารหัสผ่าน
    let hashPW = await bcrypt.hash(req.body.password, 10);
    let regisStatus = await postdataUser(req.body, hashPW);
    console.log(regisStatus[0].user_id);
    if (regisStatus != false) {
      res.json({ status: "Succeed", data: regisStatus });
    } else {
      res.json({ status: "Failed", data: "RegisError" });
    }
  }
});

async function postdataUser(data, password) {
  return new Promise((resolve, reject) => {
    try {
      Register.postdataUser(data, password, (err, rows) => {
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

module.exports = router;

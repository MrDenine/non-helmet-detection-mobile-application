const express = require("express");
const bcrypt = require("bcrypt");
const router = express.Router();
const Login = require("../models/Login");
const Utility = require("../controllers/Utility");

router.post("/PostLogin", async function (req, res, next) {
  var email = req.body.email;
  var password = req.body.password;

  if (email === null || !email) {
    res.json({ status: "Failed", data: "Please enter Username" });
  } else if (password === null || !password) {
    res.json({ status: "Failed", data: "Please enter password" });
  } else {
    let checkEmail = await Utility.getcheckEmail(email); //เช็คอีเมล
    if (checkEmail.length > 0 && checkEmail != null) {
      if (checkEmail[0].is_verified == 1) {
        let checkPW = await checkPassword(email); //เช็ครหัสผ่าน
        if (checkPW != false) {
          let hashPW = checkPW[0].password; //รหัสผ่านใน DB
          const match = await bcrypt.compare(password, hashPW); //เปรียบเทียบรหัสผ่าน
          if (match) {
            let userID = await getIdUser(email, hashPW); //ดึงไอดีผู้ใช้
            if (userID != false) {
              res.json({ status: "Succeed", data: userID });
            } else res.json({ status: "Failed", data: "Error Get id user" });
          } else res.json({ status: "Failed", data: "Incorrect password" });
        } else
          res.json({ status: "Failed", data: "Error Check password fail" });
      } else {
        res.json({
          status: "Failed",
          data: "Email is not verified",
          userID: checkEmail[0].id,
        });
      }
    } else {
      res.json({ status: "Failed", data: "Invalid email" });
    }
  }
});

async function checkPassword(email) {
  return new Promise((resolve, reject) => {
    try {
      Login.checkPassword(email, (err, rows) => {
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

async function getIdUser(email, hashPW) {
  return new Promise((resolve, reject) => {
    try {
      Login.getIdUser(email, hashPW, (err, rows) => {
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

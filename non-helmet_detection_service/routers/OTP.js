const express = require("express");
const router = express.Router();
var nodemailer = require("nodemailer");
const OTPmodels = require("../models/OTP");
const Utility = require("../controllers/Utility");

router.post("/PostReqOTP", async function (req, res, next) {
  var email = req.body.email;
  var type = req.body.type; // 1 = register, 2 = forgot password
  var user_id;
  var checkEmail;

  if (type == 1) {
    user_id = req.body.user_id;
  } else {
    checkEmail = await Utility.getcheckEmail(email);
    if (checkEmail.length > 0) {
      if (checkEmail[0].is_verified == 1) {
        user_id = checkEmail[0].id; //กรณีมีอีเมลในระบบและยืนยันแล้ว
      } else {
        user_id = -1; //กรณีมีอีเมลในระบบแต่ยังไม่ยืนยันแล้ว
      }
    } else {
      user_id = 0; //กรณีไม่มีอีเมลในระบบ
    }
  }

  if (user_id != 0 && user_id != -1) {
    var otp = Math.floor(100000 + Math.random() * 900000).toString();

    var transporter = nodemailer.createTransport({
      host: "gmail",
      service: "Gmail",
      // port: 587,
      // secure: false,
      // requireTLS: true,
      auth: {
        user: "non.helmet@gmail.com",
        pass: "Nonhelmet116110",
      },
    });

    var mailOptions = {
      from: "None Helmet Detection <non.helmet@gmail.com>",
      to: email,
      subject:
        type == 1
          ? "รหัส OTP สำหรับยืนยันบัญชีผู้ใช้"
          : "รหัส OTP สำหรับสร้างรหัสผ่านใหม่",
      text: otp,
    };

    let statusOTP = await insertOTP(user_id, req.body, otp);
    if (statusOTP) {
      transporter.sendMail(mailOptions, function (error, info) {
        if (error) {
          console.log(error);
          res.json({ status: "Failed", data: "Error" });
        } else {
          console.log("Email sent: " + info.response);
          res.json({ status: "Succeed", data: otp });
        }
      });
    } else {
      res.json({ status: "Failed", data: "Insert OTP Fail" });
    }
  } else if (user_id == 0) {
    res.json({ status: "Failed", data: "Invalid email" });
  } else {
    res.json({
      status: "Failed",
      data: "Email is not verified",
      userID: checkEmail[0].id,
    });
  }
});

router.post("/PostCheckOTP", async function (req, res, next) {
  var email = req.body.email;
  var type = req.body.type;
  var user_id;

  if (type == 1) {
    user_id = req.body.user_id;
  } else {
    let checkEmail = await Utility.getcheckEmail(email);
    if (checkEmail.length > 0) {
      if (checkEmail[0].is_verified == 1) {
        user_id = checkEmail[0].id; //กรณีมีอีเมลในระบบและยืนยันแล้ว
      } else {
        user_id = -1; //กรณีมีอีเมลในระบบแต่ยังไม่ยืนยันแล้ว
      }
    } else {
      user_id = 0; //กรณีไม่มีอีเมลในระบบ
    }
  }

  if (user_id != 0 && user_id != -1) {
    var otp = req.body.otp;
    var datetime = new Date(req.body.datetime).getTime();
    if (otp == null || !otp) {
      res.json({ status: "Failed", data: "Empty OTP" });
    } else {
      let dataOTP = await getDataOTP(user_id, otp);
      if (dataOTP == "" || dataOTP == false) {
        res.json({ status: "Failed", data: "Invalid OTP" });
      } else {
        let datetimeDB = new Date(dataOTP[0].datetimeotp).getTime();
        if (datetimeDB >= datetime) {
          let statusSetAc = await setActiveAc(user_id, req.body);
          if (statusSetAc) {
            res.json({ status: "Succeed", data: "Succeed" });
          } else {
            res.json({ status: "Failed", data: "Set User Fail" });
          }
        } else {
          res.json({ status: "Failed", data: "Over time OTP" });
        }
      }
    }
  } else {
    res.json({ status: "Failed", data: "Error" });
  }
});

async function insertOTP(user_id, data, otp) {
  return new Promise((resolve, reject) => {
    try {
      OTPmodels.insertOTP(user_id, data, otp, (err, rows) => {
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

async function getDataOTP(user_id, otp) {
  return new Promise((resolve, reject) => {
    try {
      OTPmodels.getDataOTP(user_id, otp, (err, rows) => {
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

async function setActiveAc(user_id, data) {
  return new Promise((resolve, reject) => {
    try {
      OTPmodels.setActiveAc(user_id, data, (err, rows) => {
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

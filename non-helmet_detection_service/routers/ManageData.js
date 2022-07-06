const express = require("express");
const router = express.Router();
const ManageData = require("../models/ManageData");

//อัปเดตข้อมูลตาราง object_detection
router.post("/UpdateDataObj", async function (req, res, next) {
  let updateData = await updateDataObj(req.body);
  if (updateData) {
    //insert ไปยังตารางรายงาน
    let insertReport = await insertDataReport(req.body);
    if (insertReport) {
      res.json({ status: "Succeed", data: "Update successfully" });
    } else {
      res.json({ status: "Failed", data: "Update failed" });
    }
  } else res.json({ status: "Failed", data: "Update failed" });
});

//ลบข้อมูลภาพตรวจจับ โดย Set active = 0
router.post("/DeleteDataDetected", async function (req, res, next) {
  let statusDel = await delDataDetected(req.body);
  if (statusDel) {
    res.json({ status: "Succeed", data: "Delete data successfully" });
  } else {
    res.json({ status: "Failed", data: "Delete failed" });
  }
});

async function updateDataObj(data) {
  return new Promise((resolve, reject) => {
    try {
      ManageData.updateDataObj(data, (err, rows) => {
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

async function insertDataReport(data) {
  return new Promise((resolve, reject) => {
    try {
      ManageData.insertDataReport(data, (err, rows) => {
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

async function delDataDetected(data) {
  return new Promise((resolve, reject) => {
    try {
      ManageData.delDataDetected(data, (err, rows) => {
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

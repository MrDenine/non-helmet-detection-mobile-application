const express = require("express");
const router = express.Router();
const EditProfile = require("../models/EditProfile");
const multer = require("multer");
const fs = require("fs");

router.post("/PostEditProfile", async function (req, res, next) {
  let editprofile = await updateProfile(req.body);
  if (editprofile) {
    res.json({ status: "Succeed", data: "Succeed" });
  } else {
    res.json({ status: "Failed", data: "Error EditProfile fail" });
  }
});

router.post("/uploadImageProfile", async function (req, res, next) {
  let storageUploadFile = multer.diskStorage({
    destination: (req, file, cb) => {
      const DIR = `././uploads/profiles`;
      fs.exists(DIR, (exist) => {
        if (!exist) {
          return fs.mkdir(DIR, (error) => cb(error, DIR));
        } else {
          return cb(null, DIR);
        }
      });
      // cb(null, DIR);
    },
    filename: function (req, file, cb) {
      const fileName = file.originalname;
      cb(null, fileName);
    },
  });

  let UploadFile = multer({ storage: storageUploadFile }).single("file");

  UploadFile(req, res, async function (err) {
    if (err instanceof multer.MulterError) {
      return res.status(500).json(err);
    } else if (err) {
      return res.status(500).json(err);
    }

    if (req.file != undefined) {
      EditProfile.updateImage(
        req.file.filename,
        Number(req.file.originalname.split("_")[0]),
        (err, rows) => {
          if (err) {
            res.json({ status: "Failed", data: "update data Image fail" });
          } else {
            res.json({ status: "Succeed", data: "Succeed" });
          }
        }
      );
    } else {
      res.json({ status: "Failed", data: "undefined file" });
    }
  });
});

async function updateProfile(data) {
  return new Promise((resolve, reject) => {
    try {
      EditProfile.updateProfile(data, (err, rows) => {
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

import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';

///typeProcess 1 = register, 2 = ยืนยันตัวตน
Future<void> reqOTP(
    BuildContext context, int user_id, String email, int typeProcess) async {
  try {
    var result = await req_OTP({
      "user_id": user_id,
      "email": email,
      "type": 1,
      "datetime": DateTime.now().toString()
    });
    if (result.pass) {
      Navigator.of(context, rootNavigator: true).pop();
      if (result.data["status"] == "Succeed") {
        dialogInputOTP(context, user_id, email, typeProcess);
      } else if (result.data["data"] == "Invalid email") {
        normalDialog(context, "ไม่มีอีเมลนี้ในระบบ");
      } else {
        normalDialog(context, "บันทึกไม่สำเร็จ");
      }
    }
  } catch (e) {}
}

///typeProcess 1 = register, 2 = forgot password, 3 = Login
Future<void> checkOTP(BuildContext context, int user_id, String email,
    String otpUser, int typeProcess) async {
  ShowloadDialog().showLoading(context);
  try {
    if (otpUser != "") {
      var result = await check_OTP({
        "otp": otpUser,
        "user_id": user_id,
        "email": email,
        "type": 1,
        "datetime": DateTime.now().toString()
      });
      if (result.pass) {
        Navigator.of(context, rootNavigator: true).pop();
        if (result.data["status"] == "Succeed") {
          if (typeProcess == 1) {
            succeedDialog(context, "ลงทะเบียนสำเร็จ", SplashPage());
          } else {
            succeedDialog(context, "ยืนยันตัวตนสำเร็จ", SplashPage());
          }
        } else if (result.data["data"] == "Invalid OTP") {
          normalDialog(context, "รหัส OTP ไม่ถูกต้อง");
        } else {
          normalDialog(context, "รหัส OTP หมดอายุ\nกรุณาขอ OTP ใหม่อีกครั้ง");
        }
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      normalDialog(context, "กรุณากรอก OTP");
    }
  } catch (e) {}
}

///typeProcess 1 = register, 2 = forgot password, 3 = Login
dialogInputOTP(
    BuildContext context, int user_id, String email, int typeProcess) {
  String otpUser = "";
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SimpleDialog(
      title: const Text(
        'กรุณากรอก OTP ที่ได้รับจากอีเมลของคุณภายใน 5 นาที',
        style: TextStyle(
          fontSize: 15,
        ),
      ),
      children: <Widget>[
        SingleChildScrollView(
            child: Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'รหัส OTP',
                labelStyle:
                    TextStyle(fontSize: 18, color: Colors.grey.shade600),
                fillColor: Colors.white,
                errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.grey,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              onChanged: (value) {
                otpUser = value;
              },
            ),
          ),
          TextButton(
            child: const Text('ขอ OTP อีกครั้ง',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            style: TextButton.styleFrom(fixedSize: const Size.fromHeight(10)),
            onPressed: () {
              ShowloadDialog().showLoading(context);
              reqOTP(context, user_id, email, typeProcess);
            },
          ),
        ])),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              child: ElevatedButton(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: const Text(
                    'ตกลง',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                onPressed: () {
                  checkOTP(context, user_id, email, otpUser, typeProcess);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey.shade300,
                ),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(2, 10, 2, 10),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                onPressed: () {
                  otpUser = "";
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        )
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:non_helmet_mobile/models/profile.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late String newPassword;
  bool _isObscure = true;
  bool _showpass = false;
  String otpUser = "";
  final formKey = GlobalKey<FormState>();
  Profile profiles = Profile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'ลืมรหัสผ่าน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          //textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "กรุณากรอกอีเมลเพื่อยืนยันตัวตน\n\t\tสำหรับการสร้างรหัสผ่านใหม่",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 20,
                            ),
                            buildEmail(),
                            const SizedBox(
                              height: 15,
                            ),
                            reqOTPbt(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'อีเมลผู้ใช้',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
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
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกอีเมล"),
        FormBuilderValidators.email(context, errorText: "รูปแบบอีเมลไม่ถูกต้อง")
      ]),
      onSaved: (value) {
        profiles.email = value!;
      },
    );
  }

  Widget reqOTPbt() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.amber.shade400,
        // border: Border.all(color: Colors.amber),
      ),
      child: MaterialButton(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'ขอ OTP',
          style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          formKey.currentState!.save();
          if (formKey.currentState!.validate()) {
            _reqOTP();
          }
        },
      ),
    );
  }

  Future<void> _reqOTP() async {
    ShowloadDialog().showLoading(context);
    try {
      var result = await req_OTP({
        "user_id": 0,
        "email": profiles.email,
        "type": 2,
        "datetime": DateTime.now().toString()
      });
      if (result.pass) {
        Navigator.of(context, rootNavigator: true).pop();
        if (result.data["status"] == "Succeed") {
          dialogInputOTP();
        } else if (result.data["data"] == "Invalid email") {
          normalDialog(context, "ไม่มีอีเมลนี้ในระบบ");
        } else if (result.data["data"] == "Email is not verified") {
          dialogComfirmOTP(context, result.data["userID"], profiles.email!,
              "มีอีเมลนี้ในระบบแล้ว\tแต่ไม่ได้ยืนยันตัวตน\nต้องการยืนยันตัวตนหรือไม่");
        } else {
          normalDialog(context, "บันทึกไม่สำเร็จ");
        }
      }
    } catch (e) {}
  }

  Future<void> _checkOTP() async {
    ShowloadDialog().showLoading(context);
    try {
      if (otpUser != "") {
        var result = await check_OTP({
          "otp": otpUser,
          "user_id": 0,
          "email": profiles.email,
          "type": 2,
          "datetime": DateTime.now().toString()
        });
        if (result.pass) {
          Navigator.of(context, rootNavigator: true).pop();
          if (result.data["status"] == "Succeed") {
            dialogCreatePW();
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

  dialogInputOTP() {
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
                _reqOTP();
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  onPressed: () {
                    _checkOTP();
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

  dialogCreatePW() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'สร้างรหัสผ่านใหม่',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              actions: [
                Column(
                  children: [
                    SingleChildScrollView(
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                TextFormField(
                                  obscureText: _isObscure,
                                  keyboardType: TextInputType.visiblePassword,
                                  style: const TextStyle(fontSize: 18),
                                  decoration: InputDecoration(
                                    labelText: 'รหัสผ่านใหม่',
                                    labelStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600),
                                    fillColor: Colors.white,
                                    errorStyle: const TextStyle(
                                        color: Colors.red, fontSize: 14),
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
                                    profiles.password = value;
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  obscureText: _isObscure,
                                  keyboardType: TextInputType.visiblePassword,
                                  style: const TextStyle(fontSize: 18),
                                  decoration: InputDecoration(
                                    labelText: 'ยืนยันรหัสผ่าน',
                                    labelStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600),
                                    fillColor: Colors.white,
                                    errorStyle: const TextStyle(
                                        color: Colors.red, fontSize: 14),
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
                                    newPassword = value;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 20.0,
                                  child: Row(
                                    children: <Widget>[
                                      Checkbox(
                                        value: _showpass,
                                        //checkColor: Colors.white,
                                        //activeColor: Colors.black,
                                        onChanged: (value) {
                                          setState(() {
                                            _showpass = value!;
                                            _isObscure = !_isObscure;
                                          });
                                        },
                                      ),
                                      const Text(
                                        'แสดงรหัสผ่าน',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ))),
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            onPressed: () {
                              if (profiles.password == newPassword) {
                                createPW();
                              } else {
                                normalDialog(context, "รหัสผ่านไม่ตรงกัน");
                              }
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            onPressed: () {
                              otpUser = "";
                              int count = 0;
                              Navigator.popUntil(context, (route) {
                                return count++ == 2;
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            );
          });
        });
  }

  Future<void> createPW() async {
    ShowloadDialog().showLoading(context);
    DateTime now = DateTime.now();

    try {
      var result = await ForgotPW_CreatePW({
        "email": profiles.email,
        "new_password": newPassword,
        "datetime": now.toString(),
      });
      if (result.pass) {
        Navigator.of(context, rootNavigator: true).pop();
        if (result.data["data"] == "Succeed") {
          succeedDialog(context, "สร้างรหัสผ่านใหม่สำเร็จ", SplashPage());
        } else {
          normalDialog(context, "สร้างรหัสผ่านใหม่ไม่สำเร็จ");
        }
      }
    } catch (e) {}
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:non_helmet_mobile/models/profile.dart';
import 'package:non_helmet_mobile/models/setting_camera_modetl.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/forgot_password.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/pages/register_page.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login_Page extends StatefulWidget {
  Login_Page({Key? key}) : super(key: key);

  @override
  _Login_PageState createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  bool _isObscure = true;
  final formKey = GlobalKey<FormState>();
  Profile profiles = Profile();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
            child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 80),
                Image.asset(
                  'assets/images/logo.png',
                  scale: 7,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "None Helmet",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Detection",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: Colors.grey.shade300,
                  ),
                  child: Column(
                    children: <Widget>[
                      buildInputEmail(),
                      const SizedBox(
                        height: 20,
                      ),
                      buildInputPassword(),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      buildForgetPasswordBtn(),
                      const SizedBox(
                        height: 20,
                      ),
                      buildSigninBtn(),
                      const SizedBox(
                        height: 50,
                      ),
                      buildSignupBtn()
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget buildInputEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'อีเมลผู้ใช้',
        prefixIcon: const Icon(Icons.person),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
        fillColor: Colors.white,
        filled: true,
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 15,
        ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
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

  Widget buildInputPassword() {
    return TextFormField(
      obscureText: _isObscure,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: 'รหัสผ่าน',
        prefixIcon: const Icon(Icons.vpn_key),
        suffixIcon: IconButton(
          onPressed: () {
            setState(
              () {
                _isObscure = !_isObscure;
              },
            );
          },
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
        fillColor: Colors.white,
        filled: true,
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 15,
        ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกรหัสผ่าน"),
      ]),
      onSaved: (value) {
        profiles.password = value!;
      },
    );
  }

  Widget buildForgetPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: MaterialButton(
        height: 20,
        child: Text(
          "ลืมรหัสผ่าน?",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPassword()),
          );
        },
      ),
    );
  }

  Widget buildSignupBtn() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: MaterialButton(
        height: 20,
        child: const Text(
          "ลงทะเบียนผู้ใช้",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
          );
        },
      ),
    );
  }

  Widget buildSigninBtn() {
    return Row(children: <Widget>[
      Expanded(
        child: MaterialButton(
          height: 45,
          highlightColor: Colors.red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          color: Colors.amber,
          child: Column(
            children: const [
              Text(
                "เข้าสู่ระบบ",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 3,
              ),
            ],
          ),
          onPressed: () {
            formKey.currentState!.save();
            if (formKey.currentState!.validate()) {
              login();
            }
          },
        ),
      ),
    ]);
  }

  Future<void> login() async {
    ShowloadDialog().showLoading(context);

    try {
      var result = await postLogin(
          {"email": profiles.email, "password": profiles.password});
      if (result.pass) {
        Navigator.of(context, rootNavigator: true).pop();
        var listdata = result.data;
        if (listdata["status"] == "Succeed") {
          int user_id = listdata["data"][0]["id"];
          setUserData(user_id);
          settingList();
        } else if (listdata["data"] == "Invalid email") {
          normalDialog(context, "อีเมลหรือรหัสผ่านไม่ถูกต้อง");
        } else if (listdata["data"] == "Incorrect password") {
          normalDialog(context, "อีเมลหรือรหัสผ่านไม่ถูกต้อง");
        } else if (listdata["data"] == "Email is not verified") {
          dialogComfirmOTP(context, listdata["userID"], profiles.email!,
              "อีเมลนี้ยังไม่ได้ยืนยันตัวตน\nต้องการยืนยันตัวตนหรือไม่");
        }
      }
    } catch (e) {}
  }

  Future<void> setUserData(user_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var setId_ok = await prefs.setInt('user_id', user_id);
    var setlistFrameimg_ok = await prefs.setInt('listFrameImg', 0);
    if (setId_ok && setlistFrameimg_ok) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> settingList() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> maps =
        SettingCam("1", "true", "false", "true", "true").toJson();
    String json = jsonEncode(maps);
    prefs.setString("listSetting", json);
  }
}

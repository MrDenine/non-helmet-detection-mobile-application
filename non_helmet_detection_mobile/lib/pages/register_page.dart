import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:non_helmet_mobile/models/profile.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/login.dart';
import 'package:non_helmet_mobile/widgets/dialog_otp.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isObscure = true;
  bool _showpass = false;
  bool _acceptRegis = false;
  final formKey = GlobalKey<FormState>();
  Profile profiles = Profile();
  String otpUser = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: const [
                Text(
                  'None Helmet',
                  style: TextStyle(color: Colors.black),
                ),
                Text('Detection', style: TextStyle(color: Colors.white)),
              ],
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
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
                            const Text("ลงทะเบียนผู้ใช้",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 30,
                            ),
                            buildFirstname(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildLastname(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildEmail(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildPassword(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildConfirmPassword(),
                            const SizedBox(
                              height: 10,
                            ),
                            buildShowPassword(),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [backbt(), submitbtn()],
                            )
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

  Widget buildFirstname() {
    return TextFormField(
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'ชื่อ',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกชื่อ"),
      ]),
      onSaved: (value) {
        profiles.firstname = value!;
      },
    );
  }

  Widget buildLastname() {
    return TextFormField(
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'นามสกุล',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกนามสกุล"),
      ]),
      onSaved: (value) {
        profiles.lastname = value!;
      },
    );
  }

  Widget buildEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'อีเมล',
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

  Widget buildPassword() {
    return TextFormField(
      obscureText: _isObscure,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'รหัสผ่าน',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกรหัสผ่าน"),
        FormBuilderValidators.minLength(context, 6,
            errorText: "กรุณากรอกรหัสผ่านมากกว่า 6 ตัว")
      ]),
      onSaved: (value) {
        profiles.password = value!;
      },
    );
  }

  Widget buildConfirmPassword() {
    return TextFormField(
      obscureText: _isObscure,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'ยืนยันรหัสผ่าน',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณากรอกรหัสผ่าน';
        } else if (value != profiles.password) {
          return 'รหัสผ่านไม่ตรงกัน';
        }
        return null;
      },
    );
  }

  Widget buildShowPassword() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _showpass,
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
    );
  }

  Widget buildAcceptCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _acceptRegis,
            onChanged: (value) {
              setState(() {
                _acceptRegis = value!;
              });
            },
          ),
          const Text(
            'ยอมรับข้อตกลง',
            style: TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget backbt() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: MaterialButton(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'ย้อนกลับ',
          style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login_Page()),
          );
        },
      ),
    );
  }

  Widget submitbtn() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.amber.shade400,
      ),
      child: MaterialButton(
        child: Text(
          'ขอ OTP \n เพื่อสมัคร',
          style: TextStyle(
              fontSize: 17,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          formKey.currentState!.save();
          if (formKey.currentState!.validate()) {
            postdataUser();
          }
        },
      ),
    );
  }

  Future<void> postdataUser() async {
    ShowloadDialog().showLoading(context);
    try {
      var result = await registerUser({
        "email": profiles.email,
        "firstname": profiles.firstname,
        "lastname": profiles.lastname,
        "password": profiles.password,
        "datetime": DateTime.now().toString(),
        "role": 1
      });
      if (result.pass) {
        var listdata = result.data;
        if (listdata["status"] == "Succeed") {
          int user_id = listdata["data"][0]["user_id"];
          reqOTP(context, user_id, profiles.email!, 1);
        } else if (listdata["data"] == "Duplicate_Email") {
          Navigator.of(context, rootNavigator: true).pop();
          normalDialog(context, "มีอีเมลนี้ในระบบแล้ว");
        } else if (listdata["data"] == "Email is not verified") {
          Navigator.of(context, rootNavigator: true).pop();
          dialogComfirmOTP(context, listdata["userID"], profiles.email!,
              "มีอีเมลนี้ในระบบแล้ว\tแต่ไม่ได้ยืนยันตัวตน\nต้องการยืนยันตัวตนหรือไม่");
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          normalDialog(context, "ลงทะเบียนไม่สำเร็จ");
        }
      }
      // ignore: empty_catches
    } catch (e) {}
  }
}

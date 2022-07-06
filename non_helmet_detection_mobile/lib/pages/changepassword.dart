import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:non_helmet_mobile/models/profile.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late String newPassword;
  bool _isObscure = true;
  bool _showpass = false;
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
          'เปลี่ยนรหัสผ่าน',
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
                            buildCurrentPassword(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildNewPassword(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildConfirmPassword(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildShowPassword(),
                            const SizedBox(
                              height: 30,
                            ),
                            summitbt(),
                            const SizedBox(
                              height: 15,
                            ),
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

  Widget buildCurrentPassword() {
    return TextFormField(
      obscureText: _isObscure,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'รหัสผ่านปัจจุบัน',
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
        // FormBuilderValidators.minLength(context, 6,
        //     errorText: "กรุณากรอกรหัสผ่านมากกว่า 6 ตัว")
      ]),
      onSaved: (value) {
        profiles.password = value!;
      },
    );
  }

  Widget buildNewPassword() {
    return TextFormField(
      obscureText: _isObscure,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'รหัสผ่านใหม่',
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
        newPassword = value!;
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
        } else if (value != newPassword) {
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

  Widget summitbt() {
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
          'บันทึก',
          style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          formKey.currentState!.save();
          if (formKey.currentState!.validate()) {
            changePW();
          }
        },
      ),
    );
  }

  Future<void> changePW() async {
    ShowloadDialog().showLoading(context);
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;
    DateTime now = DateTime.now();
    if (user_id != 0) {
      var result = await postChangePW({
        "user_id": user_id,
        "current_password": profiles.password,
        "new_password": newPassword,
        "datetime": now.toString(),
      });
      try {
        if (result.pass) {
          Navigator.of(context, rootNavigator: true).pop();
          if (result.data["data"] == "Succeed") {
            succeedDialog(context, "บันทึกสำเร็จ", HomePage());
          } else if (result.data["data"] == "Incorrect password") {
            normalDialog(context, "รหัสผ่านปัจจุบันไม่ถูกต้อง");
          } else {
            normalDialog(context, "บันทึกไม่สำเร็จ");
          }
        }
      } catch (e) {}
    } else {}
  }
}

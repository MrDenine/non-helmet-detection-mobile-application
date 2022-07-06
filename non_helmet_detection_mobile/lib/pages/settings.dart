// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/changepassword.dart';
import 'package:non_helmet_mobile/pages/edit_profile.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/pages/setting_camera.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    //getData();
  }

  Future<String> getData() async {
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;

    try {
      var result = await getDataUser(user_id);
      if (result.pass) {
        var listdata = result.data["data"];
        return listdata[0]["email"];
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            //Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => HomePage()),
                (Route<dynamic> route) => false);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'ตั้งค่า',
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
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
            vertical: 24.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10.0),
              buildEmailUser(),
              const SizedBox(height: 20.0),
              buildSettingCamera(),
              const SizedBox(height: 10.0),
              buildEditProfile(),
              const SizedBox(height: 10.0),
              buildChangePw(),
              const SizedBox(height: 250.0),
              const SizedBox(height: 10.0),
              buildEmailAdmin(),
              const SizedBox(height: 20.0),
              buildLogout()
            ],
          ),
        ),
      ),
    );
  }

  //หน้าตั้งค่ากล้อง
  Widget buildSettingCamera() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingCamera()),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[300],
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: Row(
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.camera,
                  color: Colors.black,
                )),
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: const Text(
                "ตั้งค่ากล้อง",
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //แก้ไขข้อมูลส่วนตัว
  Widget buildEditProfile() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditProfile()),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[300],
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: Row(
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                )),
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: const Text(
                "แก้ไขข้อมูลส่วนตัว",
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //เปลี่ยนรหัสผ่าน
  Widget buildChangePw() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangePassword()),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[300],
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: Row(
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.lock,
                  color: Colors.black,
                )),
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: const Text(
                "เปลี่ยนรหัสผ่าน",
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //แสดงอีเมลผู้ใช้
  Widget buildEmailUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            width: double.infinity,
            child: Row(children: [
              const Text(
                'อีเมลผู้ใช้:\t',
                style: TextStyle(fontSize: 15),
              ),
              // const SizedBox(w: 10.0),
              FutureBuilder(
                future: getData(),
                //initialData: InitialData,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Column(children: [
                      Container(height: 2),
                      Text(
                        "${snapshot.data}", //แสดงอีเมลผู้ใช้งาน
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors
                              .grey.shade600, /* fontWeight: FontWeight.bold */
                        ),
                      )
                    ]);
                  } else {
                    return const Text("กรุณารอสักครู่");
                  }
                },
              ),
            ]))
      ],
    );
  }

  //แสดงอีเมลผู้พัฒนา
  Widget buildEmailAdmin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ติดต่อผู้ดูแลระบบ:',
          style: TextStyle(fontSize: 15),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 2.5),
          width: double.infinity,
          child: Text(
            "non.helmet@gmail.com",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600, /* fontWeight: FontWeight.bold */
            ),
          ),
        )
      ],
    );
  }

  //ออกจากระบบ
  Widget buildLogout() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          logout();
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.red, minimumSize: const Size(0, 45)),
        child: const Text(
          'ออกจากระบบ',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SplashPage()),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/models/data_statics.dart';
import 'package:non_helmet_mobile/modules/constant.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/capture_detection/home_screen_camera.dart';
import 'package:non_helmet_mobile/pages/edit_profile.dart';
import 'package:non_helmet_mobile/pages/settings.dart';
import 'package:non_helmet_mobile/pages/show_statistics.dart';
import 'package:non_helmet_mobile/pages/upload_Page/upload_home.dart';
import 'package:non_helmet_mobile/pages/video_page/video_main.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? countAllRider;
  int? countMeRider;
  bool? checkNewvideo;
  bool _running = true;
  double? valueWidth;
  late DataStatics dataStat;
  var dataSetting;

  @override
  void initState() {
    super.initState();
    checkInternet(context).then((value) {
      if (value == 0) {
        normalDialog(context, "กรุณาตรวจสอบอินเทอร์เน็ต");
      } else {}
    });
    permissionCamera()
        .then((value) => !value ? settingPermissionDialog(context) : null);
    getSetting();
    //getData();
  }

  getSetting() async {
    var listSetting = await getDataSetting();
    setState(() {
      dataSetting = listSetting;
    });
  }

  Future<DataStatics?> getData() async {
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;

    Directory dir = await checkDirectory("Pictures");
    List<FileSystemEntity> _photoLists = dir.listSync();
    // int numDetectedImg = 0;
    int numNotupRidertoday = 0;
    int numNotupRidertoweek = 0;
    int numNotupRidertomonth = 0;
    int numNotupRidertotal = 0;

    //คำนวณสถิติข้อมูลตรวจจับที่ผู้ใช้ไม่ยังอัปโหลด
    for (var i = 0; i < _photoLists.length; i++) {
      String userIDFromFile =
          _photoLists[i].path.split('/').last.split('_').first;

      if (user_id.toString() == userIDFromFile) {
        final tags = await readExifFromFile(_photoLists[i]);
        String dateTime = tags['EXIF DateTimeOriginal'].toString();
        DateTime dateDetect = DateTime.parse(dateTime);
        DateTime datenow = DateTime.now();
        DateTime detectToWeek =
            DateTime(dateDetect.year, dateDetect.month, dateDetect.day + 7);
        //คำนวณสถิติรายวัน
        if (DateUtils.dateOnly(dateDetect)
            .isAtSameMomentAs(DateUtils.dateOnly(datenow))) {
          numNotupRidertoday += 1;
        }
        //คำนวณสถิติรายสัปดาห์
        if (detectToWeek.isAfter(datenow)) {
          numNotupRidertoweek += 1;
        }
        //คำนวณสถิติรายเดือน
        if ((dateDetect.month == datenow.month) &&
            (dateDetect.year == datenow.year)) {
          numNotupRidertomonth += 1;
        }
        //ทั้งหมด
        numNotupRidertotal += 1;
      }
    }

    //ดึงสถิติข้อมูลตรวจจับที่ผู้ใช้อัปโหลด
    try {
      var result = await getAmountRider(user_id);
      if (result.pass) {
        if (result.data["status"] == "Succeed") {
          return DataStatics(
            numNotupRidertoday,
            numNotupRidertoweek,
            numNotupRidertomonth,
            numNotupRidertotal,
            result.data["data"]["countMeRider"]["today"],
            result.data["data"]["countMeRider"]["toweek"],
            result.data["data"]["countMeRider"]["tomonth"],
            result.data["data"]["countMeRider"]["total"],
            result.data["data"]["countAllRider"]["today"],
            result.data["data"]["countAllRider"]["toweek"],
            result.data["data"]["countAllRider"]["tomonth"],
            result.data["data"]["countAllRider"]["total"],
          );
        }
      }
    } catch (e) {
      return null;
    }
  }

  Stream<bool> showloadingVideo() async* {
    final prefs = await SharedPreferences.getInstance();
    // This loop will run forever because _running is always true
    while (_running) {
      await Future<void>.delayed(const Duration(seconds: 1));
      int listFrameImg = prefs.getInt('listFrameImg') ?? 0;
      // This will be displayed on the screen as current time
      if (listFrameImg == 0) {
        _running = false;
        yield false;
      } else {
        yield true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'None Helmet',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Detection',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                  children: <Widget>[
                    buildimageAc(EditProfile()),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              SizedBox(
                // color: Colors.amber,
                height: 190,
                child: FutureBuilder(
                    future: getData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data != null) {
                        dataStat = snapshot.data;
                        return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 3,
                            itemBuilder: (context, index) =>
                                displayStatics(index, snapshot.data));
                      } else {
                        return const Text("กรุณารอสักครู่");
                      }
                    }),
              ),
              // const Divider(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildMenuBtn(
                        1,
                        const Icon(
                          Icons.camera_alt,
                          size: 60,
                        ),
                        "ตรวจจับ"),
                    Stack(
                      children: [
                        buildMenuBtn(
                            2,
                            const Icon(
                              Icons.video_collection,
                              size: 60,
                            ),
                            "วิดีโอ"),
                        StreamBuilder(
                          stream: showloadingVideo(),
                          builder: (context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.data == true) {
                              return Positioned(
                                  child: Container(
                                color: Colors.red,
                                child: const Text(
                                  "กำลังโหลดวิดีโอใหม่",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ));
                            } else {
                              return Container();
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildMenuBtn(
                        3,
                        const Icon(
                          Icons.cloud_download,
                          size: 60,
                        ),
                        "อัปโหลด"),
                    buildMenuBtn(
                        4,
                        const Icon(
                          Icons.settings_outlined,
                          size: 60,
                        ),
                        "ตั้งค่า"),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  ///แสดงสถิติ (ส่วนหลัก)
  Widget displayStatics(int index, DataStatics data) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // is portrait
      valueWidth = MediaQuery.of(context).size.width - 70;
    } else {
      // is landscape
      valueWidth = MediaQuery.of(context).size.width / 2;
    }
    return SizedBox(
        // color: Colors.amber,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            index == 0
                ? staticsNotUpload(data)
                : index == 1
                    ? staticsRiderMe(data)
                    : staticsRiderAll(data),
          ],
        ));
  }

  ///สถิติของผู้ใช้คนนั้น กรณียังไม่อัปโหลด
  Widget staticsNotUpload(DataStatics data) {
    return Container(
        margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        width: MediaQuery.of(context).size.width - 20,
        height: 160,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(62, 73, 122, 1),
          // border: Border.all(
          //   color: Colors.black,
          // ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              // offset: Offset(0, 2),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("จำนวนรถจักรยานยนต์ที่คุณตรวจจับได้",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            const Text("(ยังไม่อัปโหลด)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 10),
            displayDataStatics("\t\tทั้งหมด", data.numNotupRidertotal),
            btnSeeMoreStat(),
            showIconNavi(0)
          ],
        ));
  }

  ///สถิติของผู้ใช้คนนั้น กรณีอัปโหลดแล้ว
  Widget staticsRiderMe(DataStatics data) {
    return Container(
        margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        width: MediaQuery.of(context).size.width - 20,
        height: 160,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(62, 73, 122, 1),
          // border: Border.all(
          //   color: Colors.black,
          // ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              // offset: Offset(0, 2),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "จำนวนรถจักรยานยนต์ที่คุณตรวจจับได้",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "(อัปโหลดแล้ว)",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // displayDataStatics("วันนี้:\t\t\t\t", data.countMeRidertoday),
            // displayDataStatics("เดือนนี้:", data.countMeRidertomonth),
            displayDataStatics("\t\tทั้งหมด", data.countMeRidertotal),
            btnSeeMoreStat(),
            showIconNavi(1)
          ],
        ));
  }

  ///สถิติของผู้ใช้ในระบบทั้งหมด
  Widget staticsRiderAll(DataStatics data) {
    return Container(
        margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        width: MediaQuery.of(context).size.width - 20,
        height: 160,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(62, 73, 122, 1),
          // border: Border.all(
          //   color: Colors.black,
          // ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              // offset: Offset(0, 2),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "จำนวนรถจักรยานยนต์ที่ถูกตรวจจับได้ในระบบ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // displayDataStatics("วันนี้:\t\t\t\t", data.countAllRidertoday),
            // displayDataStatics("เดือนนี้:", data.countAllRidertomonth),
            displayDataStatics("\t\tทั้งหมด", data.countAllRidertotal),
            btnSeeMoreStat(),
            const SizedBox(height: 10.25),
            showIconNavi(2)
          ],
        ));
  }

  ///แสดงข้อมูล รายวัน เดือน ทั้งหมด
  Widget displayDataStatics(String title, int data) {
    return Card(
        color: Colors.grey[350],
        child: SizedBox(
            width: valueWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(children: [
                  Container(
                      margin: const EdgeInsets.all(8.0),
                      height: 25.0,
                      width: 80.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        // ignore: unnecessary_const
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(data.toString()))),
                  const Text(
                    'คัน\t\t',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ])
              ],
            )));
  }

  ///ปุ่มสำหรับไปหน้าแสดงภาพรวมสถิติทั้งหมด
  Widget btnSeeMoreStat() {
    return SizedBox(
        width: valueWidth!,
        child: SizedBox(
          height: 25,
          child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowStatPage(dataStat)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber, // <-- Button color
                    // onPrimary: Colors.red, // <-- Splash color
                  ),
                  child: const Text(
                    "ดูเพิ่มเติม",
                    style: TextStyle(
                      color: Color.fromRGBO(33, 50, 94, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
        ));
  }

  //ไอคอน 3 จุดสำหรับแสดงว่าตอนนี้อยู่ tab ไหน
  Widget showIconNavi(int i) {
    return SizedBox(
        height: 1,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              return index == i
                  ? const Icon(
                      Icons.fiber_manual_record,
                      size: 15,
                      color: Colors.amber,
                    )
                  : const Icon(
                      Icons.fiber_manual_record_outlined,
                      size: 15,
                      color: Colors.white,
                    );
            }));
  }

  Widget buildMenuBtn(onPressed, icon, content) {
    return Container(
        decoration: BoxDecoration(
          //shape: BoxShape.rectangle,
          //color: Colors.amber,
          // border: Border.all(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 2),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            if (onPressed == 1) {
              int statusInternet = await checkInternet(context);
              if (dataSetting != null) {
                if (statusInternet == 0 &&
                    dataSetting["autoUpload"] == "true") {
                  normalDialog(context,
                      "ไม่สามารถใช้งานอัปโหลดอัตโนมัติได้\nกรุณาตรวจสอบอินเทอร์เน็ต");
                } else {
                  late List<CameraDescription> cameras;
                  try {
                    cameras = await availableCameras();
                  } on CameraException catch (e) {
                    cameras = [];
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(cameras)));
                }
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => onPressed == 2
                        ? VideoMain()
                        : onPressed == 3
                            ? Upload()
                            : onPressed == 4
                                ? SettingPage()
                                : HomePage()),
              );
            }
          },
          child: Column(
            children: [
              icon,
              Text(
                "$content",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            ],
          ),
          style: ElevatedButton.styleFrom(
            //shape: const CircleBorder(),
            padding: const EdgeInsets.all(25),
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            primary: Colors.amber, // <-- Button color
            // onPrimary: Colors.red, // <-- Splash color
          ),
        ));
  }

  Widget buildimageAc(onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => onTap),
        );
      },
      child: FutureBuilder(
        future: getImage(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data != null &&
              snapshot.data != "false" &&
              snapshot.data != "Error") {
            return Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
                image: DecorationImage(
                    image: NetworkImage("${snapshot.data}"), fit: BoxFit.cover),
              ),
            );
          } else if (snapshot.data == "Error") {
            return const CircleAvatar();
          } else {
            return const CircleAvatar(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<String> getImage() async {
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;

    try {
      var result = await getDataUser(user_id);
      if (result.pass) {
        var imagename = result.data["data"][0]["image_profile"];
        if (imagename != null) {
          String urlImage = "${Constant().domain}/profiles/$imagename";
          var response = await http.get(Uri.parse(urlImage));
          if (response.statusCode == 200) {
            return urlImage;
          } else {
            return "Error";
          }
        } else {
          return "Error";
        }
      } else {
        return "false";
      }
    } catch (e) {
      return "Error";
    }
  }
}

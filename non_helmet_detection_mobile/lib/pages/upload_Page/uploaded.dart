import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:non_helmet_mobile/modules/constant.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/upload_Page/google_map.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

class Uploaded extends StatelessWidget {
  Uploaded();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _MyPage(),
    );
  }
}

class _MyPage extends StatefulWidget {
  const _MyPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _MyPageState();
  }
}

class _MyPageState extends State<_MyPage> with AutomaticKeepAliveClientMixin {
  List<dynamic> listDataImg = [];
  // ใส่เพื่อเมื่อสลับหน้า(Tab) ให้ใช้ข้อมูลเดิมที่เคยโหลดแล้ว ไม่ต้องโหลดใหม่
  bool loadData = false;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();
    int user_id = prefs.getInt('user_id') ?? 0;

    try {
      var result = await getDataDetectedImage(user_id);
      if (result.pass) {
        if (result.data["status"] == "Succeed") {
          setState(() {
            if (result.data["data"].length > 0) {
              listDataImg = result.data["data"];
              listDataImg
                  .sort((a, b) => b["update_at"].compareTo(a["update_at"]));
            }
            loadData = true;
          });
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: loadData
              ? listDataImg.isNotEmpty
                  ? ListView.builder(
                      // scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: listDataImg.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildDataImage(index);
                      },
                    )
                  : const Center(
                      child: Text("ไม่มีรูปภาพ"),
                    )
              : const Center(child: CircularProgressIndicator())),
    );
  }

  Widget buildDataImage(index) {
    return GestureDetector(
        onTap: () async {
          String urlImg =
              "${Constant().domain}/detectedImage/${listDataImg[index]["image_detection"]}";
          var result = await http.get(Uri.parse(urlImg));
          if (result.statusCode == 200) {
            zoomPictureDialog(context, urlImg, 2);
          }
        },
        child: Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
                //color: Colors.amber,
                child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            FutureBuilder(
                                future: displayPicture(index),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.data != null) {
                                    return snapshot.data;
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                          ],
                        )),
                    Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("วันที่อัปโหลด",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left),
                            Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                child: Text(formatDateDatabase(
                                    listDataImg[index]["update_at"]))),
                            const Text("วันที่ตรวจจับ",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left),
                            Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: Text(formatDateDatabase(
                                    listDataImg[index]["detection_at"]))),
                            const Text("ละติจูด, ลองจิจูด",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left),
                            TextButton(
                                onPressed: () {
                                  List<double> listcoor = [];
                                  listcoor.add(listDataImg[index]["latitude"]);
                                  listcoor.add(listDataImg[index]["longitude"]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ShowMap(listcoor)),
                                  );
                                },
                                child: Text(
                                    "${listDataImg[index]["latitude"].toStringAsFixed(3)}, ${listDataImg[index]["longitude"].toStringAsFixed(3)}",
                                    style: TextStyle(color: Colors.blue[900]))),
                          ],
                        )),
                  ],
                ),
                Container(
                    margin: const EdgeInsets.only(bottom: 10, left: 10),
                    //color: Colors.red,
                    child: Row(
                      children: [
                        const Text(
                          "สถานะ : ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder(
                            future: getStatusImg(index),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.data != null) {
                                return Container(
                                    color: snapshot.data == "ยังไม่ถูกพิจารณา"
                                        ? Colors.amber.shade100
                                        : snapshot.data == "ถูกพิจารณาแล้ว"
                                            ? Colors.blue.shade100
                                            : snapshot.data ==
                                                    "ถูกดำเนินคดีแล้ว"
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                    child: Text(snapshot.data));
                              } else {
                                return const CircularProgressIndicator();
                              }
                            })
                      ],
                    )),
              ],
            ))));
  }

  Future<Widget> displayPicture(index) async {
    try {
      var url =
          "${Constant().domain}/detectedImage/${listDataImg[index]["image_detection"]}";
      var result = await http.get(Uri.parse(url));
      if (result.statusCode == 200) {
        return Image.network(
          "${Constant().domain}/detectedImage/${listDataImg[index]["image_detection"]}",
          width: 150.0,
          height: 150.0,
          //scale: 16.0,
          fit: BoxFit.contain,
        );
      } else {
        return const Text("ไม่สามารถโหลดรูปได้",
            style: TextStyle(color: Colors.black, fontSize: 12));
      }
    } catch (e) {
      return const Text("ไม่สามารถโหลดรูป",
          style: TextStyle(color: Colors.black, fontSize: 12));
    }
  }

  Future<String> getStatusImg(index) async {
    int status = listDataImg[index]["status"];
    String textStatus;
    switch (status) {
      case 10:
        textStatus = "ยังไม่ถูกพิจารณา";
        break;
      case 20:
        textStatus = "ถูกพิจารณาแล้ว";
        break;
      case 30:
        textStatus = "ถูกดำเนินคดีแล้ว";
        break;
      case 40:
        textStatus = "ไม่สามารถตรวจสอบได้";
        break;
      default:
        textStatus = "";
        break;
    }
    return textStatus;
  }
}

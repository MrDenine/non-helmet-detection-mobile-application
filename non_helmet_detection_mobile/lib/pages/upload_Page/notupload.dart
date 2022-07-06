import 'dart:io';

import 'package:dio/dio.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:non_helmet_mobile/models/file_img_video.dart';
import 'package:non_helmet_mobile/modules/constant.dart';
import 'package:non_helmet_mobile/pages/upload_Page/google_map.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotUpload extends StatelessWidget {
  NotUpload();

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
  //List<FileSystemEntity> _photoList = [];
  List<FileDetectImg> listimg = [];
  List<FileDetectImg> listSelectimg = [];
  bool selectData = false;
  bool selectAll = false; //สำหรับเลือกไฟล์ทั้งหมด
  late int user_id;
  bool loadData = false;
  // ใส่เพื่อเมื่อสลับหน้า(Tab) ให้ใช้ข้อมูลเดิมที่เคยโหลดแล้ว ไม่ต้องโหลดใหม่
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    getuserID();
    getFile();
  }

  Future<void> getFile() async {
    Directory dir = await checkDirectory("Pictures");
    //ไฟล์รูป
    setState(() {
      List<FileSystemEntity> _photoLists = dir.listSync();

      if (_photoLists.isNotEmpty) {
        // List<FileSystemEntity> _photoList = List.from(_photoLists.reversed);
        _photoLists.sort((a, b) => b.path.compareTo(a.path));

        if (user_id != 0) {
          for (var i = 0; i < _photoLists.length; i++) {
            String userIDFromFile =
                _photoLists[i].path.split('/').last.split('_').first;

            if (user_id.toString() == userIDFromFile) {
              listimg.add(FileDetectImg(i + 1, _photoLists[i]));
            }
          }
        }
      }

      loadData = true;
    });
  }

  Future<void> getuserID() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id') ?? 0;
  }

  Future<int> deleteFile(List<FileDetectImg> listdataImg) async {
    try {
      Directory dir = await checkDirectory("License_plate");

      for (var i = 0; i < listdataImg.length; i++) {
        String filenameLicense = listdataImg[i].fileImg.path.split("/").last;

        //ลบไฟล์รูป Rider
        listdataImg[i].fileImg.delete(recursive: true);
        listimg.remove(listdataImg[i]);

        //ลบไฟล์รูป License plate
        File(dir.path + '/' + filenameLicense).delete();
      }

      Navigator.pop(context, 'OK');

      setState(() {
        listSelectimg.clear();
        selectData = false;
      });

      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 40,
        bottomOpacity: 0.0,
        elevation: 0.0,
        actions: [
          //สำหรับเลือกทุกไฟล์
          selectData
              ? Checkbox(
                  activeColor: Colors.blue,
                  value: selectAll,
                  onChanged: (value) {
                    setState(() {
                      selectAll = value!;
                      if (value) {
                        listSelectimg.clear();
                        for (var i = 0; i < listimg.length; i++) {
                          listSelectimg.add(listimg[i]);
                        }
                      } else {
                        listSelectimg.clear();
                      }
                    });
                  })
              : Container(),
          //ปุ่มเลือก
          TextButton(
              onPressed: () {
                setState(() {
                  if (!selectData) {
                    selectAll = false;
                  }
                  selectData = true;
                });
              },
              child: const Text("เลือก",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)))
        ],
      ),
      body: SafeArea(
          child: Stack(
        children: [
          loadData
              ? listimg.isNotEmpty
                  ? ListView.builder(
                      // scrollDirection: Axis.horizontal,
                      //shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: listimg.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildDataImage(index);
                      },
                    )
                  : const Center(
                      child: Text("ไม่มีรูปภาพ"),
                    )
              : const Center(child: CircularProgressIndicator()),
          selectData
              ? Positioned(
                  bottom: 35.0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                listSelectimg.clear();
                                selectData = false;
                              });
                            },
                            child: const Text("ปิด",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          TextButton(
                            onPressed: () {
                              if (listSelectimg.isNotEmpty) {
                                comfirmDialog(
                                    "ต้องการอัปโหลดหรือไม่", listSelectimg, 1);
                              }
                            },
                            child: const Text("อัปโหลด",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          TextButton(
                            onPressed: () {
                              if (listSelectimg.isNotEmpty) {
                                comfirmDialog(
                                    "ต้องการลบหรือไม่", listSelectimg, 2);
                              }
                            },
                            child: const Text("ลบ",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          )
                        ]),
                  ))
              : Container()
        ],
      )),
    );
  }

  Future<String> datetimeImage(FileDetectImg dataimg) async {
    try {
      final tags = await readExifFromFile(dataimg.fileImg);
      String dateTime = tags['EXIF DateTimeOriginal'].toString();
      return dateTime;
    } catch (e) {
      return "";
    }
  }

  Future<Widget> displayPicture(FileDetectImg dataimg) async {
    return GestureDetector(
      child: Image.file(
        dataimg.fileImg as File,
        width: 150.0,
        height: 150.0,
        //scale: 16.0,
        fit: BoxFit.contain,
      ),
      onTap: () {
        zoomPictureDialog(context, dataimg.fileImg, 1);
      },
    );
  }

  Future<List<double>> coordinates(FileDetectImg dataimg) async {
    List<double> latlong = [];
    /////////////////////////////////// พิกัด////////////////////////////////////
    try {
      final tags = await readExifFromFile(dataimg.fileImg);
      final latitudeValue = tags['GPS GPSLatitude']!
          .values
          .toList()
          .map<double>((item) =>
              (item.numerator.toDouble() / item.denominator.toDouble()))
          .toList();
      final latitudeSignal = tags['GPS GPSLatitudeRef']!.printable;
      final longitudeValue = tags['GPS GPSLongitude']!
          .values
          .toList()
          .map<double>((item) =>
              (item.numerator.toDouble() / item.denominator.toDouble()))
          .toList();
      final longitudeSignal = tags['GPS GPSLongitudeRef']!.printable;

      double latitude = latitudeValue[0] +
          (latitudeValue[1] / 60) +
          (latitudeValue[2] / 3600);

      double longitude = longitudeValue[0] +
          (longitudeValue[1] / 60) +
          (longitudeValue[2] / 3600);

      if (latitudeSignal == 'S') latitude = -latitude;
      if (longitudeSignal == 'W') longitude = -longitude;
      latlong.add(latitude);
      latlong.add(longitude);
    } catch (e) {
      // _photoList[index].deleteSync();
      // _photoList.removeAt(index);
    }
    //////////////////////////////////////////////////////////////////////////
    return latlong;
  }

  Widget buildDataImage(int index) {
    return GestureDetector(
        onTap: () {
          if (selectData) {
            if (selectAll) {
              selectAll = false;
            }
            if (listSelectimg.contains(listimg[index])) {
              setState(() {
                listSelectimg.remove(listimg[index]);
              });
            } else {
              setState(() {
                listSelectimg.add(listimg[index]);
              });
            }
          }
        },
        onLongPress: () {
          if (!selectData) {
            setState(() {
              listSelectimg.add(listimg[index]);
              if (!selectData) {
                selectAll = false;
              }
              selectData = true;
            });
          }
        },
        child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border.all(
                    color: listSelectimg.contains(listimg[index])
                        ? Colors.blueAccent
                        : Colors.white,
                    width: 2)),
            child: Card(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FutureBuilder(
                        future: displayPicture(listimg[index]),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.data != null) {
                            return snapshot.data;
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                  ),
                  Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("วันที่ตรวจจับ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left),
                          FutureBuilder(
                              future: datetimeImage(listimg[index]),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.data != null) {
                                  return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(formatDate(snapshot.data)));
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                          const Text("ละติจูด, ลองจิจูด",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left),
                          Container(
                              //margin: const EdgeInsets.symmetric(vertical: 10),
                              child: TextButton(
                            onPressed: () {
                              coordinates(listimg[index]).then((value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowMap(value)),
                                );
                              });
                            },
                            child: FutureBuilder(
                                future: coordinates(listimg[index]),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.data != null) {
                                    return Text(
                                        "${snapshot.data[0].toStringAsFixed(3)}, ${snapshot.data[1].toStringAsFixed(3)}",
                                        style:
                                            TextStyle(color: Colors.blue[900]));
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                }),
                          )),
                        ],
                      )),
                  selectData
                      ? Expanded(
                          flex: 1,
                          child: Checkbox(
                              activeColor: Colors.blue,
                              value: listSelectimg.contains(listimg[index])
                                  ? true
                                  : false,
                              onChanged: (value) {
                                if (selectAll) {
                                  selectAll = false;
                                }
                                if (listSelectimg.contains(listimg[index])) {
                                  setState(() {
                                    listSelectimg.remove(listimg[index]);
                                  });
                                } else {
                                  setState(() {
                                    listSelectimg.add(listimg[index]);
                                  });
                                }
                              }))
                      : Container()
                ],
              ),
            )));
  }

  comfirmDialog(String message, List<FileDetectImg> listdataimg, int type) {
    //type 1 = อัปโหลด type 2 = ลบไฟล์
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: Text(
          message,
          style: const TextStyle(
            fontSize: 17,
          ),
        ),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: Text(
                  'ใช่',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (type == 1) {
                    int statusInternet = await checkInternet(context);
                    if (statusInternet != 0) {
                      uploadDetectedImage(listdataimg);
                    } else {
                      normalDialog(context,
                          "ไม่สามารถอัปโหลดได้\nกรุณาตรวจสอบอินเทอร์เน็ต");
                    }
                  } else {
                    deleteFile(listdataimg);
                  }
                },
              ),
              TextButton(
                child: Text(
                  'ไม่',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> uploadDetectedImage(List<FileDetectImg> listdataImg) async {
    Navigator.pop(context, 'OK');
    ShowloadDialog().showLoading(context);

    String uploadurl = "${Constant().domain}/DetectedImage/uploadImage";
    int? checkupload;

    for (var i = 0; i < listdataImg.length; i++) {
      //ชื่อไฟล์
      int genName = DateTime.now().millisecondsSinceEpoch;
      DateTime datenow = DateTime.now();
      //วันที่ตรวจจับ
      String detectionDate = await datetimeImage(listdataImg[i]);
      //พิกัด
      List<double> listCoordinates = await coordinates(listdataImg[i]);
      Directory dir = await checkDirectory("License_plate");
      String filenameLicense = listdataImg[i].fileImg.path.split("/").last;
      String pathLicenseImg = dir.path + '/' + filenameLicense;

      FormData formdata = FormData.fromMap({
        "file": [
          await MultipartFile.fromFile(listdataImg[i].fileImg.path,
              filename:
                  'rider_' + user_id.toString() + genName.toString() + '.jpg'),
          await MultipartFile.fromFile(pathLicenseImg,
              filename: 'license-plate_' +
                  user_id.toString() +
                  genName.toString() +
                  '.jpg')
        ],
        "user_id": user_id,
        "datetime": datenow.toString(),
        "latitude": listCoordinates[0],
        "longitude": listCoordinates[1],
        "detection_at": detectionDate
      });

      Response response = await Dio().post(
        uploadurl,
        data: formdata,
      );
      if (response.statusCode == 200) {
        checkupload = i;
      } else {
        checkupload = -1;
        break;
      }
    }

    Navigator.of(context, rootNavigator: true).pop();
    if (checkupload != -1) {
      normalDialog(context, "อัปโหลดสำเร็จ");
      deleteFile(listdataImg);
    } else {
      normalDialog(context, "อัปโหลดไม่สำเร็จ");
    }
  }
}

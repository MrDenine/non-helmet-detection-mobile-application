import 'dart:async';
import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/models/file_img_video.dart';
import 'package:non_helmet_mobile/pages/video_page/video.dart';
import 'package:non_helmet_mobile/utility/saveimage_video.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoMain extends StatefulWidget {
  VideoMain({Key? key}) : super(key: key);

  @override
  _VideoMainState createState() => _VideoMainState();
}

class _VideoMainState extends State<VideoMain> {
  //List<FileSystemEntity> videoList = [];
  List<FileVideo> listVideo = [];
  List<FileVideo> listSelectVideo = [];
  bool _running = true;
  bool selectData = false;
  bool selectAll = false; //สำหรับเลือกไฟล์ทั้งหมด
  late int user_id;
  bool loadData = false;
  bool loadnewVideo = false;
  @override
  void initState() {
    super.initState();
    getuserID();
    getFile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getuserID() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id') ?? 0;
  }

  Future<void> getFile() async {
    Directory dir = await checkDirectory("Video");
    //ไฟล์รูป
    setState(() {
      listVideo.clear();
      List<FileSystemEntity> videoList = dir.listSync();
      // List<FileSystemEntity> videoList = List.from(_photoLists.reversed);
      videoList.sort((a, b) => b.path.compareTo(a.path));

      if (user_id != 0) {
        for (var i = 0; i < videoList.length; i++) {
          String userIDFromFile =
              videoList[i].path.split('/').last.split('_').first;

          if (user_id.toString() == userIDFromFile) {
            listVideo.add(FileVideo(i + 1, videoList[i]));
          }
        }
      }
      loadData = true;
    });
  }

  Stream<double> showloadingVideo() async* {
    final prefs = await SharedPreferences.getInstance();
    String frameImgDirPath = await createFolder("FrameImage");

    while (_running) {
      await Future<void>.delayed(const Duration(seconds: 1));
      List<FileSystemEntity> photoList = Directory(frameImgDirPath).listSync();
      int listFrameImg = prefs.getInt('listFrameImg') ?? -1;
      if (photoList.isEmpty && listFrameImg == 0) {
        _running = false;
        yield 111;
        setState(() {
          getFile();
        });
      } else if (photoList.length <= listFrameImg) {
        yield ((photoList.length * 100) / listFrameImg);
      }
    }
    loadnewVideo = true;
  }

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
          'วิดีโอ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          //textAlign: TextAlign.center,
        ),
        centerTitle: true,
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
                        listSelectVideo.clear();
                        for (var i = 0; i < listVideo.length; i++) {
                          listSelectVideo.add(listVideo[i]);
                        }
                      } else {
                        listSelectVideo.clear();
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
          const SizedBox(
            height: 10,
          ),
          loadData /* && loadnewVideo */
              ? listVideo.isNotEmpty && listVideo != null
                  ? ListView.builder(
                      // scrollDirection: Axis.horizontal,
                      //shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: listVideo.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildVideoList(index);
                      },
                    )
                  : const Center(
                      child: Text("ไม่มีวิดีโอ"),
                    )
              : const Center(child: CircularProgressIndicator()),
          StreamBuilder(
            stream: showloadingVideo(),
            builder: (context, AsyncSnapshot<double> snapshot) {
              if (snapshot.data != null && snapshot.data! <= 100.0) {
                return LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width,
                  lineHeight: 15.0,
                  percent: snapshot.data! / 100,
                  backgroundColor: Colors.grey,
                  progressColor: Colors.blue,
                  center: Text(
                    "กำลังโหลดวิดีโอใหม่ ${snapshot.data!.toStringAsFixed(2)}%",
                    style: const TextStyle(fontSize: 10.0),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
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
                                listSelectVideo.clear();
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
                              if (listSelectVideo.isNotEmpty) {
                                comfirmDialog("ต้องการดาวน์โหลดหรือไม่",
                                    listSelectVideo, 1);
                              }
                            },
                            child: const Text("ดาวน์โหลด",
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
                              if (listSelectVideo.isNotEmpty) {
                                comfirmDialog(
                                    "ต้องการลบหรือไม่", listSelectVideo, 2);
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

  Future<Widget> fileName(FileVideo dataVideo) async {
    String filename = dataVideo.fileVideo.path.split('/').last;
    return Text(filename);
  }

  Future<Widget> datetimeVideo(FileVideo dataVideo) async {
    String dateString = dataVideo.fileVideo.path
        .split('/')
        .last
        .split('_')
        .last
        .split('.')
        .first;
    String dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(dateString)).toString();
    return Text(formatDate(dateTime));
  }

  Widget buildVideoList(int index) {
    return GestureDetector(
      onTap: () {
        if (selectData) {
          if (selectAll) {
            selectAll = false;
          }
          if (listSelectVideo.contains(listVideo[index])) {
            setState(() {
              listSelectVideo.remove(listVideo[index]);
            });
          } else {
            setState(() {
              listSelectVideo.add(listVideo[index]);
            });
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      VideoPage(listVideo[index].fileVideo.path)));
        }
      },
      onLongPress: () {
        if (!selectData) {
          setState(() {
            listSelectVideo.add(listVideo[index]);
            if (!selectData) {
              selectAll = false;
            }
            selectData = true;
          });
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(
                color: listSelectVideo.contains(listVideo[index])
                    ? Colors.blue
                    : Colors.white,
                width: 2.0)),
        child: Row(
          children: [
            Expanded(
                child: Image.asset(
              "assets/images/playVideo.png",
              scale: 10,
            )),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ชื่อไฟล์",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    FutureBuilder(
                      future: fileName(listVideo[index]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data != null) {
                          return snapshot.data;
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "วันที่บันทึก",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder(
                      future: datetimeVideo(listVideo[index]),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data != null) {
                          return snapshot.data;
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                )),
            selectData
                ? Expanded(
                    flex: 1,
                    child: Checkbox(
                        activeColor: Colors.blue,
                        value: listSelectVideo.contains(listVideo[index])
                            ? true
                            : false,
                        onChanged: (value) {
                          if (selectAll) {
                            selectAll = false;
                          }
                          if (listSelectVideo.contains(listVideo[index])) {
                            setState(() {
                              listSelectVideo.remove(listVideo[index]);
                            });
                          } else {
                            setState(() {
                              listSelectVideo.add(listVideo[index]);
                            });
                          }
                        }))
                : Container()
          ],
        ),
      ),
    );
  }

  comfirmDialog(String message, List<FileVideo> listvideo, int type) {
    //type 1 = อัปโหลก type 2 = ลบไฟล์
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
                onPressed: () {
                  if (type == 1) {
                    downloadFile(listvideo);
                  } else {
                    deleteFile(listvideo);
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

  Future<int> deleteFile(List<FileVideo> listdatavideo) async {
    try {
      for (var i = 0; i < listdatavideo.length; i++) {
        listdatavideo[i].fileVideo.deleteSync();
        listVideo.remove(listdatavideo[i]);
      }

      Navigator.pop(context, 'OK');

      setState(() {
        listSelectVideo.clear();
        selectData = false;
      });

      return 0;
    } catch (e) {
      return 1;
    }
  }

  Future<int> downloadFile(List<FileVideo> listdatavideo) async {
    ShowloadDialog().showLoading(context);
    try {
      String? tempPath = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);

      for (var i = 0; i < listdatavideo.length; i++) {
        String filename = DateTime.now().millisecondsSinceEpoch.toString();
        String filePath = tempPath! + '/file_$filename.mp4';
        File fileOutput = File(filePath);
        File fileInput = File(listdatavideo[i].fileVideo.path);
        await fileOutput.writeAsBytes(fileInput.readAsBytesSync(),
            mode: FileMode.writeOnly);
      }

      Navigator.pop(context, 'OK');
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        listSelectVideo.clear();
        selectData = false;
      });

      normalDialog(context, "ดาวน์โหลดสำเร็จ");
      return 0;
    } catch (e) {
      return 1;
    }
  }
}

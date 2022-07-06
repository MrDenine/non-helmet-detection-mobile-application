import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:non_helmet_mobile/models/data_image.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/utility/convert_img_isolate.dart';
import 'package:non_helmet_mobile/utility/saveimage_video.dart';
import 'package:non_helmet_mobile/utility/upload_detect_image.dart';
import 'package:non_helmet_mobile/utility/utility.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef Callback = void Function(
    List<dynamic> list, int h, int w, List<dynamic> lists);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  const Camera(this.cameras, this.setRecognitions);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  ////////////////////////////////////////

  CameraController? controller;
  bool isDetecting = false;
  int i = 0; //สำหรับแก้บัคข้อมูลซ้ำ
  List checkValue = []; //สำหรับแก้บัคข้อมูลซ้ำ
  List<CameraImage> listCameraimg = [];
  String? recordVideo;
  String? autoUpload;
  String? resolution;
  Size? screen; //สำหรับ Crop
  // List<DataAveColor> listAvgColors = [];
  List<DataImageForCheck> listDataImg = []; //สำหรับนำไปตรวจสอบค่า
  List<dynamic> listDataForTrack = [];
  late int user_id;

  int startTime = 0;
  int endTime = 0;

  /////////////สำหรับวิดีโอ/////////////////

  String frameImgDirPath = ""; // path โฟลเดอร์เฟรมภาพ
  String videoDirPath = ""; // path โฟลเดอร์วิดีโอ
  bool firstTimeRecord = true; //เริ่มเซฟวิดีโอ
  bool getFrameimg = false; //เริ่มเก็บเฟรมภาพ
  bool? readyforRecord;
  Timer? timeGetFrameImg;
  int startTimeRec = 0;
  int endTimeRec = 0;
  //จำนวนลิสก่อนจะเข้าฟังก์ชันสร้างวิดีโอ เพื่อนำไปตัดเฟรมภาพที่ใช้ไปแล้วออก
  int prevLengofList = 0;

  ///////////////////////////////////////

  int rotation_value = 90; //ค่าการหมุนจอ

  IsolateUtils? isolateUtils; //สำหรับทำ Isolate

  bool toggleDetect = false; //สำหรับปิด/เปิดการตรวจจับ

  @override
  void initState() {
    super.initState();
    //imageDetect();
    getData();
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id') ?? 0;

    //รับ path โฟลเดอร์เฟรมภาพ
    frameImgDirPath = await createFolder("FrameImage");
    //รับ path โฟลเดอร์วิดีโอ
    videoDirPath = await createFolder("Video");

    var listdata = await getDataSetting();
    if (listdata != "Error") {
      resolution = listdata["resolution"];
      autoUpload = listdata["autoUpload"];
      recordVideo = listdata["recordVideo"];
    } else {
      resolution = "1";
      autoUpload = "true";
      recordVideo = "false";
    }
    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    await isolateUtils!.start();
    imageDetect();
  }

  imageDetect() {
    if (widget.cameras.isEmpty) {
    } else {
      controller = CameraController(
          widget.cameras[0],
          resolution == "1"
              ? ResolutionPreset.high
              : ResolutionPreset.veryHigh);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller!.startImageStream((CameraImage img) {
          if (toggleDetect) {
            ///////////////////////////ส่วนอัดวิดีโอ/////////////////////////////
            if (recordVideo == "true") {
              //รับเฟรมภาพ
              if (!getFrameimg) {
                getFrameimg = true;
                //เก็บเฟรมภาพทุก ๆ 0.25 วินาที
                timeGetFrameImg = Timer(const Duration(milliseconds: 250), () {
                  listCameraimg.add(img);
                  getFrameimg = false;
                });
              }

              //ทำครั้งแรก ครั้งเดียว ต่อไปจะทำแบบสวิต เมื่อทำเสร็จแล้วทำต่อไปเลยไม่ต้องรอ
              if (firstTimeRecord) {
                firstTimeRecord = false;
                //เซฟวิดีโอ 1 นาที ในครั้งแรก
                Future.delayed(const Duration(minutes: 1), () {
                  readyforRecord = true;
                });
              }

              //สร้างวิดีโอ
              if (readyforRecord != null && readyforRecord!) {
                startTimeRec = DateTime.now().millisecondsSinceEpoch;

                if (frameImgDirPath.isNotEmpty && videoDirPath.isNotEmpty) {
                  readyforRecord = false;
                  prevLengofList = listCameraimg.length;
                  SaveVideo(user_id, listCameraimg, frameImgDirPath,
                      videoDirPath, rotation_value, (value) {
                    endTimeRec = DateTime.now().millisecondsSinceEpoch;
                    listCameraimg.removeRange(0, prevLengofList);
                    readyforRecord = true;
                  }).init();
                }
              }
            }
            /////////////////////////////ส่วนตรวจจับ////////////////////////////
            if (!isDetecting) {
              isDetecting = true;
              ////////////////////////////////////////////////////////////////
              startTime = DateTime.now().millisecondsSinceEpoch;
              ////////////////////////////////////////////////////////////////
              Tflite.detectObjectOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: "SSDMobileNet",
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: 127.5,
                imageStd: 127.5,
                rotation: rotation_value,
                // numResultsPerClass: 4,
                // threshold: 0.1,
                numResultsPerClass: 10,
                numBoxesPerBlock: 10,
                threshold: 0.5,
              ).then((recognitions) {
                /////////////////////ส่วนเงื่อนไข////////////////////////////////////

                if (recognitions!.isNotEmpty) {
                  if (i == 0) {
                    i = 1;
                    inference(IsolateData(img, recognitions, screen!,
                            listDataImg, rotation_value))
                        .then((value) {
                      if (value.isNotEmpty) {
                        listDataForTrack = value[0].dataforTrack;
                        listDataImg = value[0].listdataImg;

                        if (value[0].dataImage.isNotEmpty) {
                          for (var i = 0; i < value[0].dataImage.length; i++) {
                            if (autoUpload == "true") {
                              //เช็คอินเทอร์เน็ต
                              checkInternet(context).then((status) {
                                if (status != 0) {
                                  uploadDatectedImage(
                                      context,
                                      user_id,
                                      value[0].dataImage[i].riderImg,
                                      value[0].dataImage[i].license_plateImg,
                                      value[0].dataImage[i].datetimeDetected);
                                } else {
                                  succeedDialog(
                                      context,
                                      "ไม่สามารถอัปโหลดได้\nกรุณาตรวจสอบอินเทอร์เน็ต",
                                      HomePage());
                                }
                              });
                            } else {
                              saveImageDetect(
                                  context,
                                  user_id,
                                  value[0].dataImage[i].riderImg,
                                  value[0].dataImage[i].license_plateImg,
                                  value[0].dataImage[i].datetimeDetected);
                            }
                          }
                        }
                      } else {
                        listDataForTrack = [];
                      }
                      i = 0;
                    });
                  }
                } else {
                  listDataForTrack = [];
                }
                //////////////////////////////////////////////////////////////////
                // endTime = DateTime.now().millisecondsSinceEpoch;

                widget.setRecognitions(
                    recognitions, img.height, img.width, listDataForTrack);
                isDetecting = false;
              });
            }
          } else {
            widget.setRecognitions([], img.height, img.width, []);
          }
        });
      });
    }
  }

  /// Runs inference in another isolate
  Future<dynamic> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils!.sendPort
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  void dispose() {
    ////////////////////ทำหลังจากออกจากหน้าตรวจจับ/////////////////////////
    if (recordVideo == "true" && listCameraimg.isNotEmpty) {
      timeGetFrameImg!.cancel();
      if (readyforRecord == null || readyforRecord == true) {
        if (frameImgDirPath.isNotEmpty && videoDirPath.isNotEmpty) {
          SaveVideo(user_id, listCameraimg, frameImgDirPath, videoDirPath,
                  rotation_value, (value) {})
              .init();
        }
      } else if (listCameraimg.isNotEmpty) {
        Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          checkReadyforRecVideo().then((value) {
            if (value) {
              timer.cancel();
              SaveVideo(user_id, listCameraimg, frameImgDirPath, videoDirPath,
                      rotation_value, (value) {})
                  .init();
            }
          });
        });
      }
    }
    /////////////////////////////////////////////////////////////////////
    controller?.dispose();
    super.dispose();
  }

  Future<bool> checkReadyforRecVideo() async {
    final prefs = await SharedPreferences.getInstance();
    int listFrameImg = prefs.getInt('listFrameImg') ?? -1;
    if (listFrameImg == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
      );
    }

    screen = MediaQuery.of(context).size; //สำหรับ Crop
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller!.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return NativeDeviceOrientationReader(builder: (context) {
      NativeDeviceOrientation orientation =
          NativeDeviceOrientationReader.orientation(context);

      switch (orientation) {
        case NativeDeviceOrientation.landscapeLeft:
          rotation_value = 360;
          break;
        case NativeDeviceOrientation.landscapeRight:
          rotation_value = 180;
          break;
        case NativeDeviceOrientation.portraitDown:
          rotation_value = 270;
          break;
        default:
          rotation_value = 90;
          break;
      }

      if (rotation_value == 90 || rotation_value == 270) {
        return OverflowBox(
            maxHeight: screenRatio > previewRatio
                ? screenH
                : screenW / previewW * previewH,
            maxWidth: screenRatio > previewRatio
                ? screenH / previewH * previewW
                : screenW,
            child: Stack(alignment: Alignment.center, children: [
              CameraPreview(controller!),
              Positioned(
                  bottom: 40,
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        toggleDetect = !toggleDetect;
                      });
                    },
                    color: toggleDetect ? Colors.red : Colors.amber,
                    textColor: Colors.white,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                  ))
            ]));
      } else {
        return OverflowBox(
            maxHeight: screenRatio > previewRatio
                ? screenH / previewH * previewW
                : screenW,
            maxWidth: screenRatio > previewRatio
                ? screenH
                : screenW / previewW * previewH,
            child: Stack(alignment: Alignment.center, children: [
              CameraPreview(controller!),
              Positioned(
                  left: 20,
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        toggleDetect = !toggleDetect;
                      });
                    },
                    color: toggleDetect ? Colors.red : Colors.amber,
                    textColor: Colors.white,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                  ))
            ]));
      }
    });
  }
}

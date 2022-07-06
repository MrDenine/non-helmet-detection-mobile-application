import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:easy_isolate/easy_isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart' as dd;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveImageDetect(BuildContext context, int user_id,
    Uint8List riderImg, Uint8List licenseImg, int datetimeDetect) async {
  try {
    //รับพิกัด
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final exif = dd.FlutterExif.fromBytes(riderImg);
    await exif.setLatLong(position.latitude, position.longitude);
    await exif.setAttribute("DateTimeOriginal",
        DateTime.fromMillisecondsSinceEpoch(datetimeDetect).toString());
    await exif.saveAttributes();

    final modifiedImage = await exif.imageData;
    /////////////////////////////////////////////////////////////////////
    String tempPathPic = await createFolder("Pictures");
    String tempPathLic = await createFolder("License_plate");

    if (tempPathPic.isNotEmpty && tempPathLic.isNotEmpty) {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();

      var filePathRider = tempPathPic + '/${user_id}_$filename.jpg';
      var filePathLicense = tempPathLic + '/${user_id}_$filename.jpg';

      File(filePathRider).writeAsBytes(modifiedImage!);
      File(filePathLicense).writeAsBytes(licenseImg);
    } else {}
    /////////////////////////////////////////////////////////////////////
  } catch (e) {
    succeedDialog(context, "ไม่สามารถบันทึกภาพได้\nกรุณาเปิด GPS", HomePage());
  }
}

Future<void> saveVideo(giffile) async {
  final FlutterFFmpeg _flutterFFmpeg =
      FlutterFFmpeg(); // Create new ffmpeg instance somewhere in your code
  int result;

  ////////////////////////////////////////////////////////////////////////////
  String tempPath = await createFolder("Video");
  if (tempPath.isNotEmpty) {
    String filename = DateTime.now().millisecondsSinceEpoch.toString();
    String filePath = tempPath + '/file_$filename.gif';
    String filePathMP4 = tempPath + '/file_$filename.mp4';
    final String inputFile = filePath; //path of the gif file.
    final String outputFile = filePathMP4; //path to export the mp4 file.
    File(filePath).writeAsBytes(giffile!).then((gifData) async => {
          //แปลงไฟล์ gif => mp4
          result = await _flutterFFmpeg
              .execute("-f gif -i $inputFile -pix_fmt yuv420p $outputFile"),
          if (result == 0)
            {
              await gifData.delete(),
            }
        });
  } else {}
  //////////////////////////////////////////////////////////////////////////////
}

Future<String> createFolder(String folderName) async {
  final dir =
      Directory((await getExternalStorageDirectory())!.path + '/$folderName');

  if ((await dir.exists())) {
    return dir.path;
  } else {
    dir.create();
    return dir.path;
  }
}

class SaveVideo {
  int userID;
  List<CameraImage> listimg;
  String frameImgDirPath;
  String videoDirPath;
  int rotation_value;
  ValueChanged<bool> callback;
  SaveVideo(this.userID, this.listimg, this.frameImgDirPath, this.videoDirPath,
      this.rotation_value, this.callback);
  final worker = Worker();

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int listFrameImg = prefs.getInt('listFrameImg') ?? 0;
    if (listFrameImg == 0) {
      await prefs.setInt('listFrameImg', listimg.length);
      await worker.init(
        mainMessageHandler,
        isolateMessageHandler,
        errorHandler: print,
      );
      worker.sendMessage({
        "userID": userID,
        "listimg": listimg,
        "frameImgDirPath": frameImgDirPath,
        "videoDirPath": videoDirPath,
        "rotation": rotation_value
      });
    } else {
      callback(false);
    }
  }

  /// Handle the messages coming from the isolate สร้างเป็นวิดีโอ
  void mainMessageHandler(dynamic data, SendPort isolateSendPort) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user_ID = data["userID"].toString();
    String _frameImgDirPath = data["frameImgDirPath"];
    String _videoDirPath = data["videoDirPath"];
    List<FileSystemEntity> _photoList = data["photoList"];

    final FlutterFFmpeg _flutterFFmpeg =
        FlutterFFmpeg(); // Create new ffmpeg instance somewhere in your code

    String filename = DateTime.now().millisecondsSinceEpoch.toString();
    String filePathMP4 = _videoDirPath + '/${user_ID}_$filename.mp4';
    int result = await _flutterFFmpeg.execute(
        "-framerate 4 -probesize 42M -i $_frameImgDirPath/img%d.jpg -preset ultrafast -pix_fmt yuv420p $filePathMP4");

    if (result == 0) {
      final dir = Directory(_frameImgDirPath);
      dir.deleteSync(recursive: true);
      createFolder("FrameImage");
      await prefs.setInt('listFrameImg', 0);
      callback(true);
    } else {
      await prefs.setInt('listFrameImg', -1);
      callback(false);
    }
  }

  /// Handle the messages coming from the main แปลง yuv => ภาพและเซฟลงเครื่อง
  static isolateMessageHandler(
      dynamic data, SendPort mainSendPort, SendErrorFunction sendError) async {
    List<CameraImage> listimg = data["listimg"];
    String frameImgDirPath = data["frameImgDirPath"];
    String videoDirPath = data["videoDirPath"];
    int rotation = data["rotation"];
    int userID_data = data["userID"];
    List<FileSystemEntity> photoList = [];

    //แก้บัคเซฟวิดีโอ
    final File file = File('$frameImgDirPath/img.jpg');
    await file.writeAsString("Frame Image From CameraImage");

    for (var i = 0; i < listimg.length; i++) {
      List listindex = [];
      List listuvIndex = [];
      CameraImage image = listimg[i];
      int uvRowStride = image.planes[1].bytesPerRow;
      int? uvPixelStride = image.planes[1].bytesPerPixel;
      int width = image.width;
      int height = image.height;

      var img = imglib.Image(width, height); // Create Image buffer
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          int uvIndex =
              uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
          int index = y * width + x;
          listindex.add(index);
          listuvIndex.add(uvIndex);
        }
      }

      for (var i = 0; i < listuvIndex.length; i++) {
        var yp = image.planes[0].bytes[listindex[i]];
        var up = image.planes[1].bytes[listuvIndex[i]];
        var vp = image.planes[2].bytes[listuvIndex[i]];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        img.data[listindex[i]] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }

      imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
      List<int> png = pngEncoder.encodeImage(img);
      final originalImage = imglib.decodeImage(png);
      final height1 = originalImage!.height;
      final width1 = originalImage.width;
      late imglib.Image fixedImage;
      if (height1 < width1) {
        fixedImage = imglib.copyRotate(originalImage, 90);
      }

      switch (rotation) {
        case 360: //แนวนอนหมุนซ้าย
          fixedImage = imglib.copyRotate(fixedImage, 270);
          break;
        case 180: //แนวนอนหมุนขวา
          fixedImage = imglib.copyRotate(fixedImage, 90);
          break;
        case 270: //แนวตั้งกลับหัว
          fixedImage = imglib.copyRotate(fixedImage, 180);
          break;
        default: //แนวตั้งปกติ
          break;
      }

      ////////////////////////////////////////////////////////////////////////
      photoList = Directory(frameImgDirPath).listSync();

      String filename = "";

      if (photoList.isNotEmpty && photoList.length > 1) {
        filename = (photoList.length).toString();
      } else {
        filename = 1.toString();
      }

      var filePath = "$frameImgDirPath/img$filename.jpg";
      File(filePath).writeAsBytes(imglib.encodeJpg(fixedImage) as Uint8List);
      ////////////////////////////////////////////////////////////////////////
    }
    mainSendPort.send({
      "userID": userID_data,
      "frameImgDirPath": frameImgDirPath,
      "videoDirPath": videoDirPath,
      "photoList": photoList,
    });
  }
}

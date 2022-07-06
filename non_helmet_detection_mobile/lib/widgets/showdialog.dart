import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/widgets/dialog_otp.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> normalDialog(BuildContext context, String message) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SimpleDialog(
      title: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: const Text('ปิด'),
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

Future<void> dialogAuto(BuildContext context, String message) async {
  Future.delayed(const Duration(seconds: 3), () {
    Navigator.of(context).pop();
  });
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SimpleDialog(
      children: [
        Center(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> succeedDialog(
    BuildContext context, String message, dynamic onpressed) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SimpleDialog(
      title: Text(
        message,
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: const Text('ปิด'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => onpressed),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        )
      ],
    ),
  );
}

Future<void> settingPermissionDialog(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SimpleDialog(
      title: const Text(
        "กรุณาอนุญาตตั้งค่าแอปทั้งหมดก่อน",
        style: TextStyle(fontSize: 17),
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: const Text(
                "ไปหน้าตั้งค่าแอป",
                style: TextStyle(fontSize: 15, color: Colors.red),
              ),
              onPressed: () {
                openAppSettings();
              },
            ),
            TextButton(
              child: Text(
                "เริ่มแอปใหม่",
                style: TextStyle(fontSize: 15, color: Colors.amber.shade700),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SplashPage()),
                );
              },
            ),
          ],
        )
      ],
    ),
  );
}

///ซูมรูปภาพ file คือ ไฟล์รูปภาพจากเครื่องหรือเป็น Url จาก Service และ type 1 = หน้า notupload type 2 = หน้า uploaded
Future<void> zoomPictureDialog(BuildContext context, file, int type) async {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.black12.withOpacity(0.6), // Background color
    barrierDismissible: false,
    barrierLabel: 'Dialog',
    // transitionDuration: const Duration(
    //     milliseconds:
    //         400), // How long it takes to popup dialog after button click
    pageBuilder: (_, __, ___) {
      // Makes widget fullscreen
      return SizedBox.expand(
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
                child: Center(
              child: InteractiveViewer(
                  panEnabled: true, // Set it to false
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 2,
                  child: type == 1
                      ? Image.file(
                          file,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          file,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.contain,
                        )),
            )),
            Positioned(
              top: 25,
              child: TextButton(
                  child: const Icon(Icons.cancel, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop()),
            )
          ],
        ),
      );
    },
  );
}

Future<void> dialogComfirmOTP(
    BuildContext context, int user_id, String email, String content) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SimpleDialog(
      titlePadding: const EdgeInsets.fromLTRB(15, 24.0, 0, 0),
      title: Text(
        content,
        style: const TextStyle(fontSize: 14),
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: Text(
                "ตกลง",
                style: TextStyle(fontSize: 15, color: Colors.amber.shade700),
              ),
              onPressed: () {
                ShowloadDialog().showLoading(context);
                reqOTP(context, user_id, email, 2);
              },
            ),
            TextButton(
              child: const Text(
                "ยกเลิก",
                style: TextStyle(fontSize: 15, color: Colors.red),
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

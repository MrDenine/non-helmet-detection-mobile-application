import 'dart:typed_data';
import 'dart:ui';

//ข้อมูลของรูปภาพ
class DataImage {
  var fileImage;
  var dateCreate;
  var latitude;
  var longitude;

  DataImage(this.fileImage, this.dateCreate, this.latitude, this.longitude);
}

//ลิสไฟล์รูปภาพ และค่าเฉลี่ยสีที่ได้จากการตรวจจับแล้ว
class ListResultImage {
  List<DataDetectedImage> dataImage; //ลิสรูปภาพที่ได้จากการตรวจจับ
  //List<DataAveColor> listAvgColor; //ลิสค่าเฉลี่ยสีของรูปภาพ
  List<DataImageForCheck>
      listdataImg; //ลิสเก็บภาพ rider เพื่อนำไปตรวจสอบ ทำ Tracking
  List<dynamic> dataforTrack;

  ListResultImage(this.dataImage, this.listdataImg, this.dataforTrack);
}

class DataDetectedImage {
  Uint8List riderImg;
  Uint8List license_plateImg;
  int datetimeDetected;
  DataDetectedImage(
      this.riderImg, this.license_plateImg, this.datetimeDetected);
}

class DataAveColor {
  int id;
  Color avgColor;
  DataAveColor(this.id, this.avgColor);
}

class DataImageForCheck {
  int id;
  Uint8List img;
  DateTime datetimeDetected;
  int active;
  int totalNum; //จำนวนทั้งหมดรวมตัวที่ถูกลบด้วย
  DataImageForCheck(
      this.id, this.img, this.datetimeDetected, this.active, this.totalNum);
}

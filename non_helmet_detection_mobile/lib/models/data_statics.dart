class DataStatics {
  //สำหรับรถที่ยังไม่ได้อัปโหลด
  int numNotupRidertoday;
  int numNotupRidertoweek;
  int numNotupRidertomonth;
  int numNotupRidertotal;
  //ผู้ใช้คน ๆ นั้น
  int countMeRidertoday; //จำนวนรถที่ผู้ใช้แต่ละอัปมารายวัน
  int countMeRidertoweek; //จำนวนรถที่ผู้ใช้แต่ละอัปมารายสัปดาห์
  int countMeRidertomonth; //จำนวนรถที่ผู้ใช้แต่ละอัปมารายเดือน
  int countMeRidertotal; //จำนวนรถที่ผู้ใช้แต่ละอัปมาทั้งหมด
  //ผู้ใช้ทั้งหมด
  int countAllRidertoday; //จำนวนรถที่ผู้ใช้ทั้งหมดอัปมารายวัน
  int countAllRidertoweek; //จำนวนรถที่ผู้ใช้ทั้งหมดอัปมารายสัปดาห์
  int countAllRidertomonth; //จำนวนรถที่ผู้ใช้ทั้งหมดอัปมารายเดือน
  int countAllRidertotal; //จำนวนรถที่ผู้ใช้ทั้งหมดอัปมาทั้งหมด

  DataStatics(
    this.numNotupRidertoday,
    this.numNotupRidertoweek,
    this.numNotupRidertomonth,
    this.numNotupRidertotal,
    this.countMeRidertoday,
    this.countMeRidertoweek,
    this.countMeRidertomonth,
    this.countMeRidertotal,
    this.countAllRidertoday,
    this.countAllRidertoweek,
    this.countAllRidertomonth,
    this.countAllRidertotal,
  );
}

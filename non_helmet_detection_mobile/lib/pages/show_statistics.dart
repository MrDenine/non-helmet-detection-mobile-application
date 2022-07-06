import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/models/data_statics.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';

class ShowStatPage extends StatefulWidget {
  DataStatics dataStat;
  ShowStatPage(this.dataStat, {Key? key}) : super(key: key);

  @override
  State<ShowStatPage> createState() => _ShowStatPageState();
}

class _ShowStatPageState extends State<ShowStatPage> {
  double? valueWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
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
            'สถิติ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child: Center(
            child: Column(
              children: [
                const SizedBox(height: 2),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 2,
                    itemBuilder: (context, index) =>
                        displayStatics(index, widget.dataStat)),
                const SizedBox(height: 20),
              ],
            ),
          )),
        ));
  }

  ///แสดงสถิติ (ส่วนหลัก)
  Widget displayStatics(int index, DataStatics data) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // is portrait
      valueWidth = MediaQuery.of(context).size.width - 60;
    } else {
      // is landscape
      valueWidth = MediaQuery.of(context).size.width / 2;
    }
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
            decoration: const BoxDecoration(
                color: Color.fromRGBO(62, 73, 122, 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    // offset: Offset(0, 2),
                    blurRadius: 10.0,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20))),
            width: MediaQuery.of(context).size.width - 30,
            child: Column(
              children: [
                const SizedBox(height: 10),
                if (index == 0) ...[
                  index == 0
                      ? const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "จำนวนรถจักรยานยนต์ที่คุณตรวจจับได้",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ))
                      : Container(),
                  staticsNotUpload(data),
                  staticsRiderMe(data)
                ] else ...[
                  staticsRiderAll(data),
                ]
              ],
            )),
      ],
    );
  }

  ///สถิติของผู้ใช้คนนั้น กรณียังไม่อัปโหลด
  Widget staticsNotUpload(DataStatics data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(children: const [
          SizedBox(width: 15),
          Text(
            "ยังไม่อัปโหลด",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
        const SizedBox(height: 15),
        displayDataStatics("\t\tวันนี้:", data.numNotupRidertoday),
        displayDataStatics("\t\tสัปดาห์นี้:", data.numNotupRidertoweek),
        displayDataStatics("\t\tเดือนนี้:", data.numNotupRidertomonth),
        displayDataStatics("\t\tทั้งหมด:", data.numNotupRidertotal),
        const SizedBox(height: 15),
      ],
    );
  }

  ///สถิติของผู้ใช้คนนั้น กรณีอัปโหลดแล้ว
  Widget staticsRiderMe(DataStatics data) {
    return Column(
      children: [
        Row(children: const [
          SizedBox(width: 15),
          Text(
            "อัปโหลดแล้ว",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
        const SizedBox(height: 15),
        displayDataStatics("\t\tวันนี้:", data.countMeRidertoday),
        displayDataStatics("\t\tสัปดาห์นี้:", data.countMeRidertoweek),
        displayDataStatics("\t\tเดือนนี้:", data.countMeRidertomonth),
        displayDataStatics("\t\tทั้งหมด:", data.countMeRidertotal),
        const SizedBox(height: 15),
      ],
    );
  }

  ///สถิติของผู้ใช้ในระบบทั้งหมด
  Widget staticsRiderAll(DataStatics data) {
    return Column(
      children: [
        const Text(
          "จำนวนรถจักรยานยนต์ที่ถูกตรวจจับได้ในระบบ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 15),
        displayDataStatics("\t\tวันนี้:", data.countAllRidertoday),
        displayDataStatics("\t\tสัปดาห์นี้:", data.countAllRidertoweek),
        displayDataStatics("\t\tเดือนนี้:", data.countAllRidertomonth),
        displayDataStatics("\t\tทั้งหมด:", data.countAllRidertotal),
        const SizedBox(height: 15),
      ],
    );
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
                )
              ])
            ],
          ),
        ));
  }
}

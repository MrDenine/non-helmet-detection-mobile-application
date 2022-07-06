import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/pages/upload_Page/notupload.dart';
import 'package:non_helmet_mobile/pages/upload_Page/uploaded.dart';

class Upload extends StatefulWidget {
  Upload({Key? key}) : super(key: key);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'อัปโหลด',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            //Navigator.pop(context);
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
        centerTitle: true,
        bottom: TabBar(
          labelColor: const Color(0xffffffff),
          unselectedLabelColor: const Color(0x55ffffff),
          tabs: const <Tab>[
            Tab(text: 'ยังไม่อัปโหลด'),
            Tab(text: 'อัปโหลดแล้ว'),
          ],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          controller: controller,
        ),
      ),
      body: TabBarView(
        children: <Widget>[NotUpload(), Uploaded()],
        controller: controller,
      ),
    );
  }
}

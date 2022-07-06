import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:non_helmet_mobile/modules/constant.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

class EditProfile extends StatefulWidget {
  EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  int user_id = 0;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  String imageName = "";
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id') ?? 0;

    try {
      var result = await getDataUser(user_id);
      if (result.pass) {
        setState(() {
          var listdata = result.data["data"][0];
          firstname.text = listdata["firstname"];
          lastname.text = listdata["lastname"];
          imageName = listdata["image_profile"];
        });
      }
    } catch (e) {}
  }

  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {}
    });
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
          'ข้อมูลส่วนตัว',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          //textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Center(
                child: Form(
                    key: formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20.0),
                          buildShowPic(),
                          const SizedBox(height: 50.0),
                          buildFirstname(),
                          const SizedBox(height: 20.0),
                          buildLastname(),
                          const SizedBox(height: 50.0),
                          buildConfirm()
                        ],
                      ),
                    )))),
      ),
    );
  }

  Widget buildShowPic() {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        //clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(72.0),
            child: _image == null
                ? FutureBuilder(
                    future: getImageDB(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const CircleAvatar();
                      }
                      if (snapshot.data != null &&
                          snapshot.data != "false" &&
                          snapshot.data != "Error") {
                        return Container(
                          height: 50.0,
                          width: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6.0,
                              ),
                            ],
                            image: DecorationImage(
                                image: NetworkImage("${snapshot.data}"),
                                fit: BoxFit.cover),
                          ),
                        );
                      } else if (snapshot.data == "Error") {
                        return const CircleAvatar();
                      } else {
                        return const CircleAvatar(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  )
                : Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
              bottom: 0,
              right: -25,
              child: RawMaterialButton(
                onPressed: getImage,
                elevation: 2.0,
                fillColor: const Color(0xFFF5F6F9),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                ),
                padding: const EdgeInsets.all(1.0),
                shape: const CircleBorder(),
              )),
        ],
      ),
    );
  }

  Widget buildFirstname() {
    return TextFormField(
      controller: firstname,
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'ชื่อ',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        // filled: true,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกชื่อ"),
      ]),
      onSaved: (value) {
        firstname.text = value!;
      },
    );
  }

  Widget buildLastname() {
    return TextFormField(
      controller: lastname,
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'นามสกุล',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        // filled: true,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกนามสกุล"),
      ]),
      onSaved: (value) {
        lastname.text = value!;
      },
    );
  }

  Widget buildConfirm() {
    return Row(children: <Widget>[
      Expanded(
        child: MaterialButton(
          height: 45,
          highlightColor: Colors.red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          color: Colors.amber,
          child: const Text(
            "บันทึกข้อมูล",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            formKey.currentState!.save();
            if (formKey.currentState!.validate()) {
              editprofile();
            }
          },
        ),
      ),
    ]);
  }

  Future<String> getImageDB() async {
    if (imageName != "") {
      try {
        String urlImage = "${Constant().domain}/profiles/${imageName}";
        var response = await http.get(Uri.parse(urlImage));
        if (response.statusCode == 200) {
          return urlImage;
        } else {
          return "Error";
        }
      } catch (e) {
        return "Error";
      }
    } else {
      return "Error";
    }
  }

  Future<void> editprofile() async {
    ShowloadDialog().showLoading(context);
    DateTime now = DateTime.now();

    try {
      var result = await postEditProfile({
        "user_id": user_id,
        "firstname": firstname.text,
        "lastname": lastname.text,
        "datetime": now.toString(),
      });
      if (result.pass) {
        if (result.data["data"] == "Succeed") {
          if (_image?.path != null) {
            uploadImage();
          } else {
            succeedDialog(context, "บันทึกสำเร็จ", HomePage());
          }
        } else {
          normalDialog(context, "บันทึกไม่สำเร็จ");
        }
      } else {}
    } catch (e) {}
  }

  Future<void> uploadImage() async {
    String uploadurl = "${Constant().domain}/EditProfile/uploadImageProfile";
    //สุ่มชื่อ
    int genName = DateTime.now().millisecondsSinceEpoch;
    String newNameTmage = user_id.toString() +
        "_" +
        genName.toString() +
        "." +
        _image!.path.split('.').last;
    FormData formdata = FormData.fromMap({
      //file download
      "file":
          await MultipartFile.fromFile(_image!.path, filename: newNameTmage),
      "file_type": '1',
    });

    Response response = await Dio().post(
      uploadurl,
      data: formdata,
    );
    Navigator.of(context, rootNavigator: true).pop();
    if (response.statusCode == 200) {
      succeedDialog(context, "บันทึกสำเร็จ", HomePage());
    } else {
      normalDialog(context, "อัปโหลดรูปไม่สำเร็จ");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/pages/homepage.dart';
import 'package:non_helmet_mobile/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // ignore: non_constant_identifier_names
  int user_id = 0;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    load_User_id();
  }

  // ignore: non_constant_identifier_names
  Future<void> load_User_id() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = (prefs.getInt('user_id') ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: user_id != 0 ? HomePage() : Login_Page(),
      duration: 3000,
      imageSize: 300,
      imageSrc: "assets/images/logoSplash.png",
      backgroundColor: Colors.white,
    );
  }
}

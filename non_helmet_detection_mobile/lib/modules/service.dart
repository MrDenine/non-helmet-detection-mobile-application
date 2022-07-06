import 'dart:convert';

import "package:http/http.dart" as http;
import 'package:non_helmet_mobile/modules/constant.dart';

class RequestResult {
  bool pass;
  dynamic data;
  RequestResult(this.pass, this.data);
}

Future<RequestResult> registerUser([dynamic data]) async {
  try {
    var url = "${Constant().domain}/Register/PostRegister";
    var dataStr = jsonEncode(data);
    var result = await http.post(Uri.parse(url), body: dataStr, headers: {
      "Content-Type": "application/json",
    });
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> postLogin([dynamic data]) async {
  try {
    var url = "${Constant().domain}/Login/PostLogin";
    var dataStr = jsonEncode(data);
    var result = await http.post(Uri.parse(url), body: dataStr, headers: {
      "Content-Type": "application/json",
    });
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> getDataUser(user_id) async {
  //Login
  try {
    var url = "${Constant().domain}/GetDataUser/$user_id";
    var result = await http.get(Uri.parse(url));
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> postEditProfile([dynamic data]) async {
  try {
    var url = "${Constant().domain}/EditProfile/PostEditProfile";
    var dataStr = jsonEncode(data);
    var result = await http.post(Uri.parse(url), body: dataStr, headers: {
      "Content-Type": "application/json",
    });
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> postChangePW([dynamic data]) async {
  try {
    var url = "${Constant().domain}/ChangePW/PostChangePW";
    var dataStr = jsonEncode(data);
    var result = await http.post(Uri.parse(url), body: dataStr, headers: {
      "Content-Type": "application/json",
    });
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> ForgotPW_CreatePW([dynamic data]) async {
  try {
    var url = "${Constant().domain}/ForgotPW/PostCreatePW";
    var dataStr = jsonEncode(data);
    var result = await http.post(Uri.parse(url), body: dataStr, headers: {
      "Content-Type": "application/json",
    });
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> req_OTP([dynamic data]) async {
  try {
    var url = "${Constant().domain}/OTP/PostReqOTP";
    var dataStr = jsonEncode(data);
    var result = await http.post(Uri.parse(url), body: dataStr, headers: {
      "Content-Type": "application/json",
    });
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> check_OTP([dynamic data]) async {
  try {
    var url = "${Constant().domain}/OTP/PostCheckOTP";
    var dataStr = jsonEncode(data);
    var result = await http.post(Uri.parse(url), body: dataStr, headers: {
      "Content-Type": "application/json",
    });
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> getAmountRider(user_id) async {
  try {
    var url = "${Constant().domain}/DetectedImage/getAmountRider/$user_id";
    var result = await http.get(Uri.parse(url));
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

Future<RequestResult> getDataDetectedImage(user_id) async {
  try {
    var url =
        "${Constant().domain}/DetectedImage/getDataDetectedImage/$user_id";
    var result = await http.get(Uri.parse(url));
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    return RequestResult(true, "");
  }
}

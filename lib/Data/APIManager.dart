import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nhakhach/Data/DataModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Common/OverlayLoadingProgress.dart';
import 'Constants.dart';
import 'DataManager.dart';
import 'Functions.dart';


class APIManager {
  static final APIManager _instance = APIManager._internal();

  factory APIManager() {
    return _instance;
  }

  APIManager._internal() {
    // initialization logic
  }

  Future<bool> callAPIFile(String path,Map<String, dynamic> data,File? image) async {
    final uri = Uri.parse('$kHostURL/api/$path');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer ${DataManager().aratToken}',
      'Content-Type': 'multipart/form-data',
    },);
    request.fields['data'] = jsonEncode(data);
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // key backend nhận
          image.path,
        ),
      );
    }
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    printDebug("callAPIFile: ${uri.path} ${request.fields} ${response.statusCode} ${responseBody.toString()}");
    return response.statusCode == 200;
  }


  Future<Map<String, dynamic>> callAPI(BuildContext? context, String path, TypeAPI typeAPI, Map<String, dynamic>? body, {String sender = "", int timeInput = 0, TypeApiMethod typeAPIMethod = TypeApiMethod.post}) async {
    // int time = timeInput != 0 ? timeInput : DateTime.timestamp().millisecondsSinceEpoch;
    // body?["time"] = time;
    printDebug("callAPI $path ${typeAPIMethod.name}: $body ${DataManager().aratToken}");
    try {
      Map<String, String> headers = DataManager().aratToken.isEmpty
          ? <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      }
          : <String, String>{'Access-Control-Allow-Origin': '*', 'Accept': '*/*', 'Content-Type': 'application/json; charset=UTF-8', 'Authorization': "Bearer ${DataManager().aratToken}"};
      final response = typeAPIMethod == TypeApiMethod.post
          ? await http.post(
        Uri.parse('$kHostURL/api/$path'),
        headers: headers,
        body: jsonEncode(body),
      )
          : (typeAPIMethod == TypeApiMethod.get ? await http.get(Uri.parse('$kHostURL/api/$path'), headers: headers) : await http.delete(Uri.parse('$kHostURL/api/$path'),body: jsonEncode(body), headers: headers));
      printDebug("callAPI Response ${response.request?.url}: ${response.statusCode} - '${response.body}'.");
      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 200) {
        try {
          if (jsonDecode(response.body) is Map) {
            Map data = jsonDecode(response.body) as Map<String, dynamic>;
            return {kMessage: data, kCode: response.statusCode};
          } else if (jsonDecode(response.body) is List) {
            List data = jsonDecode(response.body) as List;
            return {kMessage: data, kCode: response.statusCode};
          } else {
            return {kMessage: "Ok", kCode: response.statusCode};
          }
        } on FormatException catch (e) {
          return {kMessage: response.body, kCode: response.statusCode};
        }
      } else if (response.statusCode == 401 && DataManager().aratToken.isNotEmpty) {
        DataManager().aratToken = "";
        await refreshToken(context);
        return callAPI(context, path, typeAPI, body);
      } else {
        try {
          String message = "";
          if (jsonDecode(response.body) is Map && ((jsonDecode(response.body) as Map<String, dynamic>)["error"]).toString().isNotEmpty) {
            message = ((jsonDecode(response.body) as Map<String, dynamic>)["error"]) ?? "";
            if (message.isEmpty) {
              message = ((jsonDecode(response.body) as Map<String, dynamic>)["message"]) ?? "";
            }
          } else {
            message = response.body;
          }
          if (message.isNotEmpty) {
            return {kMessage: message, kCode: response.statusCode};
          } else {
            if (context != null && context.mounted) {
              showNotifyMessage(context, "Empty");
            }
            return {kMessage: "Empty", kCode: 404};
          }
        } on FormatException catch (e) {
          printDebug("callAPI $path: $e");
          return {kMessage: e.message, kCode: 502};
        }
      }
    } on SocketException catch (error) {
      if (context != null && context.mounted) {
        showNotifyMessage(context, "Đã có lỗi xảy ra, vui lòng thử lại sau");
      }
      printDebug("callAPI $path: $error");
      return {kMessage: error.message, kCode: 502};
    } on HandshakeException catch (error) {
      if (context != null && context.mounted) {
        showNotifyMessage(context, "Đã có lỗi xảy ra, vui lòng thử lại sau");
      }
      printDebug("callAPI $path: $error");
      return {kMessage: error.message, kCode: 503};
    } on http.ClientException catch (error) {
      if (context != null && context.mounted) {
        showNotifyMessage(context, "Đã có lỗi xảy ra, vui lòng thử lại sau");
      }
      printDebug("callAPI $path: $error");
      return {kMessage: error.message, kCode: 501};
    }
  }

  Future<void> refreshToken (BuildContext? context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userName = sharedPreferences.getString("username") ?? "";
    String pass = sharedPreferences.getString(userName.trim()) ?? "";
    userName = convertPhoneNumber(userName);
    printDebug("refreshToken: $userName - $pass");
    Map data = await callAPI(context, kAPILogin, TypeAPI.unknown,
        isValidEmail(userName) ? {kEmail: userName, kPassWord: generateMd5(pass, lenght: 16)} : {kPhoneNum: userName, kPassWord: generateMd5(pass, lenght: 16)});
    if (data[kCode] == 200) {
      parseAccountInfo(data[kMessage]);
    }
  }

  void updateUserInfo(BuildContext? context, String userName, Function callback) {
    callAPI(context, "updateUser", TypeAPI.unknown, {"username": userName}).then((data) => {
      if (data[kCode] == 200) {parseUserData(data[kMessage]), callback(true, null)} else {callback(false, data[kMessage])}
    });
  }

  void updateHomeInfo(BuildContext? context, String homeName, int homeId, Function callback) {
    callAPI(context, kUpdateHomeInfo, TypeAPI.unknown, {kId: homeId, kName: homeName}).then((data) => {
      if (data[kCode] == 200) {callback(true, null)} else {callback(false, data[kMessage])}
    });
  }

  void registerResetAccount(BuildContext? context, String userName, String password, String code, bool isResetPass, Function callback) {
    callAPI(
        context,
        isResetPass ? kAPIResetPass : kAPIRegister,
        TypeAPI.unknown,
        isValidEmail(userName)
            ? {kEmail: userName, kOtpCode: code, kPassWord: generateMd5(password, lenght: 16)}
            : {kPhoneNum: userName, kOtpCode: code, kPassWord: generateMd5(password, lenght: 16)})
        .then((data) => {
      if (data[kCode] == 200) {parseAccountInfo(data[kMessage]), callback(true, null)} else {callback(false, data[kMessage])}
    });
  }

  void parseAccountInfo(Map<String, dynamic> data) {
    if (data.containsKey(kToken) && (data[kToken] is String)) {
      DataManager().aratToken = data[kToken];
    }
    if (data.containsKey(kRefreshToken) && (data[kRefreshToken] is String)) {
      DataManager().aratRefreshToken = data[kRefreshToken];
    }
    DataManager().userModel = null;
    if (data.containsKey("user") && !mapEmpty(data["user"])) {
      DataManager().userModel = UserModel.fromJson(data["user"]);
    }
  }

  void getAllMenus(BuildContext? context, String dateTime, Function callBack) {
    callAPI(context, "menus?from=$dateTime&to=$dateTime", TypeAPI.getLogInfo, {}, typeAPIMethod: TypeApiMethod.get).then((value) => {
      if (value[kCode] == 200 && countListObject(value[kMessage]) > 0)
        {
          callBack((value[kMessage] as List? ?? [])
              .map((e) => MenuModel.fromJson(e))
              .toList())}
      else
        {callBack([])}
    });
  }

  void getMealReports(BuildContext? context, String dateTime, Function callBack) {
    callAPI(context, "mealReports?from=$dateTime&to=$dateTime", TypeAPI.getLogInfo, {}, typeAPIMethod: TypeApiMethod.get).then((value) => {
      if (value[kCode] == 200 && !mapEmpty(value[kMessage]) && countListObject(value[kMessage]["data"]) > 0)
        {
          callBack((value[kMessage]["data"] as List? ?? [])
              .map((e) => MealReportModel.fromJson(e))
              .toList())}
      else
        {callBack([])}
    });
  }

  void getDetailMealReports(BuildContext? context, int reportId, Function callBack) {
    callAPI(context, "mealReports/$reportId", TypeAPI.getLogInfo, {}, typeAPIMethod: TypeApiMethod.get).then((value) => {
      if (value[kCode] == 200 && !mapEmpty(value[kMessage]))
        {
          callBack(MealReportModel.fromJson(value[kMessage]))}
      else
        {callBack(null)}
    });
  }

  void requestMeal(BuildContext? context, String meal, String dateTime, int quantity, Function callBack) {
    callAPI(context, "mealReports/report", TypeAPI.getLogInfo, {"meal": meal,"reportDate" : dateTime, "quantity" : quantity}).then((value) => {
      if (value[kCode] == 200 && !mapEmpty(value[kMessage]))
        {
          callBack(MealReportModel.fromJson(value[kMessage]))}
      else
        {callBack(null)}
    });
  }

  void updateMeal(BuildContext? context,int requestId, Map<String, dynamic> updateMeal, Function callBack) {
    callAPI(context, "mealReports/$requestId", TypeAPI.getLogInfo, updateMeal).then((value) => {
      if (value[kCode] == 200 && !mapEmpty(value[kMessage]))
        {
          callBack(MealReportModel.fromJson(value[kMessage]))}
      else
        {callBack(null)}
    });
  }

  void confirmMeal(BuildContext? context,int requestId, Map<String, dynamic> updateMeal, Function callBack) {
    callAPI(context, "mealReports/confirm/$requestId", TypeAPI.getLogInfo, updateMeal).then((value) => {
      if (value[kCode] == 200 && !mapEmpty(value[kMessage]))
        {
          callBack(MealReportModel.fromJson(value[kMessage]))}
      else
        {callBack(null)}
    });
  }

  void deleteMeal(BuildContext? context,int requestId, Function callBack) {
    callAPI(context, "mealReports/$requestId", TypeAPI.getLogInfo, {},typeAPIMethod: TypeApiMethod.delete).then((value) => {
      callBack(value[kCode] == 200)
    });
  }

  void detailMealRequest(BuildContext? context, int reportId, Function callBack) {
    callAPI(context, "mealReports/$reportId", TypeAPI.getLogInfo, {}, typeAPIMethod: TypeApiMethod.get).then((value) => {
      printDebug("Context: $context - ${context?.mounted}"),
      if (context?.mounted ?? false)
        {
          if (value[kCode] == 200 && !mapEmpty(value[kMessage]))
            {
              callBack(MealReportModel.fromJson(value[kMessage]))}
          else
            {callBack(null)}
        } else {
        OverlayLoadingProgress.stop()
      }
    });
  }

  void parseUserData(Map<String, dynamic> mapUser) {
    if (mapUser.containsKey(kUserName) && (mapUser[kUserName] is String)) {
      DataManager().userName = mapUser[kUserName];
    }
    printDebug("parseUser: $mapUser - ${DataManager().userName}");
    if (mapUser.containsKey(kEmail) && (mapUser[kEmail] is String)) {
      DataManager().userAccount = mapUser[kEmail];
    } else if (mapUser.containsKey(kPhoneNum) && (mapUser[kPhoneNum] is String)) {
      DataManager().userAccount = mapUser[kPhoneNum];
    }
    if (mapUser.containsKey(kId) && (mapUser[kId] is int)) {
      DataManager().userId = mapUser[kId];
    }
  }

  void loginAccount(BuildContext? context, String userName, String password, Function callback) {
    printDebug("refreshToken loginAccount: $userName - $password");
    callAPI(context, kAPILogin, TypeAPI.unknown,
        {kUsername: userName, kPassWord: password})
        .then((data) => {
      if (data[kCode] == 200) {parseAccountInfo(data[kMessage]), callback(true, null)} else {callback(false, data[kMessage])}
    });
  }

  void requestCodeOTP(BuildContext? context, String userName, Function callback, {bool isResetPass = false}) {
    Map<String, dynamic> mapData = isValidEmail(userName) ? {kEmail: userName} : {kPhoneNum: userName};
    mapData["checkUserExist"] = isResetPass;
    callAPI(context, kAPIRequestOTP, TypeAPI.unknown, mapData).then((data) => {callback(data[kCode] == 200,data[kMessage])});
  }

  Future<void> deleteAccount(BuildContext? context, Function callback, String oldAccount) async {
    callAPI(
      context,
      kAPIUserHomeInfo,
      TypeAPI.deleteAccount,
      {
        kUserDetail: {kName: oldAccount},
      },
    ).then((value) => {
      if (value[kCode] == 200 && value[kMessage] != null) {callback(true)} else {callback(false)}
    });
  }

  void handleToken(BuildContext? context, Map<String, dynamic> value, Function callback) {
    Map<String, dynamic>? tokenInfo;
    if (value.containsKey(kMessage) && value[kMessage] is Map) {
      try {
        tokenInfo = value[kMessage];
        if (tokenInfo != null && tokenInfo[kToken] != null && tokenInfo["refreshtoken"] != null) {
          DataManager().aratToken = tokenInfo[kToken];
          DataManager().aratRefreshToken = tokenInfo["refreshtoken"];
          callback(true);
        } else {
          callback(false);
        }
      } catch (e) {
        callback(false);
      }
    } else if (context != null) {
      callback(false);
    } else {
      callback(false);
    }
  }

  void updatePassPhone(BuildContext? context, String phoneNUmber, String uuid, String password, Function callback) {
    APIManager()
        .callAPI(context, "updatePhone", TypeAPI.getUserHome, {kId: convertPhoneNumber(phoneNUmber).replaceFirst("+", ""), kUserId: uuid, kHomeID: password}, sender: "Mobile")
        .then((value) => {handleToken(context, value, callback)});
  }

  void updateNameInfo(BuildContext? context, String id, String newName, TypeAPI typeAPI, Function callback) {
    // callAPI(context, kAPIName, typeAPI, {kHomeID: DataManager().homeModel.homeID, kId: id}, sender: newName).then((value) => {
    //   if (value[kCode] == 200 && !mapEmpty(value[kMessage])) {callback(true)} else {callback(false)}
    // });
  }
}

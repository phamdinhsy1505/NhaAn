import 'dart:convert';
import 'dart:io';
// import 'package:platform_device_id_v2/platform_device_id_v2.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nhakhach/Data/DataModel.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Account/LoginScreen.dart';
import 'Constants.dart';
import 'Functions.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  static const _key = 'secure_ario_unique_id';
  static const _storage = FlutterSecureStorage();
  int userId = 0;
  String userName = "";
  String userAccount = "";
  bool isTablet = false;
  String verificationIdPhone = "";
  bool isNewUser = false;
  int widthDevice = 600;
  int numberCell = 2;
  int totalTime = 0;
  bool isConfigHC = false;
  bool isShowOverlayLoading = false;
  SettingMode settingMode = SettingMode.normal;
  bool isShowingMessage = false;
  bool isShowPopupScene = false;
  bool isTurnNotify = true;
  bool isTurnVibrate = true;
  bool is3DMode = true;
  BuildContext? currentContext;
  String uuidPhone = "mobile";
  String namePhone = "mobile";
  String aratToken = "";
  String aratRefreshToken = "";
  String firebaseMessageToken = "";
  bool isLoadingData = false;
  bool isHasNetwork = true;
  UserModel? userModel;

  factory DataManager() {
    return _instance;
  }

  Future<void> logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DataManager().logoutData();
    await prefs.setBool("isLogout", true);
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (BuildContext context) => const LoginScreen(),
    ));
  }

  Future<void> logoutData() async {
    DataManager().aratToken = "";
    DataManager().aratRefreshToken = "";
  }

  DataManager._internal() {}
}

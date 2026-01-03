import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/OverlayLoadingProgress.dart';
import '../Data/APIManager.dart';
import '../Data/Constants.dart';
import '../Data/DataManager.dart';
import '../Data/Functions.dart';
import 'OTPScreen.dart';

class ChangePassScreen extends StatefulWidget {
  const ChangePassScreen({super.key});

  @override
  _ChangePassScreenState createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  bool passwdVisible = false;
  bool passwdVisible1 = false;
  bool show = false;
  bool isValidButton = false;
  double widthForm = 250;
  double widthTap = 150;
  OtpFieldController otpbox = OtpFieldController();
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController cfpassController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      autoFillData();
    });
  }

  Future<void> autoFillData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userName = sharedPreferences.getString("username");
    if (!stringEmpty(userName)) {
      userController.text = userName ?? "";
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int width = max(300, MediaQuery.of(context).size.shortestSide.toInt());
    widthForm = width - 60;
    widthTap = width / 2 - 30;
    printDebug("Login Build: $widthForm");
    DataManager().currentContext = context;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.fill),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, bottom: 10, right: 16, top: 90),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "assets/logo_red.png",
                    width: 80,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      "Vanlock Smart",
                      style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(left: 12.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE2E2E2), width: 0.33),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurStyle: BlurStyle.outer,
                                    spreadRadius: 1)
                              ]),
                          child: TextField(
                            obscureText: passwdVisible ? false : true,
                            controller: passController,
                            onChanged: (newValue) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    "Mật khẩu mới",
                                hintStyle: const TextStyle(
                                    height: 1.3,
                                    color: Colors.grey,
                                    fontSize: kSizeTextNormal),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwdVisible = !passwdVisible;
                                    });
                                  },
                                  icon: passwdVisible
                                      ? const Icon(
                                          Icons.visibility_outlined,
                                          color: Colors.black,
                                          size: 20,
                                        )
                                      : const Icon(
                                          Icons.visibility_off_outlined,
                                          color: Colors.black,
                                          size: 20),
                                  style: IconButton.styleFrom(
                                      foregroundColor: kBgGreyColor),
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 12.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE2E2E2), width: 0.33),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurStyle: BlurStyle.outer,
                                    spreadRadius: 1)
                              ]),
                          child: TextField(
                            controller: cfpassController,
                            obscureText: passwdVisible1 ? false : true,
                            onChanged: (newValue) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Nhập lại mật khẩu",
                              hintStyle: const TextStyle(
                                  height: 1.3,
                                  color: Colors.grey,
                                  fontSize: kSizeTextNormal),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passwdVisible1 = !passwdVisible1;
                                  });
                                },
                                icon: passwdVisible1
                                    ? const Icon(Icons.visibility_outlined,
                                        color: Colors.black, size: 20)
                                    : const Icon(
                                        Icons.visibility_off_outlined,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                style: IconButton.styleFrom(
                                    foregroundColor: kBgGreyColor),
                              ),
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Mật khẩu quá dễ",
                              style: TextStyle(
                                  color: kMainColor, fontSize: kSizeTextNormal),
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // email va sdt
                  containerGradient(
                    width: widthForm,
                    TextButton(
                      onPressed: () {
                        if (isValidPassword(passController.text.trim())) {
                          if (passController.text.trim() != cfpassController.text.trim()) {
                            showNotifyMessage(
                                context,
                                "Mật khẩu không trùng khớp");
                          } else {
                            sendCodePhone();
                          }
                        } else {
                          showNotifyMessage(
                              context,
                              "Chưa nhập mật khẩu");
                        }
                      },
                      child: Text(
                        "Đổi mật khẩu",
                        style: TextStyle(
                            height: 1.3,
                            color: isValidParam()
                                // (isValidButton || isValidButtonPass || isValidButtonCfPass)
                                ? Colors.white
                                : const Color(0x80FFFFFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.transparent,
              height: 60, // set fixed height để tránh lỗi layout
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isValidParam() {
    if (!isValidEmail(userController.text.trim()) &&
        !isValidPhone(userController.text.trim())) {
      return false;
    }
    return passController.text.trim() == cfpassController.text.trim() &&
        isValidPassword(passController.text.trim());
  }

  void sendCodePhone() {
    OverlayLoadingProgress.start(context);
    APIManager().requestCodeOTP(
        context, convertPhoneNumber(userController.text.trim()), (isSuccess, message) {
      OverlayLoadingProgress.stop();
      if (isSuccess) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => OTPScreen(
              typeScreen: TypeLogin.forgotPass,
              userName: convertPhoneNumber(userController.text.trim()),
              passWord: passController.text.trim(),
              callBack: () {
                Navigator.of(context).pop();
                saveUserNamePass();
              },
            ),
          ),
        );
      } else {
        showNotifyMessage(context, message);
      }
    }, isResetPass: true);
  }

  Future<void> saveUserNamePass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogout", false);
    await prefs.setString("username",
        convertPhoneNumber(userController.text.trim()).replaceFirst("+", ""));
    await prefs.setString(
        convertPhoneNumber(userController.text.trim()).replaceFirst("+", ""),
        passController.text.trim());
  }
}

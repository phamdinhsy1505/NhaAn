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
import '../TabbarScreen.dart';
import 'OTPScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TypeLogin typeScreen = TypeLogin.login;
  bool passwdVisible = false;
  bool passwdVisible1 = false;
  bool show = false;
  int validState = 0;
  double widthForm = 250;
  double widthTap = 150;
  OtpFieldController otpbox = OtpFieldController();
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController cfpassController = TextEditingController();
  bool isLoading = false;
  bool isGotoHome = false;
  // final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _focusNode.addListener(_onFocusChange);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      autoFillData();
    });
  }

  Future<void> autoFillData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isLogout = sharedPreferences.getBool("isLogout") ?? false;
    if (!isLogout) {
      String? userName = sharedPreferences.getString("username");
      if (!stringEmpty(userName)) {
        passController.text = sharedPreferences.getString(userName!.trim()) ?? "";
        userController.text = userName;
        loginUserPassword();
      }
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.fill),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 10, right: 16, top: 90),
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
                      style: TextStyle(color: Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.bold, fontSize: 18),
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
                              border: Border.all(color: const Color(0xFFE2E2E2), width: 0.33),
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurStyle: BlurStyle.outer, spreadRadius: 1)]),
                          child: TypeAheadField<String>(
                            key: _textFieldKey,
                            suggestionsCallback: (search) => getListUserName(search),
                            builder: (context, controller, focusNode) {
                              if (userController.text.isNotEmpty) {
                                controller.text = userController.text;
                              }
                              userController = controller;
                              return TextField(
                                focusNode: focusNode,
                                controller: userController,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (newValue) {
                                  if (isValidParam() != validState && userController.text.trim().isNotEmpty) {
                                    validState = isValidParam();
                                  }
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Nhập email hoặc SĐT",
                                    hintStyle: const TextStyle(height: 1.3, color: Colors.grey, fontSize: kSizeTextNormal)),
                              );
                            },
                            itemBuilder: (context, username) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  username,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              );
                            },
                            hideOnEmpty: true,
                            onSelected: (userName) {
                              setState(() {
                                userController.text = userName;
                                getPassUserName(userName);
                                validState = -1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 12.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E2E2), width: 0.33),
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurStyle: BlurStyle.outer, spreadRadius: 1)]),
                          child: TextField(
                            obscureText: passwdVisible ? false : true,
                            controller: passController,
                            onChanged: (newValue) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: typeScreen != TypeLogin.forgotPass ? "Mật khẩu" : "Nhập lại mật khẩu",
                                hintStyle: const TextStyle(height: 1.3, color: Colors.grey, fontSize: kSizeTextNormal),
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
                                      : const Icon(Icons.visibility_off_outlined, color: Colors.black, size: 20),
                                  style: IconButton.styleFrom(foregroundColor: kBgGreyColor),
                                )),
                          ),
                        ),
                        if (typeScreen != TypeLogin.login)
                          const SizedBox(
                            height: 15,
                          ),
                        if (typeScreen != TypeLogin.login)
                          Container(
                            padding: const EdgeInsets.only(left: 12.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E2E2), width: 0.33),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurStyle: BlurStyle.outer, spreadRadius: 1)]),
                            child: TextField(
                              controller: cfpassController,
                              obscureText: passwdVisible1 ? false : true,
                              onChanged: (newValue) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: typeScreen != TypeLogin.forgotPass ? "Mật khẩu mới" : "Nhập lại mật khẩu",
                                hintStyle: const TextStyle(height: 1.3, color: Colors.grey, fontSize: kSizeTextNormal),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwdVisible1 = !passwdVisible1;
                                    });
                                  },
                                  icon: passwdVisible1
                                      ? const Icon(Icons.visibility_outlined, color: Colors.black, size: 20)
                                      : const Icon(
                                          Icons.visibility_off_outlined,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                  style: IconButton.styleFrom(foregroundColor: kBgGreyColor),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text( "Mật khẩu quá dễ, vui lòng đổi mật khẩu khác.", style: TextStyle(color: kMainColor, fontSize: kSizeTextNormal),)),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              clearText();
                              if (typeScreen == TypeLogin.forgotPass) {
                                typeScreen = TypeLogin.register;
                              } else {
                                typeScreen = TypeLogin.forgotPass;
                              }
                            });
                          },
                          child: Text(
                            typeScreen == TypeLogin.forgotPass ? "Đăng ký?" : "Quên mật khẩu",
                            style: const TextStyle(height: 1.3, color: kMainColor),
                          )),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              clearText();
                              if (typeScreen == TypeLogin.login) {
                                typeScreen = TypeLogin.register;
                              } else {
                                typeScreen = TypeLogin.login;
                              }
                            });
                          },
                          child: Text(
                            typeScreen == TypeLogin.login ? "Đăng ký" : "Đăng nhập",
                            style: const TextStyle(height: 1.3, color: kMainColor),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // email va sdt
                  containerGradient(
                    width: widthForm,
                    TextButton(
                      onPressed: () {
                        validState = isValidParam();
                        if (validState == -1) {
                          if (typeScreen == TypeLogin.login) {
                            loginUserPassword();
                          } else {
                            sendCodePhone();
                          }
                        } else {
                          List<String> listMessageValid = ["Chưa nhập tên đăng nhập", "Chưa nhập Mật khẩu", "Mật khẩu không trùng khớp"];
                          showNotifyMessage(context, listMessageValid[validState]);
                        }
                      },
                      child: Text(
                        typeScreen == TypeLogin.login
                            ? "Đăng nhập"
                            : (typeScreen == TypeLogin.register ? "Đăng ký" : "Quên mật khẩu"),
                        style: TextStyle(
                            height: 1.3,
                            color: isValidParam() == -1
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
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        kVersionInfo,
                        style: TextStyle(height: 1.3, decoration: TextDecoration.none, color: Colors.grey),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void clearText() {
    setState(() {
      userController.text = "";
      passController.text = "";
      cfpassController.text = "";
      validState = 0;
    });
  }

  int isValidParam() {
    if (!isValidEmail(userController.text.trim()) && !isValidPhone(userController.text.trim())) {
      return 0;
    }
    bool isValidPass = isValidPassword(passController.text.trim());
    if (typeScreen == TypeLogin.login) {
      return isValidPass ? -1 : 1;
    }
    if (isValidPass) {
      return passController.text.trim() == cfpassController.text.trim() ? -1 : 2;
    } else {
      return 1;
    }
  }

  void sendCodePhone() {
    OverlayLoadingProgress.start(context);
    APIManager().requestCodeOTP(context, convertPhoneNumber(userController.text.trim()), (isSuccess, message) {
      OverlayLoadingProgress.stop();
      if (isSuccess) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => OTPScreen(
              typeScreen: typeScreen,
              userName: convertPhoneNumber(userController.text.trim()),
              passWord: passController.text.trim(),
              callBack: () {
                setState(() {
                  typeScreen = TypeLogin.login;
                });
              },
            ),
          ),
        );
      } else {
        showNotifyMessage(context, message);
      }
    }, isResetPass: typeScreen == TypeLogin.forgotPass);
  }

  Future<List<String>> getListUserName(String currentUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? listAccounts = prefs.getStringList("listAccounts");
    if (listAccounts == null) {
      return [];
    }
    List<String> listRefersUsername = [];
    for (String users in listAccounts) {
      if (currentUserName.isEmpty || users.toLowerCase().contains(currentUserName.toLowerCase())) {
        listRefersUsername.add(users);
      }
    }
    return listRefersUsername;
  }

  Future<void> saveListUserName(String userName) async {
    if (userName.length <= 8) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? listAccounts = prefs.getStringList("listAccounts");
    if (!(listAccounts?.contains(userName) ?? false)) {
      List<String> newListAccounts = [];
      if (listAccounts == null) {
        newListAccounts = [userName];
      } else {
        newListAccounts = listAccounts;
        if (newListAccounts.length == 5) {
          newListAccounts.removeAt(4);
        }
        newListAccounts.insert(0, userName);
      }
      await prefs.setStringList("listAccounts", newListAccounts);
    }
  }

  Future<void> saveUserNamePass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogout", false);
    await prefs.setString("username", convertPhoneNumber(userController.text.trim()).replaceFirst("+", ""));
    await prefs.setString(convertPhoneNumber(userController.text.trim()).replaceFirst("+", ""), passController.text.trim());
  }

  void getPassUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      passController.text = prefs.getString(userName.trim()) ?? "";
    });
  }

  Future<void> loginUserPassword() async {
    OverlayLoadingProgress.start(context);
    APIManager().loginAccount(context, convertPhoneNumber(userController.text.trim()), passController.text.trim(), (isSuccess, message) {
      OverlayLoadingProgress.stop();
      if (isSuccess) {
        saveUserNamePass();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const TabbarScreen(),
          ),
        );
      } else {
        showNotifyMessage(context, message);
      }
    });
  }
}

import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import '../Data/DataManager.dart';
import '../Data/APIManager.dart';
import '../Common/OverlayLoadingProgress.dart';
import '../Data/Constants.dart';
import '../Data/Functions.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({
    super.key,
    required this.userName,
    required this.passWord,
    required this.typeScreen,
    this.callBack,
  });

  final String userName;
  final String passWord;
  final TypeLogin typeScreen;
  final Function? callBack;

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  OtpFieldController otpbox = OtpFieldController();

  @override
  Widget build(BuildContext context) {
    printDebug("Login Build");
    DataManager().currentContext = context;
    double widthForm = MediaQuery.of(context).size.shortestSide.toInt() - 60;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(widget.typeScreen == TypeLogin.register ? "Đăng ký" : "Quên mật khẩu"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 24,
                ),
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
                Text(
                  "Nhập mã từ: ${widget.userName}",
                  style: const TextStyle(
                    height: 1.3,
                    fontSize: kSizeTextTitle,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16, left: 10, right: 10),
                  child: OTPTextField(
                    controller: otpbox,
                    length: 6,
                    width: MediaQuery.of(context).size.shortestSide.toInt() - 32,
                    fieldWidth: 40,
                    style: const TextStyle(height: 1.3, fontSize: 20, fontWeight: FontWeight.bold),
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldStyle: FieldStyle.box,
                    onChanged: (value) {
                      printDebug("Entered OTP onChanged value: $value");
                    },
                    onCompleted: (pin) {
                      printDebug("Entered OTP Code: $pin");
                      signInCode(pin);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> signInCode(String pin) async {
    OverlayLoadingProgress.start(context);
    APIManager().registerResetAccount(context, widget.userName, widget.passWord, pin, widget.typeScreen == TypeLogin.forgotPass, (isSuccess, message) {
      OverlayLoadingProgress.stop();
      if (isSuccess) {
        Navigator.of(context).pop();
        if (widget.callBack != null) {
          widget.callBack!();
        }
      } else {
        showNotifyMessage(context, message);
      }
    });
  }
}

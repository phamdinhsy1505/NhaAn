import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/ExtensionWidget.dart';
import '../Common/OverlayLoadingProgress.dart';
import '../Common/Picker/sheet.dart';
import '../Common/Picker/time_picker.dart';
import '../Common/notification_center.dart';
import 'package:app_settings/app_settings.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'APIManager.dart';
import 'Constants.dart';
import 'DataManager.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

LinearGradient getStateLinear(bool isTurnOn) {
  return LinearGradient(
    colors: isTurnOn
        ? <Color>[Colors.red, Colors.redAccent]
        : <Color>[const Color(0xFF00D6C6), const Color(0xFF4CBED7)],
  );
}

Container containerGradient(Widget child,
    {double height = 50,
    double width = 0,
    double radius = 0,
    Color color = kMainColor}) {
  if (radius == 0 && height != 0) {
    radius = height / 2;
  }
  return Container(
    height: height == 0 ? null : height,
    width: width == 0 ? null : width,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    ),
    child: child,
  );
}

void printDebug(String message) {
  // if (kDebugMode) {
  DateTime now = DateTime.now();
  String formattedTime =
      "${now.hour}:${now.minute}:${now.second}:${now.millisecond}";
  print("\n$formattedTime: printDebug $message\n");
  // }
}

bool isURLValid(String? text) {
  return text != null &&
      text.length > 5 &&
      RegExp(r'(http?|https|rtsp)://(?:www\.)?\S+(?:/|\b)').hasMatch(text);
}

Widget getContainer(String title, String? des, Function? callBack,
    {Widget? detail, Widget? left}) {
  return containerBorder(
      Padding(
        padding: EdgeInsets.fromLTRB(left != null ? 0 : 16, 0, 16, 0),
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              if (left != null) left,
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          height: 1.3,
                          color: Colors.black,
                          fontSize: kSizeTextTitle,
                          overflow: TextOverflow.ellipsis))),
              if (!stringEmpty(des))
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    Text(des!,
                        style: const TextStyle(
                            height: 1.3,
                            color: Colors.black,
                            fontSize: kSizeTextTitle))
                  ],
                ),
              if (detail != null)
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    detail
                  ],
                )
            ],
          ),
        ),
      ),
      callBack,
      height: 0,
      color: Colors.white);
}

GestureDetector containerBorder(Widget child, Function? callBack,
    {Color color = Colors.white,
    double radius = 16,
    double height = 50,
    double width = 0,
    Color borderColor = Colors.white,
    bool isShadow = true,
    bool isNoneMargin = false,
    double widthShadow = 2}) {
  return GestureDetector(
    onTap: () {
      if (callBack != null) {
        callBack();
      }
    },
    child: Container(
      height: height == 0 ? null : height,
      width: width == 0 ? null : width,
      margin: isNoneMargin ? null : EdgeInsets.all(widthShadow),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        boxShadow: isShadow
            ? [
                BoxShadow(
                  color: borderColor,
                  spreadRadius: widthShadow,
                  // blurRadius: 7,
                  offset: const Offset(0, 0), // changes position of shadow
                ),
              ]
            : null,
      ),
      child: child,
    ),
  );
}

T? cast<T>(x) => x is T ? x : null;

void addObjectToList(List<dynamic>? listObjects, dynamic newObj) {
  if (countListObject(listObjects) == 0) {
    listObjects = [newObj];
  } else {
    listObjects!.add(newObj);
  }
}

String stripVN(String str) {
  String input = str.toLowerCase();
  List<List<String>> withDia = [
    [
      'à',
      'á',
      'ạ',
      'ả',
      'ã',
      'â',
      'ầ',
      'ấ',
      'ậ',
      'ẩ',
      'ẫ',
      'ă',
      'ằ',
      'ắ',
      'ặ',
      'ẳ',
      'ẵ'
    ],
    ['è', 'é', 'ẹ', 'ẻ', 'ẽ', 'ê', 'ề', 'ế', 'ệ', 'ể', 'ễ'],
    ['ì', 'í', 'ị', 'ỉ', 'ĩ'],
    [
      'ò',
      'ó',
      'ọ',
      'ỏ',
      'õ',
      'ô',
      'ồ',
      'ố',
      'ộ',
      'ổ',
      'ỗ',
      'ơ',
      'ờ',
      'ớ',
      'ợ',
      'ở',
      'ỡ'
    ],
    ['ù', 'ú', 'ụ', 'ủ', 'ũ', 'ư', 'ừ', 'ứ', 'ự', 'ử', 'ữ'],
    ['ỳ', 'ý', 'ỵ', 'ỷ', 'ỹ'],
    ['đ']
  ];
  List<String> withoutDia = ['a', 'e', 'i', 'o', 'u', 'y', 'd'];
  for (int i = 0; i < withDia.length; i++) {
    for (int j = 0; j < withDia[i].length; j++) {
      input = input.replaceAll(withDia[i][j], withoutDia[i]);
    }
  }
  String newInput = input.replaceAll(RegExp(r'[^\w\s]+'), '');
  newInput = newInput.replaceAll("  ", " ");
  printDebug("newInput: $newInput");
  return newInput;
}

String generateMd5(String input, {int lenght = 32, String padRightStr = "0"}) {
  String output = md5.convert(utf8.encode(input)).toString();
  if (output.length < lenght) {
    output = output.substring(0, lenght - 1);
    output = output.padRight(lenght, padRightStr);
  } else {
    output = output.substring(0, lenght);
  }
  return output;
}

bool isValidPassword(String password) {
  final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,32}$');
  return regex.hasMatch(password);
}

bool isValidEmail(String? email) {
  if (email != null && email.isNotEmpty) {
    return email.length >= 5 &&
        RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email);
  }
  return false;
}

String convertPhoneNumber(String phoneNumber) {
  return phoneNumber;
  // if (isValidEmail(phoneNumber)) {
  //   return phoneNumber;
  // }
  // if (phoneNumber[0] == "+") {
  //   return phoneNumber;
  // } else {
  //   if (phoneNumber[0] == '0') {
  //     return phoneNumber.replaceFirst('0', '+84');
  //   } else if (phoneNumber.substring(0, 2) == '84') {
  //     return "+$phoneNumber";
  //   } else {
  //     return "+84$phoneNumber";
  //   }
  // }
}

bool isValidPhone(String? phone) {
  if (phone != null && phone.isNotEmpty) {
    return RegExp(r"^(0|84|\+84)[0-9]{9,10}$").hasMatch(phone);
  }
  return false;
}

void showAlertDialog(String titleMessage, List<String> actionsTitle,
    Function(int) callBack, BuildContext context,
    {bool isHasCancel = true}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 296,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 16, bottom: 4),
                      child: Text(titleMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              height: 1.3,
                              color: Colors.black,
                              fontSize: kSizeTextTitle,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: (actionsTitle.length == 1 && isHasCancel)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: kSubColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24)),
                                        ),
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Huỷ bỏ",
                                              style: const TextStyle(
                                                  height: 1.3,
                                                  color: kMainColor,
                                                  fontSize: kSizeTextNormal,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            )),
                                      )),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: kMainColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(24)),
                                        ),
                                        height: 48,
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              callBack(0);
                                            },
                                            child: Text(
                                              actionsTitle[0],
                                              style: const TextStyle(
                                                  height: 1.3,
                                                  color: Colors.white,
                                                  fontSize: kSizeTextNormal,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            )),
                                      )),
                                ],
                              )
                            : Column(
                                children: [
                                  ...List.generate(
                                    actionsTitle.length,
                                    (index) => Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                                child: Container(
                                              // width: 120,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: kSubColor,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(24)),
                                              ),
                                              child: TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    callBack(index);
                                                  },
                                                  child: Text(
                                                    actionsTitle[index],
                                                    style: const TextStyle(
                                                        height: 1.3,
                                                        color: kMainColor,
                                                        fontSize:
                                                            kSizeTextTitle,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  )),
                                            )),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        )
                                      ],
                                    ),
                                  ),
                                  if (isHasCancel)
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  if (isHasCancel)
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                            child: Container(
                                          decoration: const BoxDecoration(
                                            color: kMainColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(24)),
                                          ),
                                          height: 48,
                                          child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                "Huỷ bỏ",
                                                style: const TextStyle(
                                                    height: 1.3,
                                                    color: Colors.white,
                                                    fontSize: kSizeTextTitle,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              )),
                                        ))
                                      ],
                                    ),
                                ],
                              ))
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void showAlertListInputDialog(BuildContext context, List<String> currentValues,
    Function(List<String>?, int) callBack,
    {String? titleMessage,
    List<String> hintMessages = const [],
    String? agreeTitle,
    int maxLength = 50,
    List<String> listButtons = const [],
    String? warning}) {
  double heightTextField = maxLength == 0 ? 48 : 78;
  titleMessage ??= "Nhập tên";
  List<String> newValues = List.from(currentValues);
  List<TextEditingController> newValueControllers = List.generate(
      newValues.length,
      (index) => TextEditingController(text: newValues[index]));
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: containerBorder(
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 8, bottom: 0),
                          child: Text(titleMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  height: 1.3,
                                  color: Colors.black,
                                  fontSize: kSizeTextTitle,
                                  fontWeight: FontWeight.bold)),
                        ),
                        if (warning != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 0),
                            child: Text(warning,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    height: 1.3,
                                    color: kMainColor,
                                    fontSize: kSizeTextTitle,
                                    fontWeight: FontWeight.bold)),
                          ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...List.generate(
                                  newValues.length,
                                  (index) => Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          height: heightTextField,
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(16))),
                                          child: TextField(
                                              // controller: TextEditingController(text: newValues[index]),
                                              controller: newValueControllers[
                                                  index],
                                              obscureText: false,
                                              maxLength: maxLength == 0
                                                  ? null
                                                  : maxLength,
                                              onChanged: (newValue) {
                                                newValues[index] = newValue;
                                              },
                                              decoration: InputDecoration(
                                                  fillColor: kBgGreyColor,
                                                  filled: true,
                                                  isDense: true,
                                                  border:
                                                      const OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          24)),
                                                          borderSide:
                                                              BorderSide.none),
                                                  hintText:
                                                      hintMessages.isEmpty
                                                          ? "Nhập tên"
                                                          : hintMessages[index],
                                                  hintStyle: const TextStyle(
                                                      height: 1.3,
                                                      color: kDisMainColor))),
                                        ),
                                      )),
                              // const Spacer(),
                              const SizedBox(
                                height: 10,
                              ),
                              if (listButtons.isEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: kSubColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(24)),
                                      ),
                                      child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            callBack(null, -1);
                                          },
                                          child: Text(
                                            "Huỷ bỏ",
                                            style: const TextStyle(
                                                height: 1.3,
                                                color: kMainColor,
                                                fontSize: kSizeTextTitle,
                                                fontWeight: FontWeight.normal),
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: kMainColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(24)),
                                      ),
                                      width: 120,
                                      height: 48,
                                      child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            callBack(newValues, 0);
                                          },
                                          child: Text(
                                            agreeTitle ??
                                                "Đồng ý",
                                            style: const TextStyle(
                                                height: 1.3,
                                                color: Colors.white,
                                                fontSize: kSizeTextTitle,
                                                fontWeight: FontWeight.normal),
                                          )),
                                    ),
                                  ],
                                ),
                              if (listButtons.isNotEmpty)
                                ...List.generate(
                                    listButtons.length,
                                    (index) => Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            height: heightTextField,
                                            decoration: BoxDecoration(
                                                color: index !=
                                                        listButtons.length - 1
                                                    ? kMainColor
                                                    : kSubColor,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(16))),
                                            child: TextButton(
                                              child: Text(
                                                index != listButtons.length - 1
                                                    ? listButtons[index]
                                                    : "Huỷ bỏ",
                                                style: TextStyle(
                                                    height: 1.3,
                                                    color: index !=
                                                            listButtons.length -
                                                                1
                                                        ? Colors.white
                                                        : kMainColor,
                                                    fontSize: kSizeTextTitle,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                callBack(newValues, index - 1);
                                              },
                                            ),
                                          ),
                                        )),
                            ],
                          ),
                        ))
                      ],
                    ),
                    null,
                    radius: 24,
                    height: 165 +
                        heightTextField *
                            (listButtons.length + newValues.length),
                    width: 296),
              ),
            ),
          );
        },
      );
    },
  );
}

void showAlertListSliderDialog(
    BuildContext context,
    List<int> listMin,
    List<int> listMax,
    List<int> currentValues,
    List<String> hintMessages,
    Function(List<int>?) callBack,
    {String? titleMessage,
    String? agreeTitle,
    bool isSlide = true}) {
  titleMessage ??= "";
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Map<int, Widget>? mapSegment = {};
          if (!isSlide) {
            for (int i = listMin[0]; i < listMax[0]; i++) {
              mapSegment[i] = Container(
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  hintMessages[i],
                  style: TextStyle(
                      height: 1.3,
                      color:
                          currentValues[0] == i ? Colors.white : Colors.black,
                      fontSize: kSizeTextTitle,
                      decoration: TextDecoration.none),
                ),
              );
            }
          }
          return Dialog(
            child: IntrinsicHeight(
              child: containerBorder(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 8, bottom: 8),
                        child: Text(titleMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                height: 1.3,
                                color: Colors.black,
                                fontSize: kSizeTextTitle,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Column(
                                children: [
                                  if (isSlide)
                                    ...List.generate(
                                        currentValues.length,
                                        (index) => Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: Container(
                                                height: 48,
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16))),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        "${hintMessages[index]} ${currentValues[index]}",
                                                        style: const TextStyle(
                                                            height: 1.3,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            fontSize:
                                                                kSizeTextNormal),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Material(
                                                      color: Colors.transparent,
                                                      child: Slider(
                                                          value: currentValues[
                                                                  index]
                                                              .toDouble(),
                                                          min: listMin[index]
                                                              .toDouble(),
                                                          max: listMax[index]
                                                              .toDouble(),
                                                          activeColor:
                                                              kMainColor,
                                                          onChanged:
                                                              (newValue) {
                                                            setState(() {
                                                              currentValues[
                                                                      index] =
                                                                  newValue
                                                                      .toInt();
                                                            });
                                                          }),
                                                    ))
                                                  ],
                                                ),
                                              ),
                                            )),
                                  if (!isSlide)
                                    Align(
                                      alignment: Alignment.center,
                                      child: containerBorder(
                                          CupertinoSlidingSegmentedControl(
                                              children: mapSegment,
                                              thumbColor: kMainColor,
                                              groupValue: currentValues[0],
                                              backgroundColor:
                                                  Colors.transparent,
                                              onValueChanged: (value) {
                                                printDebug(
                                                    "Segment selected: $value");
                                                if (value != null) {
                                                  setState(() {
                                                    currentValues[0] = value;
                                                  });
                                                }
                                              }),
                                          null,
                                          width: 220,
                                          height: 36,
                                          isNoneMargin: true,
                                          color: kBgGreyColor,
                                          radius: 8,
                                          isShadow: false),
                                    ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: kSubColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24)),
                                        ),
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              callBack(null);
                                            },
                                            child: Text(
                                              "Huỷ bỏ",
                                              style: const TextStyle(
                                                  height: 1.3,
                                                  color: kMainColor,
                                                  fontSize: kSizeTextTitle,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            )),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: kMainColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(24)),
                                        ),
                                        width: 120,
                                        height: 48,
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              callBack(currentValues);
                                            },
                                            child: Text(
                                              agreeTitle ??
                                                  "Đồng ý",
                                              style: const TextStyle(
                                                  height: 1.3,
                                                  color: Colors.white,
                                                  fontSize: kSizeTextTitle,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            )),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  )
                                ],
                              )))
                    ],
                  ),
                  null,
                  radius: 24,
                  height: (titleMessage.isEmpty ? 85.0 : 120.0) +
                      55 * currentValues.length,
                  width: 296),
            ),
          );
        },
      );
    },
  );
}

void showActionSheet(String? titleMessage, List<String> actionsTitle,
    Function(int) callBack, BuildContext context,
    {String? cancelButton}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: (titleMessage != null && titleMessage.isNotEmpty)
          ? Text(titleMessage)
          : null,
      actions: List.generate(
        actionsTitle.length,
        (index) => CupertinoActionSheetAction(
          onPressed: () {
            printDebug("Select action sheet index: $index");
            Navigator.of(context).pop();
            callBack(index);
          },
          child: Text(actionsTitle[index]),
        ),
      ),
      cancelButton: cancelButton != null
          ? CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                callBack(-1);
              },
              isDestructiveAction: true,
              child: Text(cancelButton),
            )
          : null,
    ),
  );
}

void showBlurActionSheet(String? titleMessage, List<String> actionsTitle,
    Function(int) callBack, BuildContext context) {
  showGeneralDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      context: context,
      transitionBuilder: (context, animation, secondaryAnimation, widget) {
        // Slide animation from the bottom
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).animate(animation);
        return SlideTransition(
          position: slideAnimation,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                          color: Colors.black.withOpacity(0.8),
                          child: getSelectListItem(actionsTitle,
                              title: titleMessage,
                              callBack: callBack,
                              scrool: false))),
                )),
          ),
        );
      },
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Container();
      },
      transitionDuration: const Duration(milliseconds: 200));
}

Future<void> saveKeyStore(Map<String, String> mapStore,
    {FlutterSecureStorage? storage}) async {
  if (storage == null) {
    const options =
        IOSOptions(accessibility: KeychainAccessibility.first_unlock);
    storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: options);
  }
  for (String key in mapStore.keys) {
    await storage.write(key: key, value: mapStore[key]);
  }
}

Future<Map<String, String>> getAllKeyStore(
    {FlutterSecureStorage? storage}) async {
  if (storage == null) {
    const options =
        IOSOptions(accessibility: KeychainAccessibility.first_unlock);
    storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: options);
  }
  Map<String, String> allValues = await storage.readAll();
  return allValues;
}

void showSelectTime(
    BuildContext context,
    String title,
    String first,
    String second,
    int maxFirst,
    int maxSecond,
    int oldFirst,
    int oldSecond,
    Function callBack,
    {Widget? rightWidget}) {
  printDebug("Show select time");
  TimePicker.show<DateTime?>(
    context: context,
    sheet: TimePickerSheet(
      sheetTitle: title,
      hourTitle: first,
      minuteTitle: second,
      oldHour: oldFirst,
      oldMinute: oldSecond,
      maxHour: maxFirst,
      maxMinute: maxSecond,
      saveButtonText: "Đồng ý",
      saveButtonColor: kMainColor,
      rightWidget: rightWidget,
    ),
  ).then((value) => {
        if (value != null)
          {
            printDebug(
                "Time Select: ${value.hour} - ${value.minute} - ${value.second}"),
            callBack(
                maxFirst > 24 ? (value.second + value.hour * 60) : value.hour,
                value.minute)
          }
      });
}

void showModalView(Widget child, BuildContext context) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => child,
  );
}

int countListObject(dynamic list) {
  if (list == null || (list is! List) || list.isEmpty) {
    return 0;
  }
  return list.length;
}

bool stringEmpty(dynamic input) {
  return input == null || (input is! String) || input.isEmpty;
}

bool mapEmpty(dynamic input) {
  return input == null || (input is! Map) || input.isEmpty;
}

void showAlertProgress(
    BuildContext mainContext, int totalTime, Function finished) {
  DataManager().totalTime = totalTime * 10;
  bool isFinish = false;
  bool initTimer = false;
  showDialog(
    context: mainContext,
    barrierDismissible: false,
    builder: (subContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (!initTimer) {
            initTimer = true;
            Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
              printDebug("Progress ${DataManager().totalTime}");
              DataManager().totalTime -= 1;
              if (!isFinish) {
                if (DataManager().totalTime <= 0) {
                  isFinish = true;
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  finished();
                  timer.cancel();
                } else {
                  if (context.mounted) {
                    setState(() {});
                  }
                }
              }
            });
          }
          return Dialog.fullscreen(
            backgroundColor: Colors.transparent,
            child: Center(
              child: containerBorder(
                  CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 5.0,
                    percent: min(
                        1.0,
                        (totalTime * 10 - DataManager().totalTime) /
                            (10 * totalTime.toDouble())),
                    center: Text(
                      "${DataManager().totalTime / 10} giây",
                      style: const TextStyle(height: 1.3, color: kMainColor),
                    ),
                    progressColor: kMainColor,
                    backgroundColor: kBgGreyColor,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  null,
                  radius: 16,
                  height: 100,
                  width: 100),
            ),
          );
        },
      );
    },
  );
}

Widget getSelectListItem(List<String> listItems,
    {String? title,
    int selectedIndex = -1,
    Function? callBack,
    bool scrool = true}) {
  return StatefulBuilder(builder: (context, setState) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: min(500, 60 * listItems.length.toDouble()),
        width:
            DataManager().isTablet ? 360 : DataManager().widthDevice.toDouble(),
        child: ListView.separated(
          physics: scrool
              ? const ScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                if (callBack != null) {
                  callBack(index);
                } else {
                  setState(() {
                    selectedIndex = index;
                  });
                }
              },
              child: Container(
                color: Colors.transparent,
                height: scrool ? 40 : 60,
                width: DataManager().widthDevice.toDouble(),
                child: Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Text(
                      listItems[index],
                      style: const TextStyle(
                          height: 1.3,
                          decoration: TextDecoration.none,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Divider(
                  color: Colors.grey.withOpacity(
                    0.1,
                  ),
                  height: 0.25,
                ));
          },
        ),
      ),
    );
  });
}

Widget getCommonButton(Widget child, Function onPressCallBack,
    {double padding = 0, Function()? longPressCallBack}) {
  return ElevatedButton(
      onPressed: () {
        onPressCallBack();
      },
      onLongPress: () {
        if (longPressCallBack != null) {
          longPressCallBack();
        }
      },
      style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          alignment: Alignment.center,
          minimumSize: const Size(40, 40),
          foregroundColor: kSubColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.all(padding)),
      child: child);
}

void showSelectListItem(BuildContext? context, List<String> listItems,
    int selectedIndex, Function callBack,
    {List<IconData>? otherIcons,
    List<String>? otherTitles,
    Widget? rightWidget,
    Function? rightCallBack}) {
  if (context == null || !context.mounted) {
    return;
  }
  Widget messageUI = Container(
    decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
    child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 20),
                  SizedBox(
                    height: min(400, listItems.length * 50),
                    child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                              height: 1,
                            ),
                        itemCount: listItems.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              callBack(index);
                            },
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: (selectedIndex != index
                                        ? null
                                        : const Icon(
                                            Icons.check_rounded,
                                            color: kMainColor,
                                          )),
                                  ),
                                  Expanded(
                                      child: Text(listItems[index],
                                          style: const TextStyle(
                                              height: 1.3,
                                              color: Colors.black,
                                              fontSize: kSizeTextTitle),
                                          textAlign: TextAlign.left)),
                                  if (rightWidget != null)
                                    getCommonButton(
                                        rightWidget,
                                        () => {
                                              if (rightCallBack != null)
                                                {
                                                  Navigator.of(context).pop(),
                                                  rightCallBack(index)
                                                }
                                            })
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  if (otherIcons != null && otherTitles != null)
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 1,
                            width: DataManager().widthDevice - 40,
                            color: kBgGreyColor,
                          ),
                          const SizedBox(
                            height: 14,
                          )
                        ],
                      ),
                    ),
                  if (otherIcons != null && otherTitles != null)
                    Column(
                      children: List.generate(otherIcons.length, (i) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            callBack(-1 - i);
                          },
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Icon(
                                      otherIcons[i],
                                      color: kMainColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(otherTitles[i],
                                        style: const TextStyle(
                                            height: 1.3,
                                            color: Colors.black,
                                            fontSize: kSizeTextTitle),
                                        textAlign: TextAlign.left),
                                  ),
                                ],
                              ),
                              if (i != otherIcons.length - 1)
                                const SizedBox(
                                  height: 20,
                                )
                            ],
                          ),
                        );
                      }),
                    ),
                  // GestureDetector(
                  //     onTap: () {
                  //       Navigator.of(context).pop();
                  //       callBack(1000);
                  //     },
                  //     child: Row(
                  //       // children: [
                  //
                  //         // SizedBox(
                  //         //   width: 40,
                  //         //   child: Icon(
                  //         //     otherIcon,
                  //         //     color: kMainColor,
                  //         //   ),
                  //         // ),
                  //         // Expanded(
                  //         //   child: Text(otherTitle, style: const TextStyle(height: 1.3,color: Colors.black, fontSize: kSizeTextTitle), textAlign: TextAlign.left),
                  //         // )
                  //       // ],
                  //     ))
                ]))),
  );
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
    barrierColor: Colors.black.withOpacity(0.1),
    pageBuilder: (context, _, __) {
      return messageUI;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
            .drive(
                Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [messageUI],
              ),
            )
          ],
        ),
      );
    },
  );
}

void showNotifyMessage(BuildContext? inputContext, String message,
    {String? debug, Color? color, int timeHidden = 2}) {
  BuildContext? context = inputContext ?? DataManager().currentContext;
  if (DataManager().isShowingMessage || context == null || !context.mounted) {
    printDebug("showNotifyMessage $message");
    return;
  }
  DataManager().isShowingMessage = true;
  Widget messageUI = Container(
    decoration: BoxDecoration(
        color: color ?? kNotiColor,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
    child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(debug == null ? message : "$message - $debug",
                  style: const TextStyle(
                      height: 1.3,
                      color: Colors.white,
                      fontSize: kSizeTextTitle),
                  textAlign: TextAlign.center),
            ],
          ),
        )),
  );
  var timer = Timer(Duration(seconds: timeHidden), () {
    if (DataManager().isShowingMessage && context.mounted) {
      Navigator.of(context).pop();
    }
  });
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
    barrierColor: Colors.black.withOpacity(0.1),
    pageBuilder: (context, _, __) {
      return messageUI;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
            .drive(
                Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [messageUI],
              ),
            )
          ],
        ),
      );
    },
  ).then((value) => {
        if (timer.isActive) {timer.cancel()},
        DataManager().isShowingMessage = false,
      });
}

Map<String, dynamic> deepCopy(Map<String, dynamic> original) {
  Map<String, dynamic> copy = {};

  original.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      // Recursively copy nested maps
      copy[key] = deepCopy(value);
    } else if (value is List) {
      // Deep copy for lists, assuming the list contains simple types or maps
      copy[key] = value.map((item) {
        return item is Map<String, dynamic> ? deepCopy(item) : item;
      }).toList();
    } else {
      // Direct assignment for other types
      copy[key] = value;
    }
  });

  return copy;
}

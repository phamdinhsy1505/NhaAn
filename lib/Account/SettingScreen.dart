import '../Common/OverlayLoadingProgress.dart';
import '../Common/notification_center.dart';
import '../Data/APIManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Data/Constants.dart';
import '../Data/DataManager.dart';
import '../Data/Functions.dart';
import 'ChangePassScreen.dart';
import 'LoginScreen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class ActionSetting {
  ActionSetting(this.name, this.typeAction);

  String name;
  ActionSettingType typeAction;
}

class _SettingScreenState extends State<SettingScreen> {
  List<ActionSetting> listActions = [];
  String passTest = "";

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        loadData();
      });
    });
  }

  Future<void> loadData() async {
    listActions.clear();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String currentAccount = sharedPreferences.getString("username") ?? "";
    passTest = sharedPreferences.getString(currentAccount.trim()) ?? "";
    passTest = generateMd5(passTest, lenght: 16);
    listActions.add(ActionSetting("Biệt danh: ${DataManager().userName} - ${DataManager().userAccount}", ActionSettingType.nameDisplay));
    listActions.add(ActionSetting("Thay đổi mật khẩu", ActionSettingType.changePass));
    listActions.add(ActionSetting("Xoá tài khoản", ActionSettingType.deleteAccount));
    listActions.add(ActionSetting("Đăng xuất", ActionSettingType.logout));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Tài khoản",
              style: const TextStyle(height: 1.3, fontWeight: FontWeight.bold, fontSize: kSizeTextHeader),
            ),
            const SizedBox(
              height: 32,
            ),
            if (listActions.isEmpty)
              Container()
            else
              Expanded(
                  child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => const SizedBox(
                  height: 12,
                ),
                itemCount: listActions.length,
                itemBuilder: (context, index) {
                  return containerBorder(
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 46,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      listActions[index].name,
                                      style: const TextStyle(
                                        height: 1.3,
                                        fontSize: kSizeTextTitle,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  if (listActions[index].typeAction == ActionSettingType.settingMode)
                                    Switch(
                                        value: DataManager().settingMode != SettingMode.normal,
                                        activeColor: Colors.white,
                                        activeTrackColor: kMainColor,
                                        inactiveTrackColor: Colors.black.withOpacity(0.2),
                                        inactiveThumbColor: Colors.black,
                                        onChanged: (value) {
                                          setState(() {
                                            DataManager().settingMode = (DataManager().settingMode != SettingMode.normal) ? SettingMode.normal : SettingMode.agency;
                                            NotificationCenter().notify("settingMode");
                                            loadData();
                                          });
                                        }),
                                  Icon(Icons.navigate_next_rounded)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ), () {
                    if (listActions[index].typeAction == ActionSettingType.logout) {
                      showAlertDialog("Bạn có chắc chắn muốn đăng xuất", ["Đăng xuất"], (index) {
                        if (index != -1) {
                          DataManager().logoutUser(context);
                        }
                      }, context);
                    } else if (listActions[index].typeAction == ActionSettingType.deleteAccount) {
                      showAlertDialog("Bạn có chắc chắn muốn xoá tài khoản? Tài khoản bị xoá sẽ không thể được phục hồi!", ["Xoá"], (index) {
                        if (index != -1) {}
                      }, context);
                    } else if (listActions[index].typeAction == ActionSettingType.nameDisplay) {
                      showAlertListInputDialog(context, [DataManager().userName], (newData, index) {
                        if (countListObject(newData) == 1) {
                          APIManager().updateUserInfo(context, newData![0].trim(), (isSuccess, message) {
                            if (isSuccess) {
                              setState(() {
                                listActions[0].name = "Biệt danh: ${DataManager().userName} - ${DataManager().userAccount}";
                              });
                            } else {
                              showNotifyMessage(context, message);
                            }
                          });
                        }
                      });
                    } else if (listActions[index].typeAction == ActionSettingType.changePass) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePassScreen()));
                    }
                    else {}
                  }, height: 56);
                },
              )),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                "$kVersionInfo - $passTest",
                style: TextStyle(height: 1.3, decoration: TextDecoration.none),
              ),
            ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}

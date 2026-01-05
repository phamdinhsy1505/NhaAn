import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lunar_calendar_plus/lunar_calendar.dart';
import 'package:nhakhach/Common/OverlayLoadingProgress.dart';
import 'package:nhakhach/Data/APIManager.dart';
import 'package:nhakhach/Data/DataModel.dart';
import '../Data/Functions.dart';
import 'Common/notification_center.dart';
import 'Data/Constants.dart';

class RequestMealScreen extends StatefulWidget {

  const RequestMealScreen({super.key, this.mealReportModel});

  final MealReportModel? mealReportModel;
  @override
  State<RequestMealScreen> createState() => _RequestMealScreenState();
}

class _RequestMealScreenState extends State<RequestMealScreen> {
  late MealReportModel currentReportModel;
  int meal = 0;
  List listMeal = [kMealBreakfast, kMealLunch, kMealDinner];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.mealReportModel != null) {
      for(int i = 0;i < 3; i++){
        if (widget.mealReportModel!.meal == listMeal[i]) {
          meal = i;
          break;
        }
      }
      currentReportModel = MealReportModel.fromJson(widget.mealReportModel!.toJson());
    } else {
      currentReportModel = MealReportModel.fromJson({});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Báo xuất ăn",style: TextStyle(
            height: 1.3,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15),),
        actions: widget.mealReportModel == null ? null : [
          IconButton(onPressed: (){
            OverlayLoadingProgress.start(context);
            APIManager().deleteMeal(context, widget.mealReportModel!.id, (data){
              OverlayLoadingProgress.stop();
              if (data != null) {
                Navigator.of(context).pop();
                NotificationCenter().notify("reloadListMeal");
                showNotifyMessage(null, "Đã xoá yêu cầu!");
              } else {
                showNotifyMessage(context, "Xoá yêu cầu lỗi, vui lòng thử lại sau!");
              }
            });
          }, icon: Icon(Icons.delete, color: kMainColor,))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LunarCalendar(
                      initialSolarDate: DateTime.now(),
                      showTodayButton: true,
                      onDateSelected: (solarDate, lunarDate) {
                        int diffDay = solarDate.difference(DateTime.now()).inDays;
                        if (diffDay < 7 && diffDay >= 0) {
                          currentReportModel.reportedAt = solarDate;
                        }
                        print('Solar date: $solarDate - ${solarDate.difference(DateTime.now()).inDays}');
                        print('Lunar date: $lunarDate');
                      },
                    ),
                    SizedBox(height: 16,),
                    NumberInput(
                      value: currentReportModel.quantity,
                      min: 1,
                      max: 1000,
                      onChanged: (v) {
                        setState(() {
                          currentReportModel.quantity = v;
                        });
                      },
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16,),
                        Text("Chọn bữa ăn:"),
                        SizedBox(width: 16,),
                        containerBorder(
                            CupertinoSlidingSegmentedControl(
                                children: {
                                  0: Container(
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Sáng",
                                      style: TextStyle(height: 1.3, color: meal == 0 ? Colors.white : Colors.black, fontSize: 14, decoration: TextDecoration.none),
                                    ),
                                  ),
                                  1: Container(
                                      height: 32,
                                      alignment: Alignment.center,
                                      child: Text("Trưa",
                                          style: TextStyle(height: 1.3, color: meal == 1 ? Colors.white : Colors.black, fontSize: 14, decoration: TextDecoration.none))),
                                  2: Container(
                                      height: 32,
                                      alignment: Alignment.center,
                                      child: Text("Tối",
                                          style: TextStyle(height: 1.3, color: meal == 2 ? Colors.white : Colors.black, fontSize: 14, decoration: TextDecoration.none))),
                                },
                                thumbColor: kMainColor,
                                groupValue: meal,
                                backgroundColor: Colors.transparent,
                                onValueChanged: (value) {
                                  printDebug("Segment selected: $value");
                                  if (value != null) {
                                    setState(() {
                                      meal = value;
                                    });
                                  }
                                }),
                            null,
                            width: 220,
                            height: 36,
                            isNoneMargin: true,
                            color: Colors.white,
                            radius: 8,
                            isShadow: false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16,),
            containerGradient(
              width: 250,
              TextButton(
                onPressed: () {
                  OverlayLoadingProgress.start(context);
                  if (widget.mealReportModel == null) {
                    APIManager().requestMeal(context, listMeal[meal], DateFormat("yyyy-MM-dd").format(currentReportModel.reportedAt), currentReportModel.quantity, (data){
                      OverlayLoadingProgress.stop();
                      if (data != null) {
                        Navigator.of(context).pop();
                        NotificationCenter().notify("reloadListMeal");
                        showNotifyMessage(null, "Đã gửi yêu cầu, chờ xác nhận!");
                      } else {
                        showNotifyMessage(context, "Gửi yêu cầu lỗi, vui lòng thử lại sau!");
                      }
                    });
                  } else {
                    APIManager().updateMeal(context, widget.mealReportModel!.id, {"meal": listMeal[meal],"reportDate" : DateFormat("yyyy-MM-dd").format(currentReportModel.reportedAt), "quantity" : currentReportModel.quantity}, (data){
                      OverlayLoadingProgress.stop();
                      if (data != null) {
                        Navigator.of(context).pop();
                        NotificationCenter().notify("reloadListMeal");
                        showNotifyMessage(null, "Đã gửi yêu cầu, chờ xác nhận!");
                      } else {
                        showNotifyMessage(context, "Gửi yêu cầu lỗi, vui lòng thử lại sau!");
                      }
                    });
                  }
                },
                child: Text("Gửi yêu cầu",
                  style: TextStyle(
                      height: 1.3,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
            SizedBox(height: 32,)
          ],
        ),
      ),
    );
  }
}

class NumberInput extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const NumberInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  void _update(int value) {
    final v = value.clamp(widget.min, widget.max);
    _controller.text = v.toString();
    widget.onChanged(v);
  }

  void _onTextChanged(String value) {
    if (value.isEmpty) return;

    final parsed = int.tryParse(value);
    if (parsed == null) return;

    _update(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 16,),
        Text("Nhập số xuất ăn:"),
        SizedBox(width: 16,),
        _button(
          icon: Icons.remove,
          onTap: () => _update(widget.value - 1),
        ),
        SizedBox(width: 8,),
        SizedBox(
          width: 56,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: _onTextChanged,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8,),
        _button(
          icon: Icons.add,
          onTap: () => _update(widget.value + 1),
        ),
      ],
    );
  }

  Widget _button({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}


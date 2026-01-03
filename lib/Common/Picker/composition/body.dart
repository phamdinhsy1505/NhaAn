import 'dart:math';

import 'package:flutter/material.dart';
import '../../../Data/Constants.dart';
import '../../../Data/Functions.dart';
import '../provider/time_picker.dart';
import 'wheel.dart';

/// For now time picker only support 24 hour. The hour options will be
/// start from 0 to 23 when the interval is 1 and when you are not setting up
/// the min & max values. The minutes should be start from 0 to 45 by default
/// because the default value for interval minutes is 15. you can adjust the
/// value to align with your needs from the screen directly.
class TimePickerBody extends StatefulWidget {
  final double itemHeight;

  final int visibleItems;

  final int minuteInterval;

  final int hourInterval;

  final int maxHour;

  final int minHour;

  final int oldHour;

  final int oldMinute;

  final int maxMinute;

  final int minMinute;

  const TimePickerBody({
    Key? key,
    required this.oldHour,
    required this.oldMinute,
    required this.itemHeight,
    required this.visibleItems,
    required this.minHour,
    required this.maxHour,
    required this.minMinute,
    required this.maxMinute,
    required this.minuteInterval,
    required this.hourInterval,
  }) : super(key: key);

  @override
  State<TimePickerBody> createState() => _TimePickerBodyState();
}

class _TimePickerBodyState extends State<TimePickerBody> {
  late ValueNotifier<int> hourNotifier = ValueNotifier(0);

  late ValueNotifier<int> minuteNotifier = ValueNotifier(0);

  late ScrollController minuteController;

  late ScrollController hourController;

  @override
  void initState() {
    super.initState();
    _initializeDateTime();
  }

  void _initializeDateTime() {
    final hours = _getHours();

    /// make sure at least there are 3 options on the list.
    assert(hours.length >= 3);
    var hourIndex = hours.indexOf(widget.oldHour);
    if (hourIndex == -1) {
      /// IF the hour less than min value, it will force to select the smallest
      /// value on the list.
      /// IF the hour greater than max value, it will force to select the
      /// biggest value on the list.
      /// ELSE will calculate the value based on the interval. if the value is
      /// outside the interval ex: the options are 0, 15, 30, 45 then the
      /// hour set to 17, it will force to the nearest value below that is
      /// 15.
      if (widget.oldHour < widget.minHour) {
        hourIndex = 0;
      } else if (widget.oldHour > widget.maxHour) {
        hourIndex = hours.length - 1;
      } else {
        hourIndex = widget.oldHour ~/ widget.hourInterval;
      }
      hourNotifier.value = hours[hourIndex];
    } else {
      hourNotifier.value = widget.oldHour;
    }
    hourController = ScrollController(
      initialScrollOffset: (hourIndex) * widget.itemHeight,
    );

    final minutes = _getMinutes();

    /// make sure at least there are 3 options on the list.
    assert(minutes.length >= 3);
    var minuteIndex = minutes.indexOf(widget.oldMinute);
    if (minuteIndex == -1) {
      /// IF the minute is less than min value, it will force to select the
      /// smallest value on the list.
      /// IF the minute greater than max value, it will force to select the
      /// biggest value on the list.
      /// ELSE will calculate the value based on the interval. if the value is
      /// outside the interval ex: the options are 0, 15, 30, 45 then the
      /// minute set to 17, it will force to the nearest value below that is
      /// 15.
      if (widget.oldMinute < widget.minMinute) {
        minuteIndex = 0;
      } else if (widget.oldMinute > widget.maxMinute) {
        minuteIndex = minutes.length - 1;
      } else {
        minuteIndex = widget.oldMinute ~/ widget.minuteInterval;
      }
      minuteNotifier.value = minutes[minuteIndex];
    } else {
      minuteNotifier.value = widget.oldMinute;
    }
    minuteController = ScrollController(
      initialScrollOffset: (minuteIndex) * widget.itemHeight,
    );
  }

  @override
  void dispose() {
    hourNotifier.dispose();
    minuteNotifier.dispose();
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void _onSaved(BuildContext context) {
    final now = DateTime.now();
    printDebug("_onSaved ${hourNotifier.value} - ${minuteNotifier.value}");
    if (widget.maxHour > 24) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
        hourNotifier.value~/60,
        minuteNotifier.value,
        hourNotifier.value % 60,
      );
      Navigator.of(context).pop(date);
    } else {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
        min(24, hourNotifier.value),
        minuteNotifier.value,
        hourNotifier.value,
      );
      Navigator.of(context).pop(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = TimePickerProvider.of(context);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 20,
                child: Text(
                  provider.hourTitle,
                  style: provider.hourTitleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 20,
                child: Text(
                  provider.minuteTitle,
                  style: provider.minuteTitleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: widget.itemHeight * 3,
                child: NumberWheel(
                  numbers: _getHours(),
                  itemHeight: widget.itemHeight,
                  numberNotifier: hourNotifier,
                  twoDigits: provider.twoDigit,
                  controller: hourController,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: widget.itemHeight * 3,
                child: NumberWheel(
                  numbers: _getMinutes(),
                  itemHeight: widget.itemHeight,
                  numberNotifier: minuteNotifier,
                  twoDigits: provider.twoDigit,
                  controller: minuteController,
                ),
              ),
            ),
          ],
        ),
        const Expanded(child: SizedBox.shrink()),
        SizedBox(
          height: 50,
          child: Column(
            children: [
              Container(
                height: 0.5,
                color: Colors.grey.withAlpha(100),
              ),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: TextButton(// <-- Radius
                        onPressed: () => {
                          Navigator.of(context).pop()
                        },
                        child: Text("Hủy bỏ", style: TextStyle(height: 1.3,color: provider.saveButtonColor, fontSize: kSizeTextHeader),),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      color: Colors.grey.withAlpha(100),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: TextButton(// <-- Radius
                        onPressed: () => _onSaved(context),
                        child: Text(provider.saveButtonText, style: TextStyle(height: 1.3,color: provider.saveButtonColor, fontSize: kSizeTextHeader, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// filter hours based on interval, min & max values.
  List<int> _getHours() {
    final maxOptions = widget.maxHour ~/ widget.hourInterval;
    final optionHours = List<int>.empty(growable: true);

    /// iteration start from 0, it means the hour should be
    /// start from 0 if the minimum value is 0.
    for (var index = 0; index < maxOptions; index++) {
      final hour = index * widget.hourInterval;
      final isEqualOrGreaterThanMinValue = hour >= widget.minHour;
      final isEqualOrLessThanMaxValue = hour <= widget.maxHour;

      if (isEqualOrGreaterThanMinValue && isEqualOrLessThanMaxValue) {
        optionHours.add(hour);
      }
    }

    return optionHours;
  }

  /// filter minutes based on interval, min & max values.
  List<int> _getMinutes() {
    final maxOptions = widget.maxMinute ~/ widget.minuteInterval;
    final optionMinutes = List<int>.empty(growable: true);

    /// iteration start from 0, it means the minute should be
    /// start from 0 if the minimum value is 0.
    for (var index = 0; index < maxOptions; index++) {
      final minute = index * widget.minuteInterval;
      final isEqualOrGreaterThanMinValue = minute >= widget.minMinute;
      final isEqualOrLessThanMaxValue = minute <= widget.maxMinute;

      if (isEqualOrGreaterThanMinValue && isEqualOrLessThanMaxValue) {
        optionMinutes.add(minute);
      }
    }

    return optionMinutes;
  }
}

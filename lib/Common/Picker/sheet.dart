import 'package:flutter/material.dart';
import '../../Data/Constants.dart';
import 'composition/body.dart';
import 'composition/header.dart';
import 'composition/indicator.dart';
import 'provider/time_picker.dart';
import 'time_picker.dart';

/// Using date time format to initialize data and also for the final result.
/// the sheet only care about the hour and minute values, the other will be
/// ignored.
class TimePickerSheet extends TimePicker {
  /// you can set initial date time from screen, so if time picker sheet
  /// opened will be directly selected the time based on initialDateTime.
  /// but this is optional, if initialDateTime not set the selected time
  /// will be 0 because using _defaultDateTime.
  /// will be used as a minute interval, the default value is 15 but you can
  /// adjust based on your needs from screen. if the value is 15 then the
  /// options will be 0, 15, 30, 45.
  final int minuteInterval;

  /// will be used as a hour interval, the default value is 1 but you can
  /// adjust based on your needs from screen. if the value is 1 then the
  /// options will be start from 0 to 23.
  final int hourInterval;

  /// max hour should be >= 0 && <= 24. outside the range will
  /// trigger an error on the screen.
  final int maxHour;

  /// min hour should be >= 0 && <= 24. outside the range will
  /// trigger an error on the screen.
  final int minHour;

  /// max minute should be >= 0 && <= 60. outside the range will
  /// trigger an error on the screen.
  final int maxMinute;

  final int oldHour;

  /// max minute should be >= 0 && <= 60. outside the range will
  /// trigger an error on the screen.
  final int oldMinute;

  /// min minute should be >= 0 && <= 60. outside the range will
  /// trigger an error on the screen.
  final int minMinute;

  /// to enable two digit format in time picker sheet,
  /// the default value is false. When this format enabled
  /// the return value/result is still using one digit. Ex:
  /// you select 03:45 then the result would be 3:45. so you
  /// don't need to reformat or mapping anything on the screen.
  final bool twoDigit;

  final IconData sheetCloseIcon;

  final Color sheetCloseIconColor;

  /// title on the top of the sheet.
  final String sheetTitle;

  /// you can customize the style to align with your requirement.
  final TextStyle sheetTitleStyle;

  final String minuteTitle;

  final TextStyle minuteTitleStyle;

  final String hourTitle;

  final TextStyle hourTitleStyle;

  final TextStyle wheelNumberItemStyle;

  final TextStyle wheelNumberSelectedStyle;

  final String saveButtonText;

  final Color saveButtonColor;

  final Widget? rightWidget;

  const TimePickerSheet({super.key,
    required this.sheetTitle,
    required this.minuteTitle,
    required this.hourTitle,
    required this.saveButtonText,
    this.oldHour = 0,
    this.oldMinute = 1,
    this.minuteInterval = 1,
    this.hourInterval = 1,
    this.minHour = 0,
    this.maxHour = 60,
    this.minMinute = 0,
    this.maxMinute = 60,
    this.twoDigit = true,
    this.sheetCloseIcon = Icons.close,
    this.sheetCloseIconColor = Colors.redAccent,
    this.saveButtonColor = Colors.redAccent,
    this.rightWidget,
    this.sheetTitleStyle = const TextStyle(height: 1.3,
      fontWeight: FontWeight.bold,
      fontSize: kSizeTextTitle,
    ),
    this.hourTitleStyle = const TextStyle(height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.redAccent,
      fontSize: kSizeTextTitle,
    ),
    this.minuteTitleStyle = const TextStyle(height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.redAccent,
      fontSize: kSizeTextTitle,
    ),
    this.wheelNumberItemStyle = const TextStyle(height: 1.3,
      fontSize: kSizeTextNormal,
      color: Colors.grey,
    ),
    this.wheelNumberSelectedStyle = const TextStyle(height: 1.3,
      fontWeight: FontWeight.bold,
      color: Colors.redAccent,
      fontSize: kSizeTextTitle,
    ),
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(height: 1.3,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: kSizeTextTitle,
    );
    return TimePickerProvider(
      sheetCloseIcon: sheetCloseIcon,
      sheetCloseIconColor: Colors.black,
      sheetTitle: sheetTitle,
      sheetTitleStyle: sheetTitleStyle,
      minuteTitle: minuteTitle,
      minuteTitleStyle: textStyle,
      hourTitle: hourTitle,
      hourTitleStyle: textStyle,
      wheelNumberItemStyle: wheelNumberItemStyle,
      wheelNumberSelectedStyle: textStyle,
      saveButtonText: saveButtonText,
      saveButtonColor: kMainColor,
      rightWidget: rightWidget,
      twoDigit: twoDigit,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      const TimePickerIndicator(),
                      TimePickerBody(
                        oldHour: oldHour,
                        oldMinute: oldMinute,
                        itemHeight: 40,
                        minuteInterval: minuteInterval.abs(),
                        hourInterval: hourInterval.abs(),
                        maxHour: maxHour,
                        minHour: minHour,
                        maxMinute: maxMinute,
                        minMinute: minMinute,
                        visibleItems: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

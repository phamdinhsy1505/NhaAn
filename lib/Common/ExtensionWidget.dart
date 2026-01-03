import 'package:flutter/material.dart';

extension StringExtension on String {
  String toCapitalize() {
    if (isNotEmpty) {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    } else {
      return this;
    }
  }
}
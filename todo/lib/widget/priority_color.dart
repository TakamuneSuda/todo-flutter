import 'package:flutter/material.dart';
import '/../constants.dart';

class PriorityColor {
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 0:
      return AppColors.PRIORITY_COLOR_LOW;
    case 1:
      return AppColors.PRIORITY_COLOR_MIDDLE;
    case 2:
      return AppColors.PRIORITY_COLOR_HIGH;
    default:
      return Colors.white;
    }
  }
}


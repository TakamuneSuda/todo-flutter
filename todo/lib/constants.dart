import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppColors {
  static Color THEME_COLOR = HexColor("##A1FF7A");

  static Color SUBMIT_BUTTON_COLOR = HexColor("#6ECEFD");

  static Color PRIORITY_COLOR_LOW = HexColor("#BDDCFF").withOpacity(0.4);
  static Color PRIORITY_COLOR_MIDDLE = HexColor("#FFF499").withOpacity(0.4);
  static Color PRIORITY_COLOR_HIGH = HexColor("#FFC5AE").withOpacity(0.4);
}

MaterialColor themeColor = MaterialColor(
  0xFF949494,
  <int, Color>{
    50: HexColor("#949494").withOpacity(0.1),
    100: HexColor("#949494").withOpacity(0.2),
    200: HexColor("#949494").withOpacity(0.3),
    300: HexColor("#949494").withOpacity(0.4),
    400: HexColor("#949494").withOpacity(0.5),
    500: HexColor("#949494").withOpacity(0.6),
    600: HexColor("#949494").withOpacity(0.8),
    700: HexColor("#949494").withOpacity(0.8),
    800: HexColor("#949494").withOpacity(0.9),
    900: HexColor("#949494").withOpacity(1.0),
  },
);

int PRIORITY_VALUE_LOW = 0;
int PRIORITY_VALUE_MIDDLE = 1;
int PRIORITY_VALUE_HIGH = 2;
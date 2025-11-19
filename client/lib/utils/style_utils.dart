import 'package:flutter/material.dart';

class StyleUtils {
  static EdgeInsets constEdgeInsets({double all = 8.0}) => EdgeInsets.all(all);
  
  static TextStyle constTextStyle({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14,
    Color? color,
  }) => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
  
  static Duration constDuration(int seconds) => Duration(seconds: seconds);
  
  static Alignment constAlignment(Alignment alignment) => alignment;
}
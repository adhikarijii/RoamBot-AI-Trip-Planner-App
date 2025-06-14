import 'package:flutter/material.dart';

double customFontSize(BuildContext context, double baseSize) {
  double widthFactor = MediaQuery.of(context).size.width / 360;
  double heightFactor = MediaQuery.of(context).size.height / 690;

  bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

  double scaleFactor = (widthFactor + heightFactor) / 2;
  double newSize = baseSize * scaleFactor;

  if (isTablet) {
    newSize *= 1.1;
  }

  return newSize.clamp(baseSize - 2, baseSize + 6);
}
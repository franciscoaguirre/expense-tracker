import 'dart:math';

import 'package:flutter/material.dart';

Color getRandomColor() {
  Random random = Random();
  // Generate a random RGB color
  int r = random.nextInt(256); // Red value between 0 and 255
  int g = random.nextInt(256); // Green value between 0 and 255
  int b = random.nextInt(256); // Blue value between 0 and 255
  return Color.fromRGBO(r, g, b, 1); // Alpha is set to 1 for full opacity
}

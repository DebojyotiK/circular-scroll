import 'dart:math';

class MathUtils {
  static double radians(double degrees) {
    return pi * degrees / 180;
  }

  static double degrees(double radians) {
    return radians * 180 / pi;
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/element_description.dart';

class SpinnerBloc {
  final double spinnerWidth;
  final double radius;
  final double innerRadius;
  final double theta;
  final int numberOfItems;
  final ScrollController controller;
  double circleRotationAngle = 0;
  int page = 0;
  String rotationAngleText = "";
  final double contentHeight;
  int rotationMultiplier = 1;
  final double circleElementHeight;
  final double anchorRadius;
  final double circleElementWidth = 20;
  double? offset;
  static int repeatContent = 5;
  final List<ElementDescription> elementDescriptions = [];

  SpinnerBloc({
    required this.radius,
    required int elementsPerHalf,
    required this.innerRadius,
  })  : spinnerWidth = 2 * radius,
        controller = ScrollController(initialScrollOffset: 2 * radius),
        numberOfItems = 2 * elementsPerHalf,
        anchorRadius = innerRadius + (radius - innerRadius) / 2,
        contentHeight = 2 * pi * radius * 0.5 * repeatContent,
        circleElementHeight = radius - innerRadius,
        theta = 360 / (2 * elementsPerHalf) {
    _initialize();
  }

  void _initialize() {
    for (int i = 0; i < numberOfItems; i++) {
      elementDescriptions.add(ElementDescription(-1 * (theta / 2 + i * theta), theta));
    }
  }

  void scrollToNearest(){
    circleRotationAngle = (circleRotationAngle~/(theta/2)/2).ceil()*theta;
  }
}

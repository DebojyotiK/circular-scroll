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
  final AnimationController animationController;
  bool _isAnimating = false;

  bool get isAnimating => _isAnimating;
  late Animation<double> _rotationAnimation;

  Animation<double> get rotationAnimation => _rotationAnimation;

  SpinnerBloc({
    required this.radius,
    required int elementsPerHalf,
    required this.innerRadius,
    required this.animationController,
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

  void scrollToNearest(VoidCallback onFrameUpdate) {
    _isAnimating = true;
    double newCircleRotationAngle = (circleRotationAngle ~/ (theta / 2) / 2).ceil() * theta;
    double diff = (newCircleRotationAngle - circleRotationAngle).abs();
    _rotationAnimation = Tween(begin: circleRotationAngle, end: newCircleRotationAngle).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.bounceInOut,
      ),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
          circleRotationAngle = newCircleRotationAngle;
        }
        onFrameUpdate();
      })
      ..addListener(() {
        circleRotationAngle = _rotationAnimation.value;
        onFrameUpdate();
      });
    animationController.reset();
    animationController.duration = Duration(milliseconds: (2000 * diff) ~/ 180);
    animationController.forward();
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/element_description.dart';

import 'math_utils.dart';

class SpinnerBloc {
  final double spinnerWidth;
  final double radius;
  final double innerRadius;
  final double theta;
  final int numberOfItems;
  final ScrollController controller;
  double circleRotationAngle = 0;
  int page = 0;
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
  bool _isScrolling = false;

  bool get isAnimating => _isAnimating;
  late Animation<double> _rotationAnimation;

  bool get isScrolling => _isScrolling;

  Animation<double> get rotationAnimation => _rotationAnimation;

  final VoidCallback onFrameUpdate;

  SpinnerBloc({
    required this.radius,
    required int elementsPerHalf,
    required this.innerRadius,
    required this.animationController,
    required this.onFrameUpdate,
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

  void scrollToNearest() {
    double newCircleNearestRotationAngle = (circleRotationAngle ~/ (theta / 2) / 2).ceil() * theta;
    _rotateToAngle(newCircleNearestRotationAngle);
  }

  void bringTappedElementToCenter(Offset offset) {
    double tappedDegree = (elementDescriptions[getElementIndex(offset)].anchorAngle + circleRotationAngle) % 360;
    double adjustedDegree = _getAdjustedDegree(tappedDegree);
    double endAngle = circleRotationAngle + adjustedDegree;
    _rotateToAngle(endAngle);
  }

  double _getAdjustedDegree(double tappedDegree) {
    late double adjustedDegree;
    if (tappedDegree >= 0 && tappedDegree <= 90) {
      adjustedDegree = -1 * (90 + tappedDegree);
    } else if (tappedDegree >= 270 && tappedDegree <= 360) {
      adjustedDegree = -1 * (90 - (360 - tappedDegree));
    } else if (tappedDegree >= 90 && tappedDegree <= 270) {
      adjustedDegree = (270 - tappedDegree);
    }
    return adjustedDegree;
  }

  void _rotateToAngle(double newCircleRotationAngle) {
    _isAnimating = true;
    double diff = (newCircleRotationAngle - circleRotationAngle).abs();
    _rotationAnimation = Tween(
      begin: circleRotationAngle,
      end: newCircleRotationAngle,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOutCirc,
      ),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
          circleRotationAngle = newCircleRotationAngle;
          double adjustedRotationAngle = circleRotationAngle % 360;
          double distance = _degreesToDistance(adjustedRotationAngle);
          //controller.jumpTo(distance);
          _isAnimating = false;
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

  double pointToDegree(Offset offset) {
    double x = _translatedX(offset);
    double y = _translatedY(offset);
    double theta = MathUtils.degrees(atan(y / x));
    if (x > 0 && y < 0) {
      return theta;
    } else if (x < 0 && y < 0) {
      return -180 + theta;
    } else if (x < 0 && y > 0) {
      return -180 + theta;
    } else {
      return -360 + theta;
    }
  }

  double _translatedY(Offset offset) => offset.dy - spinnerWidth / 2;

  double _translatedX(Offset offset) => offset.dx - spinnerWidth / 2;

  bool checkIfPointClickedOnElement(Offset offset) {
    double x = _translatedX(offset);
    double y = _translatedY(offset);
    double radius = sqrt(pow(x, 2) + pow(y, 2));
    return (radius >= innerRadius && radius <= radius);
  }

  int getElementIndex(Offset offset) {
    double tappedDegree = pointToDegree(offset);
    double adjustedTappedDegree = (tappedDegree.abs() + circleRotationAngle) % 360;
    return adjustedTappedDegree ~/ theta;
  }

  int shiftByElements(int actualIndex, int shiftBy) {
    return (actualIndex + (numberOfItems - shiftBy)) % numberOfItems;
  }

  void processScrollStartNotification(ScrollStartNotification scrollInfo) {
    _isScrolling = true;
  }

  void processScrollUpdateNotification(ScrollUpdateNotification scrollInfo) {
    double deltaDegree = 0;
    if (offset != null) {
      deltaDegree = _distanceToDegrees(((scrollInfo.metrics.pixels - offset!)));
    }
    offset = scrollInfo.metrics.pixels;
    if (scrollInfo.dragDetails != null) {
      double x = _translatedX(scrollInfo.dragDetails!.localPosition);
      double y = _translatedY(scrollInfo.dragDetails!.localPosition);
      rotationMultiplier = (x > 0) ? -1 : 1;
    }
    circleRotationAngle += rotationMultiplier * deltaDegree;
    onFrameUpdate();
    if (offset! <= 0) {
      controller.jumpTo(spinnerWidth);
    } else if (offset! >= (spinnerWidth + contentHeight)) {
      controller.jumpTo(spinnerWidth);
    }
  }

  double _distanceToDegrees(double translation) => translation * 360 * SpinnerBloc.repeatContent / contentHeight;

  double _degreesToDistance(double degrees) => degrees * contentHeight / (360 * SpinnerBloc.repeatContent);

  void processScrollEndNotification(ScrollEndNotification scrollInfo) {
    _isScrolling = false;
    scrollToNearest();
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/element_description.dart';

import 'math_utils.dart';

typedef OnEnteredViewPort = void Function(List<int> index);
typedef OnLeftViewPort = void Function(List<int> index);

class SpinnerBloc {
  final double spinnerWidth;
  final double radius;
  final double innerRadius;
  final double theta;
  final int numberOfItems;
  late ScrollController controller;
  double circleRotationAngle = 0;
  double? _visibleElementsCalculationLastAngle;
  double _newCircleRotationAngle = 0;
  int page = 0;
  final double contentHeight;
  int rotationMultiplier = 1;
  final double anchorRadius;
  double? _previousOffset;
  static int repeatContent = 5;
  final List<ElementDescription> elementDescriptions = [];
  final AnimationController animationController;
  bool _isAnimating = false;
  bool _isScrolling = false;

  bool get isAnimating => _isAnimating;
  late Animation<double> _rotationAnimation;

  bool get isScrolling => _isScrolling;

  final VoidCallback onFrameUpdate;

  String visibleElementText = "";

  List<ElementDescription> _lastVisibleElements = [];

  late double _segmentHeight;
  late double _segmentWidth;

  double get segmentHeight => _segmentHeight;

  double get segmentWidth => _segmentWidth;

  OnEnteredViewPort? onEnteredViewPort;
  OnLeftViewPort? onLeftViewPort;

  ElementDescription get centerItem {
    int index = _convertDegreeToNegativeDegree((-90 - circleRotationAngle)).abs() ~/ theta;
    return elementDescriptions[index];
  }

  void notifyVisibilityOfElements() {
    if (_visibleElementsCalculationLastAngle == null || (circleRotationAngle - _visibleElementsCalculationLastAngle!).abs() > 0.2 * theta) {
      _visibleElementsCalculationLastAngle = circleRotationAngle;
      List<ElementDescription> visibleElements = _getVisibleElements();
      List<int> newlyVisibleElement = [];
      List<int> newlyHiddenElement = [];
      for (var element in visibleElements) {
        if (!_lastVisibleElements.contains(element)) {
          newlyVisibleElement.add(elementDescriptions.indexOf(element));
        }
      }
      for (var element in _lastVisibleElements) {
        if (!visibleElements.contains(element)) {
          newlyHiddenElement.add(elementDescriptions.indexOf(element));
        }
      }
      if (onEnteredViewPort != null && newlyVisibleElement.isNotEmpty) {
        onEnteredViewPort!(newlyVisibleElement);
      }
      if (onLeftViewPort != null && newlyHiddenElement.isNotEmpty) {
        onLeftViewPort!(newlyHiddenElement);
      }
      _lastVisibleElements = visibleElements;
    }
  }

  List<ElementDescription> _getVisibleElements() {
    List<ElementDescription> visibleElements = [];
    for (var element in elementDescriptions) {
      double adjustedStartAngle = _convertDegreeToNegativeDegree(element.startAngle + circleRotationAngle).abs();
      double adjustedEndAngle = _convertDegreeToNegativeDegree(element.endAngle + circleRotationAngle).abs();
      if ((adjustedStartAngle > 0 && adjustedStartAngle < 180) || (adjustedEndAngle > 0 && adjustedEndAngle < 180)) {
        visibleElements.add(element);
      }
    }
    return visibleElements;
  }

  SpinnerBloc({
    required this.radius,
    required int elementsPerHalf,
    required this.innerRadius,
    required this.animationController,
    required this.onFrameUpdate,
    this.onEnteredViewPort,
    this.onLeftViewPort,
  })  : spinnerWidth = 2 * radius,
        numberOfItems = 2 * elementsPerHalf,
        anchorRadius = innerRadius + (radius - innerRadius) / 2,
        contentHeight = 2 * pi * radius * 0.5 * repeatContent,
        theta = 360 / (2 * elementsPerHalf) {
    var cosThetaBy2 = cos(MathUtils.radians(theta / 2));
    var sinThetaBy2 = sin(MathUtils.radians(theta / 2));
    _segmentHeight = radius - innerRadius * cosThetaBy2;
    _segmentWidth = 2 * radius * sinThetaBy2;
    _initialize();
    _initializeAnimation();
    initializeScrollController();
  }

  void initializeScrollController() {
    controller = ScrollController(initialScrollOffset: spinnerWidth + contentHeight / 2);
  }

  void _initialize() {
    for (int i = 0; i < numberOfItems; i++) {
      var element = ElementDescription(
        -1 * (theta / 2 + i * theta),
        theta,
        "$i",
      );
      elementDescriptions.add(element);
    }
    notifyVisibilityOfElements();
  }

  void _initializeAnimation() {
    _rotationAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOutCirc,
      ),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          circleRotationAngle = _newCircleRotationAngle;
          double adjustedRotationAngle = -90 - centerItem.anchorAngle;
          double contentOffset = _degreesToDistance(adjustedRotationAngle) + spinnerWidth;
          debugPrint("Jump to $contentOffset");
          _previousOffset = contentOffset;
          if (_previousOffset! <= spinnerWidth) {
            _jumpToMiddle();
          } else if (_previousOffset! >= (spinnerWidth + contentHeight)) {
            _jumpToMiddle();
          } else {
            controller.jumpTo(_previousOffset!);
          }
          notifyVisibilityOfElements();
          _isAnimating = false;
        }
        onFrameUpdate();
      })
      ..addListener(() {
        circleRotationAngle = circleRotationAngle + _rotationAnimation.value * (_newCircleRotationAngle - circleRotationAngle);
        onFrameUpdate();
      });
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
    if (newCircleRotationAngle != circleRotationAngle) {
      _isAnimating = true;
      _newCircleRotationAngle = newCircleRotationAngle;
      double diff = (_newCircleRotationAngle - circleRotationAngle).abs();
      animationController.reset();
      animationController.duration = Duration(milliseconds: (2000 * diff) ~/ 180);
      animationController.forward();
    }
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
    if (!_isAnimating) {
      _isScrolling = true;
    }
  }

  void processScrollUpdateNotification(ScrollUpdateNotification scrollInfo) {
    if (!_isAnimating) {
      double deltaDegree = 0;
      if (_previousOffset != null) {
        deltaDegree = _distanceToDegrees(((scrollInfo.metrics.pixels - _previousOffset!)));
      }
      _previousOffset = scrollInfo.metrics.pixels;
      if (scrollInfo.dragDetails != null) {
        double x = _translatedX(scrollInfo.dragDetails!.localPosition);
        double y = _translatedY(scrollInfo.dragDetails!.localPosition);
        rotationMultiplier = (x > 0) ? -1 : 1;
      }
      circleRotationAngle += rotationMultiplier * deltaDegree;
      notifyVisibilityOfElements();
      onFrameUpdate();
      if (_previousOffset! <= spinnerWidth) {
        _jumpToMiddle();
      } else if (_previousOffset! >= (spinnerWidth + contentHeight)) {
        _jumpToMiddle();
      }
    }
  }

  void _jumpToMiddle() {
    _previousOffset = spinnerWidth + contentHeight / 2;
    controller.jumpTo(_previousOffset!);
  }

  void processScrollEndNotification(ScrollEndNotification scrollInfo) {
    if (!_isAnimating) {
      _isScrolling = false;
      scrollToNearest();
    }
  }

  double _distanceToDegrees(double translation) => translation * 360 * SpinnerBloc.repeatContent * 2 / contentHeight;

  double _degreesToDistance(double degrees) => degrees * contentHeight / (360 * SpinnerBloc.repeatContent * 2);

  double _convertDegreeToNegativeDegree(double degree) {
    double adjustedDegree = degree % 360;
    return adjustedDegree - 360;
  }
}

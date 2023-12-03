import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/spinner/element_description.dart';

import 'math_utils.dart';
import 'typedefs.dart';

class SpinnerBloc {
  final double spinnerWidth;
  final double radius;
  final double innerRadius;
  final double theta;
  final int numberOfItems;
  late ScrollController controller;
  ValueNotifier<double> circleRotationAngleNotifier = ValueNotifier<double>(0);
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

  List<int> get visibleElementIndexes => _getVisibleElements().map((e) => elementDescriptions.indexOf(e)).toList();

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
  OnElementCameToCenter? onElementCameToCenter;

  ElementDescription get centerItem {
    return elementDescriptions[centerItemIndex];
  }

  int get centerItemIndex => MathUtils.convertDegreeToNegativeDegree((-90 - circleRotationAngleNotifier.value)).abs() ~/ theta;

  void _notifyVisibilityOfElements(SpinnerChangeReason reason) {
    if (_visibleElementsCalculationLastAngle == null ||
        (circleRotationAngleNotifier.value - _visibleElementsCalculationLastAngle!).abs() > 0.2 * theta) {
      _visibleElementsCalculationLastAngle = circleRotationAngleNotifier.value;
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
        onEnteredViewPort!(newlyVisibleElement, reason);
      }
      if (onLeftViewPort != null && newlyHiddenElement.isNotEmpty) {
        onLeftViewPort!(newlyHiddenElement, reason);
      }
      _lastVisibleElements = visibleElements;
    }
  }

  List<ElementDescription> _getVisibleElements() {
    List<ElementDescription> visibleElements = [];
    for (var element in elementDescriptions) {
      double adjustedStartAngle = MathUtils.convertDegreeToNegativeDegree(element.startAngle + circleRotationAngleNotifier.value).abs();
      double adjustedEndAngle = MathUtils.convertDegreeToNegativeDegree(element.endAngle + circleRotationAngleNotifier.value).abs();
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
    this.onElementCameToCenter,
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
    _initializeScrollController();
  }

  void _initializeScrollController() {
    controller = ScrollController(initialScrollOffset: spinnerWidth + contentHeight / 2);
  }

  void _initialize() {
    for (int i = 0; i < numberOfItems; i++) {
      var element = ElementDescription(
        -1 * (theta / 2 + i * theta),
        theta,
      );
      elementDescriptions.add(element);
    }
    _notifyVisibilityOfElements(SpinnerChangeReason.initialize);
    _notifyCenteredElement(SpinnerChangeReason.initialize);
  }

  void _notifyCenteredElement(SpinnerChangeReason reason) {
    if (onElementCameToCenter != null) {
      onElementCameToCenter!(elementDescriptions.indexOf(centerItem), reason);
    }
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
          circleRotationAngleNotifier.value = _newCircleRotationAngle;
          double adjustedRotationAngle = -90 - centerItem.anchorAngle;
          double contentOffset = _degreesToDistance(adjustedRotationAngle) + spinnerWidth;
          _previousOffset = contentOffset;
          if (_previousOffset! <= spinnerWidth) {
            _jumpToMiddle();
          } else if (_previousOffset! >= (spinnerWidth + contentHeight)) {
            _jumpToMiddle();
          } else {
            controller.jumpTo(_previousOffset!);
          }
          _notifyVisibilityOfElements(SpinnerChangeReason.scrollEnd);
          _notifyCenteredElement(SpinnerChangeReason.scrollEnd);
          _isAnimating = false;
        }
        onFrameUpdate();
      })
      ..addListener(() {
        circleRotationAngleNotifier.value = circleRotationAngleNotifier.value + _rotationAnimation.value * (_newCircleRotationAngle - circleRotationAngleNotifier.value);
        onFrameUpdate();
      });
  }

  void scrollToNearest() {
    double newCircleNearestRotationAngle = (circleRotationAngleNotifier.value ~/ (theta / 2) / 2).ceil() * theta;
    _rotateToAngle(newCircleNearestRotationAngle);
  }

  void bringElementAtIndexToCenter(
    int index, {
    required int turns,
  }) {
    double tappedDegree = (elementDescriptions[index].anchorAngle + circleRotationAngleNotifier.value) % 360;
    double adjustedDegree = _getAdjustedDegree(tappedDegree);
    double endAngle = circleRotationAngleNotifier.value + adjustedDegree + turns * 360;
    _rotateToAngle(endAngle);
  }

  int bringTappedElementToCenter(Offset offset) {
    int elementIndex = getElementIndex(offset);
    bringElementAtIndexToCenter(
      elementIndex,
      turns: 0,
    );
    return elementIndex;
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
    if (newCircleRotationAngle != circleRotationAngleNotifier.value) {
      _isAnimating = true;
      _newCircleRotationAngle = newCircleRotationAngle;
      double diff = (_newCircleRotationAngle - circleRotationAngleNotifier.value).abs();
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
    double adjustedTappedDegree = (tappedDegree.abs() + circleRotationAngleNotifier.value) % 360;
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
      circleRotationAngleNotifier.value += rotationMultiplier * deltaDegree;
      _notifyVisibilityOfElements(SpinnerChangeReason.scrolling);
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
}

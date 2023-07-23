import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/spinner_view.dart';

import 'element_description.dart';

class Spinner extends StatefulWidget {
  final int elementsPerHalf;
  final double radius;

  const Spinner({
    Key? key,
    required this.radius,
    required this.elementsPerHalf,
  }) : super(key: key);

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {
  late double spinnerWidth;
  late double outerRadius;
  late double innerRadius;
  late double theta;
  late int numberOfItems;
  late ScrollController controller;
  GlobalKey<_SpinnerState> scrollKey = GlobalKey<_SpinnerState>();
  double _circleRotationAngle = 0;
  int page = 0;
  String rotationAngleText = "";
  late double contentHeight;
  int rotationMultiplier = 1;
  late double circleElementHeight;
  late double anchorRadius;
  late double circleElementWidth;
  double? offset;
  final int repeatContent = 5;
  final List<ElementDescription> _elementDescriptions = [];

  // Method to find the coordinates and
  // setstate method that will set the value to
  // variable posx and posy.
  void onTapDown(BuildContext context, TapDownDetails details) {
    // creating instance of renderbox
    final RenderBox box = context.findRenderObject() as RenderBox;
    // find the coordinate
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    debugPrint("Theta: ${pointToDegree(localOffset)}");
    debugPrint("Is Inside Area: ${checkIfPointClickedOnElement(localOffset)}");
    debugPrint("Element clicked: ${getElement(localOffset)}");
  }

  @override
  void initState() {
    super.initState();
    spinnerWidth = widget.radius * 2;
    numberOfItems = 2 * widget.elementsPerHalf;
    controller = ScrollController(initialScrollOffset: spinnerWidth);
    theta = 360 / numberOfItems;
    outerRadius = spinnerWidth / 2;
    contentHeight = 2 * pi * outerRadius * 0.5 * repeatContent;
    innerRadius = 0.7 * outerRadius;
    circleElementHeight = outerRadius - innerRadius;
    anchorRadius = innerRadius + circleElementHeight / 2;
    circleElementWidth = 20;
    for (int i = 0; i < numberOfItems; i++) {
      _elementDescriptions.add(ElementDescription(-1 * (theta / 2 + i * theta), theta));
    }
    debugPrint("Initialized");
    debugPrint("Spinner Width: $spinnerWidth");
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    List<Widget> circles = [];
    circles.add(_anchorCircle(anchorRadius));
    circles.add(_outerCircle());
    circles.add(_innerCircle());
    return Column(
      children: [
        Container(
          color: Colors.green,
          width: spinnerWidth,
          height: spinnerWidth,
          child: Stack(
            children: [
              // _circles(circles),
              _segmentView(),
              _scrollContainer(),
            ],
          ),
        ),
        Container(
          width: spinnerWidth,
          child: Text(
            rotationAngleText,
            style: const TextStyle(
              inherit: false,
              color: Colors.black,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Positioned _scrollContainer() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: 0.2,
        child: Container(
          height: spinnerWidth,
          child: NotificationListener<ScrollNotification>(
            child: _scrollView(),
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is UserScrollNotification) {
                // if (scrollInfo.direction == ScrollDirection.forward) {
                //   rotationMultiplier = 1;
                // } else if (scrollInfo.direction == ScrollDirection.reverse) {
                //   rotationMultiplier = -1;
                // }
                debugPrint("Direction: ${scrollInfo.direction}");
              } else if (scrollInfo is ScrollUpdateNotification) {
                double delta = 0;
                if (offset != null) {
                  delta = (scrollInfo.metrics.pixels - offset!) * 360 * repeatContent / contentHeight;
                }
                offset = scrollInfo.metrics.pixels;

                //double newRotationAngle = (offset - spinnerWidth) * 360 / contentHeight;
                rotationAngleText = "";
                if (scrollInfo.dragDetails != null) {
                  double x = _translatedX(scrollInfo.dragDetails!.localPosition);
                  double y = _translatedY(scrollInfo.dragDetails!.localPosition);
                  rotationMultiplier = (x > 0) ? -1 : 1;
                }
                setState(() {
                  _circleRotationAngle += rotationMultiplier * delta;
                  rotationAngleText += "Rotation Angle: $_circleRotationAngle";
                });
                if (offset! <= 0) {
                  controller.jumpTo(spinnerWidth);
                } else if (offset! >= (spinnerWidth + contentHeight)) {
                  controller.jumpTo(spinnerWidth);
                }
              }
              return true;
            },
          ),
        ),
      ),
    );
  }

  Positioned _segmentView() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Transform.rotate(
        angle: _radians(_circleRotationAngle),
        child: SpinnerView(
          anchorRadius: anchorRadius,
          spinnerWidth: spinnerWidth,
          sectorHeight: circleElementHeight,
          sectorWidth: circleElementWidth,
          elementDescriptions: _elementDescriptions,
        ),
      ),
    );
  }

  Positioned _circles(List<Widget> circles) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Stack(
        children: circles,
      ),
    );
  }

  Widget _scrollView() {
    double height = (2 * spinnerWidth + contentHeight);
    double viewHeight = 20;
    double numberOfElements = height / viewHeight;
    List<Widget> views = [];
    int i = 0;
    for (i = 0; i < numberOfElements - 1; i++) {
      views.add(
        _scrollMiniView(viewHeight, i),
      );
    }
    views.add(
      Expanded(
        child: _scrollMiniView(viewHeight, i),
      ),
    );
    return GestureDetector(
      onTapDown: (details) => onTapDown(context, details),
      child: SingleChildScrollView(
        key: scrollKey,
        controller: controller,
        physics: ClampingScrollPhysics(),
        child: Container(
          color: Colors.blue,
          height: (2 * spinnerWidth + contentHeight),
          child: Column(
            children: views,
          ),
        ),
      ),
    );
  }

  Container _scrollMiniView(double viewHeight, int i) {
    return Container(
      height: viewHeight,
      color: (i % 2 == 0) ? Colors.red : Colors.blue,
      alignment: Alignment.center,
      child: Text(
        "$i",
        style: TextStyle(
          inherit: false,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _anchorCircle(double anchorRadius) {
    return Container(
      height: spinnerWidth,
      width: spinnerWidth,
      alignment: Alignment.center,
      child: Container(
        height: anchorRadius * 2,
        width: anchorRadius * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(anchorRadius),
          color: Colors.transparent,
          border: Border.all(
            width: 2,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Center _outerCircle() {
    return Center(
      child: Container(
        height: outerRadius * 2,
        width: outerRadius * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(outerRadius),
          color: Colors.transparent,
          border: Border.all(
            width: 2,
            color: Colors.yellow,
          ),
        ),
      ),
    );
  }

  Container _innerCircle() {
    return Container(
      height: spinnerWidth,
      width: spinnerWidth,
      alignment: Alignment.center,
      child: Container(
        height: innerRadius * 2,
        width: innerRadius * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(innerRadius),
          color: Colors.transparent,
          border: Border.all(
            width: 2,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _scrollContent(
    String text,
    Color backgroundColor,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      height: spinnerWidth,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  double _radians(double degrees) {
    return pi * degrees / 180;
  }

  double _degrees(double radians) {
    return radians * 180 / pi;
  }

  double pointToDegree(Offset offset) {
    double x = _translatedX(offset);
    double y = _translatedY(offset);
    double theta = _degrees(atan(y / x));
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
    return (radius >= innerRadius && radius <= outerRadius);
  }

  int getElement(Offset offset) {
    double tappedDegree = pointToDegree(offset);
    double adjustedTappedDegree = (tappedDegree.abs() + _circleRotationAngle) % 360;
    return adjustedTappedDegree ~/ theta;
  }

  double getEndRotationAngle(Offset offset) {
    double tappedDegree = pointToDegree(offset);
    double diff = -90 - tappedDegree;
    return _circleRotationAngle + diff;
  }

  int shiftByElements(int actualIndex, int shiftBy) {
    return (actualIndex + (numberOfItems - shiftBy)) % numberOfItems;
  }
}

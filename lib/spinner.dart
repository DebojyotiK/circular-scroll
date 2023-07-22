import 'dart:math';

import 'package:flutter/material.dart';

class Spinner extends StatefulWidget {
  final double radius;

  const Spinner({Key? key, required this.radius}) : super(key: key);

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {
  late double spinnerWidth;
  late double outerRadius;
  late double innerRadius;
  late double theta;
  int numberOfItems = 14;
  late ScrollController controller;
  GlobalKey<_SpinnerState> scrollKey = GlobalKey<_SpinnerState>();
  double rotationAngle = 0;
  int page = 0;
  String rotationAngleText = "";
  late double contentHeight;
  int rotationMultiplier = 1;
  late double circleElementHeight;
  late double anchorRadius;
  late double circleElementWidth;
  double? offset;
  final int repeatContent = 5;
  late double initialScrollOffset;

  // Method to find the coordinates and
  // setstate method that will set the value to
  // variable posx and posy.
  void onTapDown(BuildContext context, TapDownDetails details) {
    // creating instance of renderbox
    final RenderBox box = context.findRenderObject() as RenderBox;
    // find the coordinate
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    // debugPrint("Theta: ${pointToDegree(localOffset)}");
    // debugPrint("Is Inside Area: ${checkIfPointClickedOnElement(localOffset)}");
    // debugPrint("Element clicked: ${shiftByElements(getElement(localOffset), 3)}");
  }

  @override
  void initState() {
    super.initState();
    spinnerWidth = widget.radius * 2;
    theta = 360 / numberOfItems;
    outerRadius = spinnerWidth / 2;
    contentHeight = 2 * pi * outerRadius * 0.5 * repeatContent;
    initialScrollOffset = spinnerWidth + contentHeight / 2;
    controller = ScrollController(initialScrollOffset: initialScrollOffset);
    innerRadius = 0.7 * outerRadius;
    circleElementHeight = outerRadius - innerRadius;
    anchorRadius = innerRadius + circleElementHeight / 2;
    circleElementWidth = 20;
    controller.addListener(() {
      // double offset = controller.offset;
      // double newRotationAngle = (offset - spinnerWidth) * 360 / contentHeight;
      // setState(() {
      //   rotationAngle = newRotationAngle;
      // });
      // if (offset <= 0) {
      //   controller.jumpTo(spinnerWidth);
      // } else if (offset >= (spinnerWidth + contentHeight)) {
      //   controller.jumpTo(spinnerWidth);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    List<Widget> circles = [];
    circles.add(_anchorCircle(anchorRadius));
    circles.add(_outerCircle());
    circles.add(_innerCircle());
    for (int i = 0; i < numberOfItems; i++) {
      double dx = anchorRadius * (cos(_radians(90 + i * theta)) - cos(_radians(90)));
      double dy = -1 * anchorRadius * (sin(_radians(90 + i * theta)) - sin(_radians(90)));
      double rotationAngle = _radians(-1 * i * theta);
      Offset translation = Offset(dx, dy);
      Widget container = Positioned(
        top: 0,
        left: (spinnerWidth - circleElementWidth) / 2,
        child: Transform.translate(
          offset: translation,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Container(
              height: circleElementHeight,
              width: circleElementWidth,
              color: Colors.black,
              alignment: Alignment.center,
              child: Text(
                "$i",
                style: TextStyle(
                  inherit: false,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
      elements.add(container);
    }
    return Column(
      children: [
        Container(
          color: Colors.green,
          width: spinnerWidth,
          height: spinnerWidth * 2,
          child: Stack(
            children: [
              _circles(circles),
              _segments(elements),
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
      top: spinnerWidth,
      left: 0,
      right: 0,
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
                rotationAngle += rotationMultiplier * delta;
                rotationAngleText += "Rotation Angle: $rotationAngle";
              });
              if (offset! <= 0) {
                controller.jumpTo(initialScrollOffset);
              } else if (offset! >= (spinnerWidth + contentHeight)) {
                controller.jumpTo(initialScrollOffset);
              }
            }
            return true;
          },
        ),
      ),
    );
  }

  Positioned _segments(List<Widget> elements) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Transform.rotate(
        angle: _radians(rotationAngle),
        child: Container(
          width: spinnerWidth,
          height: spinnerWidth,
          child: Stack(
            children: elements,
          ),
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
    return SingleChildScrollView(
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
      return theta.abs();
    } else if (x < 0 && y < 0) {
      return 180 - theta.abs();
    } else if (x < 0 && y > 0) {
      return 180 + theta.abs();
    } else {
      return 360 - theta.abs();
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
    return tappedDegree ~/ theta;
  }

  int shiftByElements(int actualIndex, int shiftBy) {
    return (actualIndex + (numberOfItems - shiftBy)) % numberOfItems;
  }
}

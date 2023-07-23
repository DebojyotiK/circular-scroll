import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/spinner_bloc.dart';
import 'package:spinner/spinner_view.dart';

import 'math_utils.dart';

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
  GlobalKey<_SpinnerState> scrollKey = GlobalKey<_SpinnerState>();
  late SpinnerBloc _bloc;

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
    _bloc = SpinnerBloc(
      elementsPerHalf: widget.elementsPerHalf,
      innerRadius: 0.7 * widget.radius,
      radius: widget.radius,
    );
    debugPrint("Initialized");
    debugPrint("Spinner Width: ${_bloc.spinnerWidth}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.green,
          width: _bloc.spinnerWidth,
          height: _bloc.spinnerWidth,
          child: Stack(
            children: [
              _segmentView(),
              _scrollContainer(),
            ],
          ),
        ),
        SizedBox(
          width: _bloc.spinnerWidth,
          child: Text(
            _bloc.rotationAngleText,
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
        child: SizedBox(
          height: _bloc.spinnerWidth,
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
                if (_bloc.offset != null) {
                  delta = (scrollInfo.metrics.pixels - _bloc.offset!) * 360 * SpinnerBloc.repeatContent / _bloc.contentHeight;
                }
                _bloc.offset = scrollInfo.metrics.pixels;

                //double newRotationAngle = (offset - spinnerWidth) * 360 / contentHeight;
                _bloc.rotationAngleText = "";
                if (scrollInfo.dragDetails != null) {
                  double x = _translatedX(scrollInfo.dragDetails!.localPosition);
                  double y = _translatedY(scrollInfo.dragDetails!.localPosition);
                  _bloc.rotationMultiplier = (x > 0) ? -1 : 1;
                }
                setState(() {
                  _bloc.circleRotationAngle += _bloc.rotationMultiplier * delta;
                  _bloc.rotationAngleText += "Rotation Angle: ${_bloc.circleRotationAngle}";
                });
                if (_bloc.offset! <= 0) {
                  _bloc.controller.jumpTo(_bloc.spinnerWidth);
                } else if (_bloc.offset! >= (_bloc.spinnerWidth + _bloc.contentHeight)) {
                  _bloc.controller.jumpTo(_bloc.spinnerWidth);
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
        angle: MathUtils.radians(_bloc.circleRotationAngle),
        child: SpinnerView(
          anchorRadius: _bloc.anchorRadius,
          spinnerWidth: _bloc.spinnerWidth,
          sectorHeight: _bloc.circleElementHeight,
          sectorWidth: _bloc.circleElementWidth,
          elementDescriptions: _bloc.elementDescriptions,
        ),
      ),
    );
  }

  Widget _scrollView() {
    double height = (2 * _bloc.spinnerWidth + _bloc.contentHeight);
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
        controller: _bloc.controller,
        physics: const ClampingScrollPhysics(),
        child: Container(
          color: Colors.blue,
          height: (2 * _bloc.spinnerWidth + _bloc.contentHeight),
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
        style: const TextStyle(
          inherit: false,
          color: Colors.white,
          fontSize: 12,
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
      height: _bloc.spinnerWidth,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
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

  double _translatedY(Offset offset) => offset.dy - _bloc.spinnerWidth / 2;

  double _translatedX(Offset offset) => offset.dx - _bloc.spinnerWidth / 2;

  bool checkIfPointClickedOnElement(Offset offset) {
    double x = _translatedX(offset);
    double y = _translatedY(offset);
    double radius = sqrt(pow(x, 2) + pow(y, 2));
    return (radius >= _bloc.innerRadius && radius <= radius);
  }

  int getElement(Offset offset) {
    double tappedDegree = pointToDegree(offset);
    double adjustedTappedDegree = (tappedDegree.abs() + _bloc.circleRotationAngle) % 360;
    return adjustedTappedDegree ~/ _bloc.theta;
  }

  double getEndRotationAngle(Offset offset) {
    double tappedDegree = pointToDegree(offset);
    double diff = -90 - tappedDegree;
    return _bloc.circleRotationAngle + diff;
  }

  int shiftByElements(int actualIndex, int shiftBy) {
    return (actualIndex + (_bloc.numberOfItems - shiftBy)) % _bloc.numberOfItems;
  }
}

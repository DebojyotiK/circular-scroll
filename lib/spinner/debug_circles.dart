import 'package:flutter/material.dart';

class DebugCircles extends StatelessWidget {
  final double anchorRadius;
  final double outerRadius;
  final double innerRadius;
  final double spinnerWidth;

  const DebugCircles({
    Key? key,
    required this.anchorRadius,
    required this.spinnerWidth,
  })  : outerRadius = spinnerWidth / 2,
        innerRadius = 2 * anchorRadius - spinnerWidth / 2,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: spinnerWidth,
      width: spinnerWidth,
      child: Stack(
        children: [
          _anchorCircle(),
          _outerCircle(),
          _innerCircle(),
          _xAxis(),
          _yAxis(),
        ],
      ),
    );
  }

  Widget _xAxis() {
    return Positioned(
      left: 0,
      top: spinnerWidth / 2 - 1,
      child: Container(
        width: spinnerWidth,
        height: 2,
        color: Colors.black,
      ),
    );
  }

  Widget _yAxis() {
    return Positioned(
      left: spinnerWidth / 2 - 1,
      top: 0,
      child: Container(
        width: 2,
        height: spinnerWidth,
        color: Colors.black,
      ),
    );
  }

  Widget _anchorCircle() {
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
            color: Colors.black,
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
}

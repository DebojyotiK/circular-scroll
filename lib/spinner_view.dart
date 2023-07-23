import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/debug_circles.dart';
import 'package:spinner/element_description.dart';

import 'math_utils.dart';

class SpinnerView extends StatelessWidget {
  final double anchorRadius;
  final double spinnerWidth;
  final double sectorHeight;
  final double sectorWidth;
  final List<ElementDescription> elementDescriptions;
  final bool showDebugCircles;

  const SpinnerView({
    Key? key,
    required this.elementDescriptions,
    required this.spinnerWidth,
    required this.anchorRadius,
    required this.sectorHeight,
    required this.sectorWidth,
    this.showDebugCircles = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    if (showDebugCircles) {
      elements.add(
        DebugCircles(
          anchorRadius: anchorRadius,
          spinnerWidth: spinnerWidth,
        ),
      );
    }
    for (var elementDescription in elementDescriptions) {
      int elementIndex = (elementDescriptions.indexOf(elementDescription));
      double x = anchorRadius * (cos(MathUtils.radians(elementDescription.anchorAngle.abs())));
      double y = anchorRadius * (sin(MathUtils.radians(elementDescription.anchorAngle.abs())));
      double dx = x - anchorRadius;
      double dy = -1 * y;
      double rotationAngle = MathUtils.radians(elementDescription.anchorAngle);
      Offset translation = Offset(dx, dy);
      Widget container = Positioned(
        top: (spinnerWidth - sectorWidth) / 2,
        right: 0,
        child: Transform.translate(
          offset: translation,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Container(
              height: sectorWidth,
              width: sectorHeight,
              color: Colors.black,
              alignment: Alignment.center,
              child: Text(
                "$elementIndex",
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
    return Container(
      width: spinnerWidth,
      height: spinnerWidth,
      child: Stack(
        children: elements,
      ),
    );
  }
}

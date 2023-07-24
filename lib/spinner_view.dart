import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/arc_view.dart';
import 'package:spinner/element_description.dart';

import 'math_utils.dart';
import 'typedefs.dart';

class SpinnerView extends StatelessWidget {
  final double anchorRadius;
  final double spinnerWidth;
  final double outerRadius;
  final double innerRadius;
  final double sectorHeight;
  final double sectorWidth;
  final double sectorTheta;
  final List<ElementDescription> elementDescriptions;
  final CircularElementBuilder elementBuilder;

  const SpinnerView({
    Key? key,
    required this.elementDescriptions,
    required this.spinnerWidth,
    required this.anchorRadius,
    required this.innerRadius,
    required this.outerRadius,
    required this.sectorHeight,
    required this.sectorWidth,
    required this.sectorTheta,
    required this.elementBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    for (var elementDescription in elementDescriptions) {
      int elementIndex = (elementDescriptions.indexOf(elementDescription));
      double x = anchorRadius * (cos(MathUtils.radians(elementDescription.anchorAngle.abs())));
      double y = anchorRadius * (sin(MathUtils.radians(elementDescription.anchorAngle.abs())));
      double dx = x - anchorRadius;
      double dy = -1 * y;
      double rotationAngle = MathUtils.radians(elementDescription.anchorAngle);
      Offset translation = Offset(dx, dy);
      Widget container = Transform.rotate(
        angle: rotationAngle,
        child: Container(
          width: spinnerWidth,
          height: spinnerWidth,
          alignment: Alignment.centerRight,
          child: _child(elementIndex),
        ),
      );
      elements.add(container);
    }
    return SizedBox(
      width: spinnerWidth,
      height: spinnerWidth,
      child: Stack(
        children: elements,
      ),
    );
  }

  Widget _child(int elementIndex) {
    var sinThetaBy2 = sin(MathUtils.radians(sectorTheta / 2));
    return Transform.translate(
      offset: Offset((sectorWidth - sectorHeight) / 2, 0),
      child: Transform.rotate(
        angle: MathUtils.radians(90),
        child: Transform.scale(
          child: _arcView(elementIndex),
          scale: 0.95,
        ),
      ),
    );
  }

  Widget _arcView(int elementIndex) {
    return ArcView(
      segmentWidth: sectorWidth,
      segmentHeight: sectorHeight,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      theta: sectorTheta,
      elementBuilder: elementBuilder,
      index: elementIndex,
    );
  }
}

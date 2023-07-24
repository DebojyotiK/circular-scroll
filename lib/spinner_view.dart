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
      Widget container = Positioned(
        top: (spinnerWidth - sectorWidth) / 2,
        right: 0,
        child: Transform.translate(
          offset: translation,
          child: Transform.rotate(
            angle: rotationAngle,
            child: _child(elementIndex),
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

  Widget _child(int elementIndex) {
    return Transform.rotate(
      angle: MathUtils.radians(90),
      child: ArcView(
        segmentWidth: sectorWidth,
        segmentHeight: sectorHeight,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        theta: sectorTheta,
        elementBuilder: elementBuilder,
        index: elementIndex,
      ),
    );
  }
}

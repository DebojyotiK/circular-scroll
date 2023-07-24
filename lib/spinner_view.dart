import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/arc_view.dart';
import 'package:spinner/spinner_bloc.dart';

import 'math_utils.dart';
import 'typedefs.dart';

double initialScale = 0.9;
double finalScale = 1;

class SpinnerView extends StatelessWidget {
  final CircularElementBuilder elementBuilder;
  final SpinnerBloc bloc;

  const SpinnerView({
    Key? key,
    required this.elementBuilder,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [];
    for (var elementDescription in bloc.elementDescriptions) {
      int elementIndex = (bloc.elementDescriptions.indexOf(elementDescription));
      double x = bloc.anchorRadius * (cos(MathUtils.radians(elementDescription.anchorAngle.abs())));
      double y = bloc.anchorRadius * (sin(MathUtils.radians(elementDescription.anchorAngle.abs())));
      double dx = x - bloc.anchorRadius;
      double dy = -1 * y;
      double rotationAngle = MathUtils.radians(elementDescription.anchorAngle);
      Offset translation = Offset(dx, dy);
      Widget container = Transform.rotate(
        angle: rotationAngle,
        child: Container(
          width: bloc.spinnerWidth,
          height: bloc.spinnerWidth,
          alignment: Alignment.centerRight,
          child: _child(elementIndex),
        ),
      );
      elements.add(container);
    }
    return SizedBox(
      width: bloc.spinnerWidth,
      height: bloc.spinnerWidth,
      child: Stack(
        children: elements,
      ),
    );
  }

  Widget _child(int elementIndex) {
    return Transform.translate(
      offset: Offset((bloc.segmentWidth - bloc.segmentHeight) / 2, 0),
      child: Transform.rotate(
        angle: MathUtils.radians(90),
        child: ValueListenableBuilder<double>(
          valueListenable: bloc.circleRotationAngleNotifier,
          builder: (context, value, child) {
            return Transform.scale(
              scale: _getScale(elementIndex),
              child: _arcView(elementIndex),
            );
          },
        ),
      ),
    );
  }

  Widget _arcView(int elementIndex) {
    return ArcView(
      segmentWidth: bloc.segmentWidth,
      segmentHeight: bloc.segmentHeight,
      innerRadius: bloc.innerRadius,
      outerRadius: bloc.radius,
      theta: bloc.theta,
      elementBuilder: elementBuilder,
      index: elementIndex,
    );
  }

  double _getScale(int index) {
    double currentAnchorAngle = bloc.elementDescriptions[index].anchorAngle + bloc.circleRotationAngleNotifier.value;
    double adjustedAnchorAngle = MathUtils.convertDegreeToNegativeDegree(currentAnchorAngle).abs();
    if (adjustedAnchorAngle > 0 && adjustedAnchorAngle <= 180) {
      if (adjustedAnchorAngle > 90 && adjustedAnchorAngle <= 180) {
        adjustedAnchorAngle = 180 - adjustedAnchorAngle;
      }
      double scale = ((finalScale - initialScale) * adjustedAnchorAngle) / 90 + initialScale;
      return scale;
    } else {
      return 1.0;
    }
  }
}

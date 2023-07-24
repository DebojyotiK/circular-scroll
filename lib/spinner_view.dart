import 'package:flutter/material.dart';
import 'package:spinner/arc_view.dart';
import 'package:spinner/spinner_bloc.dart';

import 'math_utils.dart';
import 'typedefs.dart';

double initialScale = 0.65;
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
      double rotationAngle = MathUtils.radians(elementDescription.anchorAngle);
      Widget container = ValueListenableBuilder<double>(
        valueListenable: bloc.circleRotationAngleNotifier,
        builder: (context, value, child) {
          return Transform.rotate(
            angle: rotationAngle,
            child: Container(
              width: bloc.spinnerWidth,
              height: bloc.spinnerWidth,
              alignment: Alignment.centerRight,
              child: _child(elementIndex),
            ),
          );
        },
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
        child: Transform.scale(
          scale: _getScale(elementIndex),
          child: Transform.scale(
            scale: 0.95,
            child: _arcView(elementIndex),
          ),
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
    double adjustedAnchorAngle = _getAdjustedAnchorAngle(index);
    double scale = ((finalScale - initialScale) * adjustedAnchorAngle) / 90 + initialScale;
    return scale;
  }

  double _getAdjustedAnchorAngle(int index) {
    double currentAnchorAngle = bloc.elementDescriptions[index].anchorAngle + bloc.circleRotationAngleNotifier.value;
    double adjustedAnchorAngle = MathUtils.convertDegreeToNegativeDegree(currentAnchorAngle).abs();
    if (adjustedAnchorAngle > 90 && adjustedAnchorAngle <= 180) {
      adjustedAnchorAngle = 180 - adjustedAnchorAngle;
    } else if (adjustedAnchorAngle > 180 && adjustedAnchorAngle <= 270) {
      adjustedAnchorAngle = adjustedAnchorAngle % 180;
    } else if (adjustedAnchorAngle > 270 && adjustedAnchorAngle < 360) {
      adjustedAnchorAngle = 360 - adjustedAnchorAngle;
    }
    return adjustedAnchorAngle;
  }
}

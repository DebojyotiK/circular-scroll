import 'package:flutter/material.dart';
import 'package:spinner/spinner/arc_clipper.dart';

import 'typedefs.dart';

class ArcView extends StatelessWidget {
  const ArcView({
    super.key,
    required this.segmentWidth,
    required this.segmentHeight,
    required this.innerRadius,
    required this.outerRadius,
    required this.theta,
    required this.elementBuilder,
    required this.index,
  });

  final double segmentWidth;
  final double segmentHeight;
  final double innerRadius;
  final double outerRadius;
  final double theta;
  final int index;
  final CircularElementBuilder elementBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: segmentWidth,
      height: segmentHeight,
      child: ClipPath(
        clipper: ArcClipper(
          innerRadius: innerRadius,
          outerRadius: outerRadius,
          arcTheta: theta,
        ),
        child: elementBuilder(index),
      ),
    );
  }
}

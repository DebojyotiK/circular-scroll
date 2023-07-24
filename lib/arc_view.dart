import 'package:flutter/material.dart';
import 'package:spinner/arc_clipper.dart';

class ArcView extends StatelessWidget {
  const ArcView({
    super.key,
    required this.segmentWidth,
    required this.segmentHeight,
    required this.innerRadius,
    required this.outerRadius,
    required this.theta,
  });

  final double segmentWidth;
  final double segmentHeight;
  final double innerRadius;
  final double outerRadius;
  final double theta;

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
        child: Container(
          color: Colors.blue,
          child: Image.asset(
            "assets/biryani.jpeg",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

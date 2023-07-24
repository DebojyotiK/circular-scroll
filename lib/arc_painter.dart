import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/math_utils.dart';

class ArcPainter extends CustomPainter {
  final double arcTheta;
  final double outerRadius;
  final double innerRadius;

  ArcPainter({
    required this.arcTheta,
    required this.outerRadius,
    required this.innerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.strokeWidth = 2;
    paint.color = Colors.blue;
    paint.style = PaintingStyle.fill;
    var cosThetaBy2 = cos(MathUtils.radians(arcTheta / 2));
    var sinThetaBy2 = sin(MathUtils.radians(arcTheta / 2));
    var shape = Path();
    var lowerArcStartX = (outerRadius - innerRadius) * sinThetaBy2;
    var lowerArcEndX = (outerRadius + innerRadius) * sinThetaBy2;
    var lowerArcY = outerRadius - innerRadius * cosThetaBy2;
    var lineEndX = 2 * outerRadius * sinThetaBy2;
    var lineEndY = outerRadius * (1 - cosThetaBy2);
    shape.moveTo(lowerArcStartX, lowerArcY);
    shape.arcToPoint(
      Offset(lowerArcEndX, lowerArcY),
      radius: Radius.circular(innerRadius),
    );
    shape.lineTo(lineEndX, lineEndY);
    shape.arcToPoint(
      Offset(0, lineEndY),
      radius: Radius.circular(outerRadius),
      clockwise: false,
    );
    shape.close();
    // lowerArc.lineTo(2 * outerRadius * sinThetaBy2, outerRadius * (1 - cosThetaBy2));
    canvas.drawPath(shape, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

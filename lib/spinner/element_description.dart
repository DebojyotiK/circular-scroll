class ElementDescription {
  final double startAngle;
  final double anchorAngle;
  final double endAngle;

  ElementDescription(
    this.anchorAngle,
    double spanTheta,
  )   : startAngle = anchorAngle + spanTheta / 2,
        endAngle = anchorAngle - spanTheta / 2;
}

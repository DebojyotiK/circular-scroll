class ElementDescription {
  final double startAngle;
  final double anchorAngle;
  final double endAngle;
  final String description;

  ElementDescription(
    this.anchorAngle,
    double spanTheta,
    this.description,
  )   : startAngle = anchorAngle + spanTheta / 2,
        endAngle = anchorAngle - spanTheta / 2;
}

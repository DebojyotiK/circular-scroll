import 'package:flutter/material.dart';
import 'package:spinner/circular_scroll_view.dart';
import 'package:spinner/spinner_bloc.dart';
import 'package:spinner/spinner_view.dart';

import 'debug_circles.dart';
import 'math_utils.dart';

class Spinner extends StatefulWidget {
  final int elementsPerHalf;
  final double radius;
  final bool showDebugCircles;

  const Spinner({
    Key? key,
    required this.radius,
    required this.elementsPerHalf,
    this.showDebugCircles = true,
  }) : super(key: key);

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  GlobalKey<_SpinnerState> scrollKey = GlobalKey<_SpinnerState>();
  late SpinnerBloc _bloc;

  // Method to find the coordinates and
  // setstate method that will set the value to
  // variable posx and posy.
  void onTapUp(BuildContext context, TapUpDetails details) {
    if (!_bloc.isScrolling && !_bloc.isAnimating) {
      _bloc.bringTappedElementToCenter(details.localPosition);
    }
  }

  @override
  void initState() {
    super.initState();
    _bloc = SpinnerBloc(
      elementsPerHalf: widget.elementsPerHalf,
      innerRadius: 0.7 * widget.radius,
      radius: widget.radius,
      animationController: AnimationController(
        vsync: this,
      ),
      onFrameUpdate: () {
        setState(() {});
      },
    );
    debugPrint("Initialized");
    debugPrint("Spinner Width: ${_bloc.spinnerWidth}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.green,
          width: _bloc.spinnerWidth,
          height: _bloc.spinnerWidth,
          child: Stack(
            children: [
              if (widget.showDebugCircles)
                DebugCircles(
                  anchorRadius: _bloc.anchorRadius,
                  spinnerWidth: _bloc.spinnerWidth,
                ),
              _spinnerView(),
              _scrollContainer(),
            ],
          ),
        ),
        SizedBox(
          width: _bloc.spinnerWidth,
          child: Text(
            "Rotation Angle: ${_bloc.circleRotationAngle}\n"
            "offset: ${(_bloc.controller.hasClients) ? _bloc.controller.offset : ""}",
            style: const TextStyle(
              inherit: false,
              color: Colors.black,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        GestureDetector(
          onTap: () {
            debugPrint("Center Item: ${_bloc.centerItem.description}");
          },
          child: SizedBox(
            width: _bloc.spinnerWidth,
            child: const Text(
              "Scroll to nearest",
              style: TextStyle(
                inherit: false,
                color: Colors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: _bloc.spinnerWidth,
          child: Text(
            _bloc.visibleElementText,
            style: const TextStyle(
              inherit: false,
              color: Colors.black,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Positioned _scrollContainer() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: NotificationListener<ScrollNotification>(
        child: CircularScrollView(
          bloc: _bloc,
          key: scrollKey,
          onTapUp: (details) => onTapUp(context, details),
        ),
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollStartNotification) {
            _bloc.processScrollStartNotification(scrollInfo);
          } else if (scrollInfo is ScrollUpdateNotification) {
            _bloc.processScrollUpdateNotification(scrollInfo);
          } else if (scrollInfo is ScrollEndNotification) {
            _bloc.processScrollEndNotification(scrollInfo);
          }
          return true;
        },
      ),
    );
  }

  Positioned _spinnerView() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Transform.rotate(
        angle: MathUtils.radians(_bloc.circleRotationAngle),
        child: SpinnerView(
          anchorRadius: _bloc.anchorRadius,
          spinnerWidth: _bloc.spinnerWidth,
          sectorHeight: _bloc.circleElementHeight,
          sectorWidth: _bloc.circleElementWidth,
          elementDescriptions: _bloc.elementDescriptions,
        ),
      ),
    );
  }
}

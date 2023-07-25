import 'package:flutter/material.dart';
import 'package:spinner/circular_scroll_view.dart';
import 'package:spinner/spinner_bloc.dart';
import 'package:spinner/spinner_view.dart';

import 'debug_circles.dart';
import 'math_utils.dart';
import 'typedefs.dart';

part 'spinner_controller.dart';

class Spinner extends StatefulWidget {
  final int elementsPerHalf;
  final double radius;
  final double innerRadius;
  final bool showDebugViews;
  final OnEnteredViewPort? onEnteredViewPort;
  final OnLeftViewPort? onLeftViewPort;
  final OnElementTapped? onElementTapped;
  final OnElementCameToCenter? onElementCameToCenter;
  final CircularElementBuilder elementBuilder;
  final SpinnerController? spinnerController;

  const Spinner({
    Key? key,
    required this.radius,
    required this.innerRadius,
    required this.elementsPerHalf,
    required this.elementBuilder,
    this.spinnerController,
    this.onElementTapped,
    this.onElementCameToCenter,
    this.onEnteredViewPort,
    this.onLeftViewPort,
    this.showDebugViews = true,
  }) : super(key: key);

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  final GlobalKey<_SpinnerState> _scrollKey = GlobalKey<_SpinnerState>();
  late SpinnerBloc _bloc;

  void onTapUp(BuildContext context, TapUpDetails details) {
    if (!_bloc.isScrolling && !_bloc.isAnimating) {
      int elementIndex = _bloc.bringTappedElementToCenter(details.localPosition);
      if (widget.onElementTapped != null) {
        widget.onElementTapped!(elementIndex);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _bloc = SpinnerBloc(
      elementsPerHalf: widget.elementsPerHalf,
      innerRadius: widget.innerRadius,
      radius: widget.radius,
      animationController: AnimationController(
        vsync: this,
      ),
      onFrameUpdate: () {
        setState(() {});
      },
      onEnteredViewPort: widget.onEnteredViewPort,
      onLeftViewPort: widget.onLeftViewPort,
      onElementCameToCenter: widget.onElementCameToCenter,
    );
    widget.spinnerController?._bloc = _bloc;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _bloc.spinnerWidth,
          height: _bloc.spinnerWidth / 2,
          child: Stack(
            children: [
              if (widget.showDebugViews)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: DebugCircles(
                    anchorRadius: _bloc.anchorRadius,
                    spinnerWidth: _bloc.spinnerWidth,
                  ),
                ),
              _spinnerView(),
              _scrollContainer(),
            ],
          ),
        ),
        if (widget.showDebugViews)
          Column(
            children: [
              SizedBox(
                width: _bloc.spinnerWidth,
                child: Text(
                  "Rotation Angle: ${_bloc.circleRotationAngleNotifier.value}\n"
                  "offset: ${(_bloc.controller.hasClients) ? _bloc.controller.offset : ""}",
                  style: const TextStyle(
                    inherit: false,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
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
              )
            ],
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
          key: _scrollKey,
          onTapUp: (details) => onTapUp(context, details),
          showDebugViews: widget.showDebugViews,
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
        angle: MathUtils.radians(_bloc.circleRotationAngleNotifier.value),
        child: SpinnerView(
          bloc: _bloc,
          elementBuilder: widget.elementBuilder,
        ),
      ),
    );
  }
}

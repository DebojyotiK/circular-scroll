import 'package:flutter/material.dart';
import 'spinner_bloc.dart';

class CircularScrollView extends StatelessWidget {
  final GestureTapUpCallback? onTapUp;
  final SpinnerBloc bloc;
  final bool showDebugViews;

  const CircularScrollView({
    Key? key,
    this.onTapUp,
    required this.showDebugViews,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> views = [];
    if (showDebugViews) {
      double height = (2 * bloc.spinnerWidth + bloc.contentHeight);
      double viewHeight = 20;
      double numberOfElements = height / viewHeight;
      int i = 0;
      for (i = 0; i < numberOfElements - 1; i++) {
        views.add(
          _scrollMiniView(viewHeight, i),
        );
      }
      views.add(
        Expanded(
          child: _scrollMiniView(viewHeight, i),
        ),
      );
    } else {
      views.add(
        const Expanded(
          child: SizedBox(),
        ),
      );
    }
    return Opacity(
      opacity: showDebugViews ? 0.5 : 0,
      child: SizedBox(
        height: bloc.spinnerWidth,
        child: GestureDetector(
          onTapUp: onTapUp,
          child: SingleChildScrollView(
            controller: bloc.controller,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: (2 * bloc.spinnerWidth + bloc.contentHeight),
              child: Column(
                children: views,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _scrollMiniView(double viewHeight, int i) {
    return Container(
      height: viewHeight,
      color: (i % 2 == 0) ? Colors.red : Colors.blue,
      alignment: Alignment.center,
      child: Text(
        "$i",
        style: const TextStyle(
          inherit: false,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}

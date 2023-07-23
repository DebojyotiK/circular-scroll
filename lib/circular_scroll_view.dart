import 'package:flutter/material.dart';
import 'package:spinner/spinner_bloc.dart';

class CircularScrollView extends StatelessWidget {
  final GestureTapDownCallback? onTapDown;
  final SpinnerBloc bloc;

  const CircularScrollView({
    Key? key,
    this.onTapDown,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = (2 * bloc.spinnerWidth + bloc.contentHeight);
    double viewHeight = 20;
    double numberOfElements = height / viewHeight;
    List<Widget> views = [];
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
    return Opacity(
      opacity: 0.2,
      child: SizedBox(
        height: bloc.spinnerWidth,
        child: GestureDetector(
          onTapDown: onTapDown,
          child: SingleChildScrollView(
            controller: bloc.controller,
            physics: const ClampingScrollPhysics(),
            child: Container(
              color: Colors.blue,
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

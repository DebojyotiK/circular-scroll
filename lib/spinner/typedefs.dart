import 'package:flutter/material.dart';

enum SpinnerChangeReason {
  initialize,
  scrollEnd,
  scrolling,
}

typedef CircularElementBuilder = Widget Function(int index);
typedef OnEnteredViewPort = void Function(List<int> index, SpinnerChangeReason reason);
typedef OnLeftViewPort = void Function(List<int> index, SpinnerChangeReason reason);
typedef OnElementTapped = void Function(int index);
typedef OnElementCameToCenter = void Function(int index,SpinnerChangeReason reason);

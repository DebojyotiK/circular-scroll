import 'package:flutter/material.dart';

typedef CircularElementBuilder = Widget Function(int index);
typedef OnEnteredViewPort = void Function(List<int> index);
typedef OnLeftViewPort = void Function(List<int> index);
typedef OnElementTapped = void Function(int index);
typedef OnElementCameToCenter = void Function(int index);

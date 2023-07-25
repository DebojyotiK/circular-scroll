import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';

class ImageRepo {
  CancelableOperation<List<String>>? operation;
  final Random _random = Random();

  Future<List<String>> fetchImages(int count) {
    operation?.cancel();
    operation = CancelableOperation.fromFuture(
      _fetchImages(count),
      onCancel: () {},
    );
    return operation!.value;
  }

  void cancelFetchingImages() {
    operation?.cancel();
    operation = null;
  }

  Future<List<String>> _fetchImages(int count) async {
    await Future.delayed(Duration(milliseconds: _random.nextInt(300) + 200), () {});
    List<String> imagePaths = [];
    for (int i = 0; i < count; i++) {
      imagePaths.add("assets/${_random.nextInt(13)}.jpeg");
    }
    return imagePaths;
  }

}

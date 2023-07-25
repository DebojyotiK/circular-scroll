import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';

typedef OnImageFetchSuccess = void Function(List<String> images);
typedef OnImageFetchFailure = void Function();

class ImageRepo {
  CancelableOperation? operation;
  final Random _random = Random();

  void fetchImages(
    int count, {
    OnImageFetchSuccess? onImageFetchSuccess,
    OnImageFetchFailure? onImageFetchFailure,
  }) {
    operation?.cancel();
    operation = CancelableOperation.fromFuture(
      () async {
        List<String> images = await _fetchImages(count);
        if (onImageFetchSuccess != null) {
          onImageFetchSuccess(images);
        }
      }(),
      onCancel: () {
        debugPrint("Cancelled");
      },
    );
  }

  void cancelFetchingImages() {
    operation?.cancel();
    operation = null;
  }

  Future<List<String>> _fetchImages(int count) async {
    await Future.delayed(Duration(milliseconds: _random.nextInt(1200) + 800), () {});
    List<String> imagePaths = [];
    for (int i = 0; i < count; i++) {
      imagePaths.add("assets/${_random.nextInt(13)}.jpeg");
    }
    return imagePaths;
  }
}

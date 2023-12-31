import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';

import 'image_repo.dart';

class LocalImageFetchImpl extends ImageRepo {
  CancelableOperation<List<String>>? operation;

  @override
  Future<List<String>> fetchImages(int count) {
    operation?.cancel();
    operation = CancelableOperation.fromFuture(
      _fetchImages(count),
      onCancel: () {},
    );
    return operation!.value;
  }

  @override
  void cancelFetchingImages() {
    operation?.cancel();
    operation = null;
  }

  Future<List<String>> _fetchImages(int count) async {
    await Future.delayed(Duration(milliseconds: _apiFetchTime()), () {});
    List<String> imagePaths = [];
    for (int i = 0; i < count; i++) {
      imagePaths.add("assets/${Random().nextInt(24)}.jpeg");
    }
    return imagePaths;
  }

  int _apiFetchTime() => Random().nextInt(300) + 200;
}

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:spinner/image_repo.dart';
import 'package:spinner/spinner.dart';

import 'image_fetching_state.dart';

class ImageFetcher {
  final ImageRepo _repo = ImageRepo();
  final List<ValueNotifier<ImageFetchingState>> _imageStates = [];
  final int _numberOfItems;
  final SpinnerController spinnerController;
  final List<int> _indexesToBeLoaded = [];
  final ValueNotifier<int> _totalResultsFetchedTillDateNotifier = ValueNotifier(0);

  ValueNotifier<int> get totalResultsFetchedTillDateNotifier => _totalResultsFetchedTillDateNotifier;

  List<ValueNotifier<ImageFetchingState>> get imageStates => List.from(_imageStates);

  ImageFetcher({
    required int numberOfItemsPerHalf,
    required this.spinnerController,
  }) : _numberOfItems = 2 * numberOfItemsPerHalf {
    for (int i = 0; i < _numberOfItems; i++) {
      _imageStates.add(ValueNotifier(ImageFetchingProgressState()));
    }
  }

  void fetchImage(int index) async {
    _imageStates[index].value = ImageFetchingProgressState();
    if (!_indexesToBeLoaded.contains(index)) {
      _indexesToBeLoaded.add(index);
      List<String> images = await _repo.fetchImages(
        _indexesToBeLoaded.length,
      );
      _processFetchedImages(images);
    }
  }

  void cancelFetchingImage(int index) {
    _imageStates[index].value = ImageFetchingProgressState();
    if (_indexesToBeLoaded.contains(index)) {
      _indexesToBeLoaded.remove(index);
    }
  }

  void _processFetchedImages(List<String> images) {
    int minLength = min(images.length, _indexesToBeLoaded.length);
    for (int i = 0; i < minLength; i++) {
      int currentIndexToBeLoaded = _indexesToBeLoaded[i];
      String image = images[i];
      var currentNotifier = _imageStates[currentIndexToBeLoaded];
      currentNotifier.value = ImageFetchingSuccessState(image);
    }
    _totalResultsFetchedTillDateNotifier.value += minLength;
    _indexesToBeLoaded.clear();
  }
}

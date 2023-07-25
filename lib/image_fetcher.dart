import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:spinner/image_repo.dart';
import 'package:spinner/spinner.dart';

import 'image_fetching_state.dart';

class ImageFetcher {
  int _pendingImagesCount = 0;
  final ImageRepo _repo = ImageRepo();
  final List<ValueNotifier<ImageFetchingState>> _imageStates = [];
  final int _numberOfItems;
  final SpinnerController spinnerController;

  List<ValueNotifier<ImageFetchingState>> get imageStates => List.from(_imageStates);

  ImageFetcher({
    required int numberOfItemsPerHalf,
    required this.spinnerController,
  }) : _numberOfItems = 2 * numberOfItemsPerHalf {
    for (int i = 0; i < _numberOfItems; i++) {
      _imageStates.add(ValueNotifier(ImageFetchingProgressState()));
    }
  }

  void fetchImage(int index) {
    _pendingImagesCount++;
    _imageStates[index].value = ImageFetchingProgressState();
    _repo.fetchImages(
      _pendingImagesCount,
      onImageFetchSuccess: (List<String> images) {
        _pendingImagesCount = 0;
        _processFetchedImages(images);
      },
    );
  }

  void _processFetchedImages(List<String> images) {
    List<int> visibleElementIndexes = spinnerController.visibleElementIndexes;
    int minLength = min(images.length, visibleElementIndexes.length);
    for (int i = 0; i < minLength; i++) {
      int currentVisibleIndex = visibleElementIndexes[i];
      String image = images[i];
      var currentNotifier = _imageStates[currentVisibleIndex];
      currentNotifier.value = ImageFetchingSuccessState(image);
    }
  }
}

import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';

abstract class ImageRepo {

  Future<List<String>> fetchImages(int count);

  void cancelFetchingImages();
}

abstract class ImageFetchingState {}

class ImageFetchingProgressState extends ImageFetchingState {}

class ImageFetchingSuccessState extends ImageFetchingState {
  final String imageUrl;

  ImageFetchingSuccessState(this.imageUrl);
}

part of 'spinner.dart';

class SpinnerController {
  late SpinnerBloc _bloc;

  void bringElementAtIndexToCenter(int index) {
    _bloc.bringElementAtIndexToCenter(index);
  }
}

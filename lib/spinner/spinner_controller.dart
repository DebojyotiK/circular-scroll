part of 'spinner.dart';

class SpinnerController {
  final int elementsPerHalf;

  late SpinnerBloc _bloc;

  SpinnerController(this.elementsPerHalf);

  void bringElementAtIndexToCenter(
    int index, {
    int turns = 0,
  }) {
    _bloc.bringElementAtIndexToCenter(
      index,
      turns: turns,
    );
  }

  List<int> get visibleElementIndexes => _bloc.visibleElementIndexes;

  int get centerItemIndex => _bloc.centerItemIndex;

  int itemIndexAtRightFromCenter(int offset) => (_bloc.centerItemIndex - offset) % (elementsPerHalf * 2);

  int itemIndexAtLeftFromCenter(int offset) => (_bloc.centerItemIndex + offset) % (elementsPerHalf * 2);
}

import 'package:flutter/material.dart';

import 'image_fetching_state.dart';

class ImageView extends StatefulWidget {
  final int index;
  final bool showIndex;
  final ValueNotifier<ImageFetchingState> state;

  const ImageView({
    Key? key,
    required this.index,
    this.showIndex = false,
    required this.state,
  }) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_refreshView);
  }

  @override
  void dispose() {
    super.dispose();
    widget.state.removeListener(_refreshView);
  }

  void _refreshView() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isImageFetched = (widget.state.value is ImageFetchingSuccessState);
    return Container(
      color: const Color(0xffe5e5e5),
      child: AnimatedOpacity(
        opacity: isImageFetched ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: isImageFetched ? _imageView() : Container(),
      ),
    );
  }

  Widget _imageView() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Image.asset(
            (widget.state.value as ImageFetchingSuccessState).imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        if (widget.showIndex)
          Positioned(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "${widget.index}",
                style: TextStyle(
                  fontSize: 24,
                  inherit: false,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = Colors.black,
                ),
              ),
            ),
          ),
        if (widget.showIndex)
          Positioned(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "${widget.index}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  inherit: false,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
      ],
    );
  }
}

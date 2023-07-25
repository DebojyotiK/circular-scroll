import 'package:flutter/material.dart';
import 'package:spinner/image_view.dart';
import 'package:spinner/spinner.dart';

import 'image_fetcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(body: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int elementsPerHalf = 7;
  late double _theta;

  late double outerRadius;

  bool isInitialized = false;

  late SpinnerController _spinnerController;
  late TextEditingController _textEditingController;
  late ImageFetcher _imageFetcher;
  GlobalKey<_HomePageState> _homePageKey = GlobalKey<_HomePageState>();

  @override
  void initState() {
    super.initState();
    _theta = 180 / elementsPerHalf;
    _spinnerController = SpinnerController();
    _textEditingController = TextEditingController();
    _imageFetcher = ImageFetcher(
      numberOfItemsPerHalf: elementsPerHalf,
      spinnerController: _spinnerController,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      double width = MediaQuery.of(context).size.width;
      outerRadius = width * 0.8 / 2;
      isInitialized = true;
    }
    return _spinner(outerRadius);
  }

  Container _spinner(double radius) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spinner(
            radius: radius,
            innerRadius: 0.5 * radius,
            elementsPerHalf: elementsPerHalf,
            showDebugViews: false,
            elementBuilder: (index) {
              return ImageView(
                index: index,
                state: _imageFetcher.imageStates[index],
              );
            },
            onEnteredViewPort: (indexes) {
              debugPrint("$indexes entered view port");
              for (var index in indexes) {
                _imageFetcher.fetchImage(index);
              }
            },
            onLeftViewPort: (indexes) {
              debugPrint("$indexes left view port");
              for (var index in indexes) {
                _imageFetcher.cancelFetchingImage(index);
              }
            },
            onElementTapped: (index) {
              debugPrint("$index was tapped");
            },
            onElementCameToCenter: (index) {
              debugPrint("$index came to center");
            },
            spinnerController: _spinnerController,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              child: TextField(
                controller: _textEditingController,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              int indexToScroll = int.parse(_textEditingController.text);
              _spinnerController.bringElementAtIndexToCenter(indexToScroll);
            },
            child: const Text(
              "Rotate to index",
              style: TextStyle(
                inherit: false,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: _rotateVigorously,
            child: const Text(
              "Rotate Vigorously",
              style: TextStyle(
                inherit: false,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _imageFetcher.totalResultsFetchedTillDateNotifier,
            builder: (context, value, child) {
              return Text(
                "Fetched till date: $value",
                style: const TextStyle(
                  inherit: false,
                  color: Colors.black,
                  fontSize: 16,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _rotateVigorously() async {
    _spinnerController.bringElementAtIndexToCenter(0);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(1);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(3);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(5);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(6);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(7);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(8);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(3);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(13);
    await _pauseInteraction();
    _spinnerController.bringElementAtIndexToCenter(2);
  }

  Future<void> _pauseInteraction() async {
    await Future.delayed(const Duration(seconds: 1), () {});
  }
}

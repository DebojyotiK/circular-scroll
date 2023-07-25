import 'package:flutter/material.dart';
import 'package:spinner/spinner.dart';

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
  double theta = 360 / 14;

  late double outerRadius;

  bool isInitialized = false;

  late SpinnerController _spinnerController;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _spinnerController = SpinnerController();
    _textEditingController = TextEditingController();
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
            elementsPerHalf: 7,
            showDebugViews: false,
            elementBuilder: (index) {
              return _view(index);
            },
            onEnteredViewPort: (index) {
              debugPrint("$index entered view port");
            },
            onLeftViewPort: (index) {
              debugPrint("$index left view port");
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
            padding: EdgeInsets.symmetric(horizontal: 12),
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
              )),
          TextButton(
              onPressed: _rotateVigorously,
              child: const Text(
                "Rotate Vigorously",
                style: TextStyle(
                  inherit: false,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ))
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

  Widget _view(int index) {
    return Container(
        color: Colors.blue,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                "assets/$index.jpeg",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              child: Container(
                alignment: Alignment.center,
                child: Container(
                  child: Text(
                    "$index",
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
            ),
            Positioned(
              child: Container(
                alignment: Alignment.center,
                child: Container(
                  child: Text(
                    "$index",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      inherit: false,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

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
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  double theta = 360 / 14;
  late double outerRadius;
  bool isInitialized = false;

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
      child: Spinner(
        radius: radius,
        innerRadius: 0.5 * radius,
        elementsPerHalf: 7,
        showDebugViews: false,
        elementBuilder: (index) {
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
                      child: Text(
                        "$index",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          inherit: false,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ));
        },
      ),
    );
  }
}

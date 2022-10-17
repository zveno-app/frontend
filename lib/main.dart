import 'package:flutter/material.dart';
import 'package:zveno_frontend/api.dart';
import 'package:zveno_frontend/draw.dart';
import 'package:zveno_frontend/draw3.dart';
import 'dart:math';

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
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'zveno'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _currentSliderValue = 0.5;
  double _currentComplexity = 0.5;
  Color _currentColor = Colors.indigo;

  final _answer_controller = TextEditingController();

  late Future<Block> futureScheme;

  @override
  void dispose() {
    _answer_controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    
    futureScheme = Api.createAndGet(_counter.toString(), _currentComplexity);
  }
  
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      _currentComplexity = _currentSliderValue;
      _currentColor = Colors.indigo;
      futureScheme = Api.createAndGet(_counter.toString(), _currentComplexity);
    });
  }

  void _setSlider(double newV) {
    setState(() {
      _currentSliderValue = newV;
    });
  }

  void _rerender() {
    setState(() {});
  }

  void _checkAnswer(String s) {
    print(s);
    _currentColor = Colors.indigo;
    Api.checkAnswer(_counter.toString(), s).then((value) {
      print(value);
      setState(() {_currentColor = value ? Colors.green : Colors.red;});
      return value;
    });

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
        backgroundColor: _currentColor,
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: Column(
          children: [
            Expanded(child: FutureBuilder<Block>(
              future: futureScheme,
              builder: (ctx, snap) {
                if (snap.hasData) {
                  return InteractiveViewer(
                      minScale: 0.0001,
                      maxScale: 10.0,
                      // clipBehavior: lip.none,
                      child: CustomPaint(
                          willChange: false,
                          isComplex: true,
                          painter: BlockPainter(snap.data!),
                          child: Container()));
                } else if (snap.hasError) {
                  return Text('Ошибка получения схемы с $API_ENDPOINT: ${snap.error.toString()}');
                } else {
                  return const CircularProgressIndicator();
                }
            })),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(flex: 10, child: Slider(
                    value: _currentSliderValue,
                    onChanged: _setSlider,
                    min: 0.0,
                    max: 1.0,
                    label: _currentSliderValue.toStringAsFixed(2),
                  )),
                  Spacer(flex: 1),
                  OutlinedButton(
                    onPressed: _incrementCounter,
                    child: const Text('Сгенерировать ещё')
                  )
                ]
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(flex: 10, child: TextField(
                  onSubmitted: _checkAnswer,
                  decoration: const InputDecoration(
                      hintText: "Введите ответ", border: OutlineInputBorder()),
                  controller: _answer_controller
                )),
                Spacer(flex: 1),
                OutlinedButton(
                  onPressed: () {return _checkAnswer(_answer_controller.text);},
                  child: const Text('Проверить ответ')
                )
              ])
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
        // onPressed: _incrementCounter,
        // tooltip: 'Rerender',
        // child: const Icon(Icons.refresh),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

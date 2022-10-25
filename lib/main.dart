import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
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
  double _currentSliderValue = 50;
  double _currentComplexity = 0.5;
  Color _currentColor = Colors.indigo;

  final answerController = TextEditingController();
  final _blockIDContoller = TextEditingController();
  String? _currentCircuitId;

  late Future<Block> futureScheme;

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    
    futureScheme = _createAndGetCircuit(_currentComplexity);
  }

  Future<Block> _createAndGetCircuit(double complexity) async {
    String circuitID = await Api.createBlock(complexity);
    setState(() {_currentCircuitId = circuitID;});
    _blockIDContoller.text = _currentCircuitId!;
    return await Api.getBlock(_currentCircuitId!);
  }
  
  void _generateCircuit(bool fromId) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _currentComplexity = _currentSliderValue;
      _currentColor = Colors.indigo;
      futureScheme = fromId ? _getCircuitByID() : _createAndGetCircuit(_currentComplexity);
    });
  }

  Future<Block> _getCircuitByID() async {
    setState(() {_currentCircuitId = _blockIDContoller.text;});
    var res = await Api.getBlock(_currentCircuitId!);
    setState(() {});
    return res;
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
    setState(() => _currentColor = Colors.indigo);
    Api.checkAnswer(_currentCircuitId!, s).then((value) {
      setState(() {_currentColor = value ? Colors.green : Colors.red;});
      return value;
    });

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _generateCircuit method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} #$_currentCircuitId'),
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
                  return const Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
                }
            })),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Сложность"),
                  Spacer(flex: 1),
                  Flexible(flex: 30, child: SliderTheme(
                    child: Slider(
                      value: _currentSliderValue,
                      onChanged: _setSlider,
                      min: 1,
                      max: 100,
                      label: _currentSliderValue.round().toString(),  
                    ),
                    data: SliderThemeData(
                      showValueIndicator: ShowValueIndicator.always,
                    )
                  )),
//                  Flexible(flex: 3, child: TextField(
//                    decoration: const InputDecoration(
//                      hintText: "ID схемы с такой сложностью",
//                      border: OutlineInputBorder()
//                    ),
//                    controller: _blockIDContoller
//                  )),
                  Spacer(flex: 1),
                  OutlinedButton(
                    onPressed: () => _generateCircuit(false),
                    child: const Text('Сгенерировать ещё')
                  )
                ]
              )
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(flex: 10, child: TextField(
                  onSubmitted: (s) => _generateCircuit(true),
                  decoration: const InputDecoration(
                    hintText: "#ID схемы", border: OutlineInputBorder()
                  ),
                  controller: _blockIDContoller
                )),
                Spacer(flex: 1),
                OutlinedButton(
                  onPressed: () => _generateCircuit(true),
                  child: const Text('Загрузить схему с данным ID')
                )
              ])
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(flex: 10, child: TextField(
                  onSubmitted: _checkAnswer,
                  decoration: const InputDecoration(
                      hintText: "Введите ответ", border: OutlineInputBorder()),
                  controller: answerController
                )),
                Spacer(flex: 1),
                OutlinedButton(
                  onPressed: () {return _checkAnswer(answerController.text);},
                  child: const Text('Проверить ответ')
                )
              ])
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
        // onPressed: _generateCircuit,
        // tooltip: 'Rerender',
        // child: const Icon(Icons.refresh),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

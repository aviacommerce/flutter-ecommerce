import 'package:flutter/material.dart';
import 'package:aviastore/scoped-models/main.dart';
import 'package:aviastore/screens/home.dart';
import 'package:aviastore/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final MainModel _model = MainModel();
  // This widget is the root of your application.

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  static Map<int, Color> color = {
    50: Color.fromRGBO(33, 46, 64, .1),
    100: Color.fromRGBO(33, 46, 64, .2),
    200: Color.fromRGBO(33, 46, 64, .3),
    300: Color.fromRGBO(33, 46, 64, .4),
    400: Color.fromRGBO(33, 46, 64, .5),
    500: Color.fromRGBO(33, 46, 64, .6),
    600: Color.fromRGBO(33, 46, 64, .7),
    700: Color.fromRGBO(33, 46, 64, .8),
    800: Color.fromRGBO(33, 46, 64, .9),
    900: Color.fromRGBO(33, 46, 64, 1),
  };
  MaterialColor colorCustom = MaterialColor(0xFF212E40, color);

  @override
  void initState() {
    _model.loggedInUser();
    _model.fetchCurrentOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        initialRoute: '/home',
        routes: {'/home': (context) => HomeScreen()},
        theme: ThemeData(
          primarySwatch: colorCustom,
          accentColor: Colors.white,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/screens/home.dart';
import 'package:ofypets_mobile_app/scoped-models/cart.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final CartModel _model = CartModel();

  @override
  void initState() {
    _model.fetchCurrentOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<CartModel>(
      model: _model,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.white,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

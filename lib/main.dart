import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/screens/home.dart';
import 'package:ofypets_mobile_app/scoped-models/cart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<CartModel>(
      model: CartModel(),
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

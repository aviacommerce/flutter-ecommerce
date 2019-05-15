import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/screens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.white,
      ),
      home: HomeScreen(),
    );
  }
}

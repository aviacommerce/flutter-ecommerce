import 'package:flutter/material.dart';

class SuccessPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SuccessPageState();
  }
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Success Page')),
    );
  }
}

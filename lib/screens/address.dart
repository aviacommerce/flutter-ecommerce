import 'package:flutter/material.dart';

class AddressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddressPageState();
  }
}

class _AddressPageState extends State<AddressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Address or Add New'),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          
        ],)
      ),
    );
  }
}

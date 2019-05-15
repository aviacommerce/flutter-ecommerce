import 'package:flutter/material.dart';

class Authentication extends StatefulWidget {
  final int index;
  Authentication(this.index);
  @override
  State<StatefulWidget> createState() {
    return _AuthenticationState();
  }
}

class _AuthenticationState extends State<Authentication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      )),
    );
  }
}

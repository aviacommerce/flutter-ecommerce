import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';

class ReturnPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Return Policy'),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            _headingText(returnPolicyHeading1),
            _normalText(retunPolicyText1),
            _headingText(returnPolicyHeading2),
            _normalText(returnPolicyText2),
            _headingText(returnPolicyHeading3),
            _normalText(returnPolicyText3),
            _headingText(returnPolicyHeading4),
            _normalText(returnPolicyText4),
            _headingText(returnPolicyHeading4),
            _normalText(returnPolicyText5),
            _headingText(returnPolicyHeading6),
            _normalText(returnPolicyText6),
            _headingText(returnPolicyHeading7),
            _normalText(returnPolicyText7),
            _headingText(returnPolicyHeading8),
            _normalText(returnPolicyText8),
            _headingText(returnPolicyHeading9),
            _normalText(returnPolicyText9),
          ],
        ),
      ),
    );
  }
}

Widget _normalText(String text) {
  return Text(text);
}

Widget _headingText(String text) {
  return Text(
    text,
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
  );
}

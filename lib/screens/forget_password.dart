import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';

class ForgetPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgetPasswordState();
  }
}

class _ForgetPasswordState extends State<ForgetPassword>
    with SingleTickerProviderStateMixin {
  final Map<String, dynamic> _formData = {'email': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoader = false;
  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _deviceSize = MediaQuery.of(context).size;
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: Colors.green,
            leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            title: Text(
              'Forgot Password',
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                width: targetWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        'Please enter the email address used to create your account.',
                        style: TextStyle(fontSize: 16.0, color: Colors.black87, fontWeight: FontWeight.w100, ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.grey.shade500),
                            contentPadding: EdgeInsets.all(0.0)),
                        keyboardType: TextInputType.emailAddress,
                        validator: (String value) {
                          if (value.isEmpty ||
                              !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                  .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          _formData['email'] = value;
                        },
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      _isLoader
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.white)
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              child: RaisedButton(
                                textColor: Colors.white,
                                color: Colors.deepOrange,
                                child: Text('RESET PASSWORD'),
                                onPressed: () => _submitFogetPassword(),
                              ),
                            ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitFogetPassword() async {
    setState(() {
      _isLoader = true;
    });
    if (!_formKey.currentState.validate()) {
      setState(() {
        _isLoader = false;
      });
      return;
    }
    _formKey.currentState.save();
    final Map<String, dynamic> authData = {
      "spree_user": {
        'email': _formData['email'],
      }
    };

    final http.Response response = await http.post(
      Settings.SERVER_URL + 'auth/passwords',
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    String message = 'Something went wrong.';
    bool hasError = true;

    if (responseData.containsKey('id')) {
      message = 'Password reset successfully. Please check register mail.';
      hasError = false;
    } else if (responseData.containsKey('error')) {
      message = "Email does not exist.";
    }

    final Map<String, dynamic> successInformation = {
      'success': !hasError,
      'message': message
    };
    if (successInformation['success']) {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return _alertDialog(
                'Success!', successInformation['message'], context);
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return _alertDialog(
                'An Error Occurred!', successInformation['message'], context);
          });
    }
    setState(() {
      _isLoader = false;
    });
  }

  Widget _alertDialog(String boxTitle, String message, BuildContext context) {
    return AlertDialog(
      title: Text(boxTitle),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text('Okay',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green.shade300)),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}

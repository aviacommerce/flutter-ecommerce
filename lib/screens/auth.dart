import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/forget_password.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication extends StatefulWidget {
  final int index;
  Authentication(this.index);
  @override
  State<StatefulWidget> createState() {
    return _AuthenticationState();
  }
}

class _AuthenticationState extends State<Authentication>
    with SingleTickerProviderStateMixin {
  final Map<String, dynamic> _formData = {'email': null, 'password': null};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyForLogin = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _isLoader = false;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: widget.index, vsync: this, length: 2);
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
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.green,
              tabs: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "SIGN IN",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
            title: Text(
              'ofypets',
              style: TextStyle(fontFamily: 'HolyFat', fontSize: 50),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _renderLogin(targetWidth),
              _renderSignup(targetWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderLogin(double targetWidth) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SingleChildScrollView(
        child: Container(
          width: targetWidth,
          child: Form(
            key: _formKeyForLogin,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                _buildEmailTextField(),
                SizedBox(
                  height: 20.0,
                ),
                _buildPasswordTextField(),
                SizedBox(
                  height: 20.0,
                ),
                _isLoader
                    ? CircularProgressIndicator(backgroundColor: Colors.green)
                    : Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(15),
                      child: FlatButton(
                        textColor: Colors.white,
                        color: Colors.deepOrange,
                        child: Text('SIGN IN'),
                        onPressed: () => _submitForm(),
                      )),
                SizedBox(
                  height: 20.0,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ForgetPassword();
                    }));
                  },
                  child: Text(
                    'FORGOT YOUR PASSWORD?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _renderSignup(double targetWidth) {
    return SingleChildScrollView(
      child: Container(
        width: targetWidth,
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              _buildEmailTextField(),
              SizedBox(
                height: 20.0,
              ),
              _buildPasswordTextField(),
              SizedBox(
                height: 20.0,
              ),
              _buildPasswordConfirmTextField(),
              SizedBox(
                height: 20.0,
              ),
              _isLoader
                  ? CircularProgressIndicator(backgroundColor: Colors.green)
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(15),
                      child: FlatButton(
                        textColor: Colors.white,
                        color: Colors.deepOrange,
                        child: Text('CREATE ACCOUNT'),
                        onPressed: () => _submitForm(),
                      )),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    ));
  }

  Widget _buildPasswordTextField() {
    return Padding( 
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
      decoration: InputDecoration(
          labelText: 'Password (Atleast 6 Characters)',
          filled: true,
          fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password must be atleast 6 characters';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    ));
  }

  Widget _buildPasswordConfirmTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Passwords do not match.';
        }
      },
    ));
  }

  void _submitLogin(MainModel model) async {
    setState(() {
      _isLoader = true;
    });
    if (!_formKeyForLogin.currentState.validate()) {
      setState(() {
        _isLoader = false;
      });
      return;
    }
    _formKeyForLogin.currentState.save();
    final Map<String, dynamic> authData = {
      "spree_user": {
        'email': _formData['email'],
        'password': _formData['password'],
      }
    };

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final http.Response response = await http.post(
      Settings.SERVER_URL + 'login.json',
      body: json.encode(authData),
      headers: {
        'Content-Type': 'application/json',
        'guest-order-token': prefs.getString('orderToken')
      },
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    String message = 'Something went wrong.';
    bool hasError = true;
    if (responseData.containsKey('id')) {
      message = 'Login successfuly.';
      hasError = false;
    } else if (responseData.containsKey('error')) {
      message = responseData["error"];
    }

    final Map<String, dynamic> successInformation = {
      'success': !hasError,
      'message': message
    };
    if (successInformation['success']) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      print("SPREE API KEY ${responseData['spree_api_key']}");
      prefs.setInt('id', responseData['id']);
      prefs.setString('email', responseData['email']);
      prefs.setString('spreeApiKey', responseData['spree_api_key']);
      model.getAddress();
      model.fetchCurrentOrder();
      model.loggedInUser();
      Navigator.of(context).pop();
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

  void _submitForm() async {
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
        'password': _formData['password'],
      }
    };

    final http.Response response = await http.post(
      Settings.SERVER_URL + 'auth/accounts',
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    String message = 'Something went wrong.';
    bool hasError = true;

    if (responseData.containsKey('id')) {
      print('success');
      message = 'Register successfuly.';
      hasError = false;
    } else if (responseData.containsKey('errors')) {
      message = "Email " + responseData["errors"]["email"][0];
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
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

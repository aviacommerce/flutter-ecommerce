import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _passwordTextController = TextEditingController();
  final UnderlineInputBorder _underlineInputBorder =
      UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54));

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
      color: Colors.green,
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.white,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: TabBar(
              indicatorWeight: 4.0,
              controller: _tabController,
              indicatorColor: Colors.green,
              tabs: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "SIGN IN",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(fontSize: 13),
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
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Container(
            width: targetWidth,
            child: Form(
              key: _formKeyForLogin,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                  ),
                  _buildEmailTextField(),
                  SizedBox(
                    height: 45.0,
                  ),
                  _buildPasswordTextField(false),
                  SizedBox(
                    height: 35.0,
                  ),
                  _isLoader
                      ? CircularProgressIndicator(backgroundColor: Colors.green)
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(15),
                          child: FlatButton(
                            textColor: Colors.white,
                            color: Colors.deepOrange,
                            child: Text(
                              'SIGN IN',
                              style: TextStyle(fontSize: 12.0),
                            ),
                            onPressed: () => _submitLogin(model),
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
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                          fontSize: 14.0),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _renderSignup(double targetWidth) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
          width: targetWidth,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                _buildEmailTextField(),
                SizedBox(
                  height: 45.0,
                ),
                _buildPasswordTextField(true),
                SizedBox(
                  height: 45.0,
                ),
                _buildPasswordConfirmTextField(),
                SizedBox(
                  height: 45.0,
                ),
                _isLoader
                    ? CircularProgressIndicator(backgroundColor: Colors.green)
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(15),
                        child: FlatButton(
                          textColor: Colors.white,
                          color: Colors.deepOrange,
                          child: Text('CREATE ACCOUNT',
                              style: TextStyle(fontSize: 12.0)),
                          onPressed: () => _submitForm(),
                        )),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
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
              labelStyle: TextStyle(color: Colors.grey),
              labelText: 'Email',
              contentPadding: EdgeInsets.all(0.0),
              enabledBorder: _underlineInputBorder),
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
        ));
  }

  Widget _buildPasswordTextField([bool isLimitCharacter = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: isLimitCharacter
                ? 'Password (Atleast 6 Characters)'
                : 'Password',
            labelStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.all(0.0),
            enabledBorder: _underlineInputBorder),
        obscureText: true,
        controller: _passwordTextController,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return 'Password must be atleast 6 characters';
          }
          return null;
        },
        onSaved: (String value) {
          _formData['password'] = value;
        },
      ),
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Theme(
          data: ThemeData(hintColor: Colors.grey.shade700),
          child: TextFormField(
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              labelText: 'Confirm Password',
              enabledBorder: _underlineInputBorder,
              contentPadding: EdgeInsets.all(0.0),
            ),
            obscureText: true,
            validator: (String value) {
              if (_passwordTextController.text != value) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
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
      prefs.setInt('id', responseData['id']);
      prefs.setString('email', responseData['email']);
      prefs.setString('spreeApiKey', responseData['spree_api_key']);
      prefs.setString('createdAt', responseData['created_at']);
      model.getAddress();
      model.fetchCurrentOrder();
      model.loggedInUser();
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('${successInformation['message']}'),
        duration: Duration(seconds: 1),
      ));
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
            return _alertDialog('Success!',
                "Account Created Successfully! Sign in to Continue", context);
          });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('${successInformation['message']}'),
        duration: Duration(seconds: 1),
      ));
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('${successInformation['message']}'),
        duration: Duration(seconds: 1),
      ));
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
          child: Text('Later',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green.shade300)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text('Sign In',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green.shade300)),
          onPressed: () {
            Navigator.pop(context);
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Authentication(0));
            Navigator.push(context, route);
          },
        )
      ],
    );
  }
}

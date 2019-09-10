import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';

class EmailEdit extends StatefulWidget {
  @override
  _EmailEditState createState() => _EmailEditState();
}

class _EmailEditState extends State<EmailEdit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = 'sagar@gmail.com';
  final TextEditingController _textFieldController = TextEditingController();
  bool _fetchingEmail = true;
  bool _savingEmail = false;

  @override
  void initState() {
    get_user();
    super.initState();
  }

  get_user() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getInt('id').toString();
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> userResponse;
    String url = Settings.SERVER_URL + "api/v1/users/${userId}";
    http.Response response = await http.get(url, headers: headers);

    userResponse = json.decode(response.body);

    this.setState(() {
      _email = userResponse['email'];
      _fetchingEmail = false;
    });
    _textFieldController.text = _email;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Email"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                saveEmail(context, model);
              },
            )
          ],
        ),
        body: ScopedModelDescendant(
            builder: (BuildContext context, Widget child, MainModel model) {
          if (_fetchingEmail) {
            return LinearProgressIndicator();
          } else {
            return Container(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(20),
                  children: <Widget>[
                    buildEmailField(),
                    SizedBox(
                      height: 50,
                    ),
                    submitButton()
                  ],
                ),
              ),
            );
          }
        }),
      );
    });
  }

  Widget buildEmailField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter valid email address';
        }
      },
      controller: _textFieldController,
      decoration: InputDecoration(
        labelText: "Email",
      ),
      onSaved: (String value) {
        setState(() {
          _email = value;
        });
      },
    );
  }

  Widget submitButton() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return FlatButton(
          color: Colors.deepOrange,
          disabledColor: Colors.grey,
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text(
            'SAVE',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _savingEmail
              ? null
              : () async {
                  saveEmail(context, model);
                });
    });
  }

  saveEmail(context, model) async {
    setState(() {
      _savingEmail = true;
    });
    Map<dynamic, dynamic> updateResponse;
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_id = prefs.getInt('id').toString();
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> payload = Map();
    payload = {'email': _email, 'user_id': user_id};
    String url = Settings.SERVER_URL + "api/v1/users/${user_id}";
    http.Response response =
        await http.put(url, headers: headers, body: json.encode(payload));

    updateResponse = json.decode(response.body);
    setState(() {
      _savingEmail = false;
    });
    if (response.statusCode == 200) {
      logoutUser(context, model);
    } else {
      String error = updateResponse['errors']['email'][0];
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Email ${error}'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  logoutUser(BuildContext context, MainModel model) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = await getHeaders();
    http
        .get(Settings.SERVER_URL + 'logout.json', headers: headers)
        .then((response) {
      prefs.clear();
      model.loggedInUser();
      model.fetchCurrentOrder();
    });
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }
}

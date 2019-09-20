import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/change_email.dart';
import 'package:ofypets_mobile_app/screens/change_password.dart';
import 'package:ofypets_mobile_app/screens/my_address.dart';
import 'package:ofypets_mobile_app/screens/order_history.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/models/address.dart';
import 'package:ofypets_mobile_app/utils/drawer_homescreen.dart';
import 'package:ofypets_mobile_app/screens/retun_policy.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Account extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountState();
  }
}

class _AccountState extends State<Account> {
  var formatter = new DateFormat('MMM dd, yyyy');
  String createdAtString = '';
  TextStyle _textStyle = TextStyle(fontWeight: FontWeight.w500);
  @override
  void initState() {
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
      ),
      body: Container(
        child: accountOptions(),
      ),
      drawer: HomeDrawer(),
    );
  }

  getDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String createdAt = prefs.getString('createdAt');
    setState(() {
      createdAtString = formatter.format(DateTime.parse(createdAt));
    });
  }

  Widget accountOptions() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListView(
        children: <Widget>[
          Container(
            color: Colors.grey.shade100,
            child: ListTile(
              title: Text(
                "Customer since $createdAtString",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {},
            ),
          ),
          ListTile(
            title: Text(
              "Order History",
              style: _textStyle,
            ),
            onTap: () {
              navigate_option("order_history", context, model);
            },
          ),
          ListTile(
            title: Text(
              "Addresses",
              style: _textStyle,
            ),
            onTap: () {
              navigate_option("change_address", context, model);
            },
          ),
          ListTile(
            title: Text(
              "Change Email",
              style: _textStyle,
            ),
            onTap: () {
              navigate_option("email_edit", context, model);
            },
          ),
          ListTile(
            title: Text(
              "Change Password",
              style: _textStyle,
            ),
            onTap: () {
              navigate_option("change_password", context, model);
            },
          ),
          Container(
            color: Colors.grey.shade100,
            child: ListTile(
              title: Text(
                "24/7 Help & Info",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {},
            ),
          ),
          InkWell(
            onTap: () {
              _callMe('917-6031-568');
            },
            child: ListTile(
              title: Text(
                'Call: 917-6031-568',
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _sendMail('support@ofypets.com');
            },
            child: ListTile(
              title: Text(
                'Email: support@ofypets.com',
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ReturnPolicy();
              }));
            },
            child: ListTile(
              title: Text(
                'Return Policy',
              ),
            ),
          ),
          logOutButton(),
        ],
      );
    });
  }

  Widget logOutButton() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (model.isAuthenticated) {
          return ListTile(
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () {
              _showDialog(context, model);
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  void _showDialog(context, model) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sign Out"),
            content: new Text("Are you sure you want to sign out?"),
            actions: <Widget>[
              new FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  logoutUser(context, model);
                },
              )
            ],
          );
        });
  }

  logoutUser(BuildContext context, MainModel model) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_id = prefs.getInt('id').toString();
    String api_key = prefs.getString('spreeApiKey');
    Map<String, String> headers = await getHeaders();
    http
        .get(Settings.SERVER_URL + 'logout.json', headers: headers)
        .then((response) {
      prefs.clear();
      model.clearData();
      model.loggedInUser();
      model.fetchCurrentOrder();
    });
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  void navigate_option(String screen, BuildContext context, MainModel model) {
    switch (screen) {
      case "order_history":
        {
          MaterialPageRoute orderList =
              MaterialPageRoute(builder: (context) => OrderList());
          Navigator.push(context, orderList);
        }
        break;
      case "email_edit":
        {
          MaterialPageRoute orderList =
              MaterialPageRoute(builder: (context) => EmailEdit());
          Navigator.push(context, orderList);
        }
        break;
      case "change_password":
        {
          MaterialPageRoute orderList =
              MaterialPageRoute(builder: (context) => ChangePassword());
          Navigator.push(context, orderList);
        }
        break;
      case "change_address":
        {
          MaterialPageRoute orderList =
              MaterialPageRoute(builder: (context) => MyAddressPage());
          Navigator.push(context, orderList);
        }
    }
  }

  _sendMail(String email) async {
    // Android and iOS
    final uri = 'mailto:$email?subject=&body=';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  _callMe(String phone) async {
    final uri = 'tel:$phone';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}

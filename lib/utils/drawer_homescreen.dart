import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/auth.dart';

class HomeDrawer extends StatelessWidget {
  Widget logOutButton() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (model.isAuthenticated) {
          return ListTile(
            leading: Icon(
              Icons.reply,
              color: Colors.green,
            ),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              logoutUser(model);
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget signInLineTile() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (!model.isAuthenticated) {
          return Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  'Sign in',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => Authentication(0));

                  Navigator.push(context, route);
                },
              ),
              Text('|',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300)),
              GestureDetector(
                child: Text('Create Account',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300)),
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => Authentication(1));

                  Navigator.push(context, route);
                },
              )
            ],
          ));
        } else {
          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('Welcome Back!',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300))
              ],
            ),
          );
        }
      },
    );
  }

  logoutUser(MainModel model) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_id = prefs.getInt('id').toString();
    String api_key = prefs.getString('spreeApiKey');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'token-type': 'Bearer',
      'ng-api': 'true',
      'Auth-Token': api_key,
      'uid': user_id
    };
    http
        .get(Settings.SERVER_URL + 'logout.json', headers: headers)
        .then((response) {
      prefs.clear();
      model.loggedInUser();
      model.fetchCurrentOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'ofypets',
                style: TextStyle(
                    fontFamily: 'HolyFat', fontSize: 65, color: Colors.white),
              ),
              Text(
                '1.0.0',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              ),
              signInLineTile()
            ]),
            decoration: BoxDecoration(color: Colors.green),
          ),
          ListTile(
            onTap: () {
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            },
            leading: Icon(
              Icons.home,
              color: Colors.green,
            ),
            title: Text(
              'Home',
              style: TextStyle(color: Colors.green),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: Colors.green,
            ),
            title: Text(
              'Favorites',
              style: TextStyle(color: Colors.green),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.receipt,
              color: Colors.green,
            ),
            title: Text(
              'Buy Again',
              style: TextStyle(color: Colors.green),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.green,
            ),
            title: Text(
              'Account',
              style: TextStyle(color: Colors.green),
            ),
          ),
          logOutButton(),
          Divider(),
          ListTile(
            title: Text(
              '24/7 Help',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.call,
            ),
            title: Text(
              'Call: 1-111-111-1111',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.mail,
            ),
            title: Text(
              'Email: abc@ofypets.com',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.share,
            ),
            title: Text(
              'Share the App',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.alternate_email,
            ),
            title: Text(
              'App Feedback',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.assignment,
            ),
            title: Text(
              'Privacy Policy',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.assignment,
            ),
            title: Text(
              'Terms and Policies',
            ),
          ),
        ],
      ),
    );
  }
}

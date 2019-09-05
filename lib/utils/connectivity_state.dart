import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ConnectivityManager {
  StreamSubscription<ConnectivityResult> subscription;
  Connectivity connectivity = new Connectivity();
  ConnectivityState _connectivityState;
  bool isPageAdded = false;
  Flushbar flushBar;

  void initConnectivity(BuildContext context) {
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        if (_connectivityState != null &&
            _connectivityState != ConnectivityState.online)
          //showFlushBar(context, ConnectivityState.online);
          _connectivityState = ConnectivityState.online;
        if (isPageAdded) Navigator.of(context).pop();
        isPageAdded = false;
      } else {
        _connectivityState = ConnectivityState.offline;
        // showFlushBar(context, ConnectivityState.offline);
        //showInternetOffScreen(context);
        pushInternetOffScreen(context);
      }
    });
  }

  void pushInternetOffScreen(BuildContext context) {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return new ConnectivityPage();
        },
        fullscreenDialog: true));
    isPageAdded = true;
  }

  void showInternetOffScreen(BuildContext context) {
    Dialog errorDialog = Dialog(
      backgroundColor: Colors.green,
      //this right here
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.green,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'ofypets',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'HolyFat', fontSize: 50, color: Colors.white),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.signal_wifi_off,
                  color: Colors.grey,
                  size: 80.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'You are not connected to internet',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => errorDialog);
  }

  void dispose() {
    subscription.cancel();
  }
}

class ConnectivityPage extends StatefulWidget {
  @override
  _ConnectivityPageState createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeAll();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.green,
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'ofypets',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'HolyFat', fontSize: 50, color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.signal_wifi_off,
                    color: Colors.white,
                    size: 80.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'You are not connected to the internet.',
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

enum ConnectivityState { offline, online }

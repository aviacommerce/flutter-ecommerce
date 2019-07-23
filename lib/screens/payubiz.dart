import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/screens/order_response.dart';

class PayubizScreen extends StatefulWidget {
  String url;
  PayubizScreen(this.url);
  @override
  State<StatefulWidget> createState() {
    return _PayubizScreenState();
  }
}

class _PayubizScreenState extends State<PayubizScreen> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  @override
  void initState() {
    flutterWebviewPlugin.launch(widget.url);
    super.initState();
  }

  pushSuccessPage(bool success) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderNumber = prefs.getString('orderNumber');
    MaterialPageRoute payment = MaterialPageRoute(
        builder: (context) => OrderResponse(
              orderNumber: orderNumber,
              success: success,
            ));
    Navigator.pushAndRemoveUntil(
      context,
      payment,
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.split('?')[0] == Settings.WEB_URL + 'checkout/order-success') {
        pushSuccessPage(true);
      } else if (url.split('?')[0] ==
          Settings.WEB_URL + 'checkout/order-failed') {
        pushSuccessPage(false);
      }
    });

    return WillPopScope(
      onWillPop: () async => (false),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Payubiz',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          body: WebviewScaffold(
            url: widget.url,
            withJavascript: true,
            // hidden: true,
          )),
    );
  }
}

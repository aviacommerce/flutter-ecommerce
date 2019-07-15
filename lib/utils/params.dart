import 'dart:convert';

import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:http/http.dart' as http;

import 'dart:io';

getParams() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String surl = '${Settings.SERVER_URL}payment/handle_payubiz';
  String furl = '${Settings.SERVER_URL}payment/handle_payubiz';

  Map<String, String> headers = await getHeaders();

  Map<String, dynamic> params = {
    'params': {
      'surl': surl,
      'furl': furl,
      'order_number': prefs.getString('orderNumber')
    }
  };
  http.Response response = await http.post(
      Settings.SERVER_URL + 'payment/post_request_payubiz',
      body: json.encode(params),
      headers: headers);
  print("PAYUBIZ RESPONSE URL");
  //print(response);
  print(json.decode(response .body));
  
}

import 'package:shared_preferences/shared_preferences.dart';

import 'package:ofypets_mobile_app/utils/config.dart';

getParams(String paymentAmount, String firstName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Map<String, String> hashParams = {
    'key': DefaultConfig.PAYUBZ_KEY,
    'txnid': prefs.getString('orderNumber'),
    'amount': paymentAmount,
    'productinfo': DefaultConfig.APP_NAME + '-Product',
    'firstname': firstName,
    'email': prefs.getString('email'),
    'udf1': prefs.getString('orderNumber')
  };
  String paramsList = "${hashParams['key']}|${hashParams['txnid']}|";
  print(paramsList);
}

import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/models/address.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';

mixin UserModel on Model {
  bool _isAuthenticated = false;
  MainModel model;
  Address _shipAddress;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  Address get shipAddress {
    return _shipAddress;
  }

  void set shipAddress(addr) {
    _shipAddress = addr;
    notifyListeners();
  }

  loggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('spreeApiKey');
    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
    } else {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  getAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();
    http.Response response = await http.get(
        Settings.SERVER_URL + 'api/v1/users/${prefs.getInt('id')}',
        headers: headers);
    responseBody = json.decode(response.body);
    if (responseBody['ship_address'] != null) {
      _shipAddress = Address(
        id: responseBody['ship_address']['id'],
        firstName: responseBody['ship_address']['firstname'],
        lastName: responseBody['ship_address']['lastname'],
        stateName: responseBody['ship_address']['state']['name'],
        stateAbbr: responseBody['ship_address']['state']['abbr'],
        address2: responseBody['ship_address']['address2'],
        city: responseBody['ship_address']['city'],
        address1: responseBody['ship_address']['address1'],
        mobile: responseBody['ship_address']['phone'],
        pincode: responseBody['ship_address']['zipcode'],
        stateId: responseBody['ship_address']['state_id'],
      );
      notifyListeners();
    } else {
      _shipAddress = null;
    }
  }
}

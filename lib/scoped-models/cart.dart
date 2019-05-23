import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/models/line_item.dart';
import 'package:ofypets_mobile_app/models/variant.dart';

class CartModel extends Model {
  List<LineItem> _lineItems = [];

  Map<dynamic, dynamic> lineItemObject = Map();

  List<LineItem> get lineItems {
    return List.from(_lineItems);
  }

  void addProduct({int variantId, int quantity}) async {
    print('ADD TO CART');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String orderToken = prefs.getString('orderToken');

    if (orderToken != null) {
      print('ORDER TOKEN AVAILABLE');
      createNewLineItem(variantId, quantity);
    } else {
      print('ORDER TOKEN UNAVAILABLE, FETCH TOKEN ');
      createNewOrder(variantId, quantity);
    }
    notifyListeners();
  }

  void createNewOrder(int variantId, int quantity) async {
    Map<dynamic, dynamic> responseBody;
    Map<dynamic, dynamic> orderParams = Map();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    orderParams = {
      'order': {
        'line_items': {
          '0': {'variant_id': variantId, 'quantity': quantity}
        }
      }
    };
    http
        .post(Settings.SERVER_URL + 'api/v1/orders',
            body: json.encode(orderParams))
        .then((response) {
      responseBody = json.decode(response.body);
      prefs.setString('orderToken', responseBody['token']);
      prefs.setString('orderNumber', responseBody['number']);
    });
  }

  void createNewLineItem(int variantId, int quantity) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<dynamic, dynamic> responseBody;
    Variant variant;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    LineItem lineItem;

    lineItemObject = {
      "line_item": {"variant_id": variantId, "quantity": quantity}
    };
    http
        .post(
            Settings.SERVER_URL +
                'api/v1/orders/${prefs.getString('orderNumber')}/line_items?order_token=${prefs.getString('orderToken')}',
            headers: headers,
            body: json.encode(lineItemObject))
        .then((response) {
      responseBody = json.decode(response.body);
      print(responseBody);
      variant = Variant(
          image: responseBody['variant']['images'][0]['product_url'],
          displayPrice: responseBody['variant']['display_price'],
          name: responseBody['variant']['name'],
          quantity: responseBody['quantity']);
      lineItem = LineItem(
          id: responseBody['id'],
          displayAmount: responseBody['display_amount'],
          quantity: responseBody['quantity'],
          total: responseBody['total'],
          variant: variant,
          variantId: responseBody['variant_id']);
      _lineItems.add(lineItem);
      prefs.setString('numberOfItems', _lineItems.length.toString());
      notifyListeners();
    });
  }
}

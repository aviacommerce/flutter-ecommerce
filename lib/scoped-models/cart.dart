import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/models/order.dart';
import 'package:ofypets_mobile_app/models/line_item.dart';
import 'package:ofypets_mobile_app/models/variant.dart';

class CartModel extends Model {
  List<LineItem> _lineItems = [];
  Order order;
  bool _isLoading = false;

  Map<dynamic, dynamic> lineItemObject = Map();

  List<LineItem> get lineItems {
    return List.from(_lineItems);
  }

  bool get isLoading {
    return _isLoading;
  }

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'token-type': 'Bearer',
    'ng-api': 'true'
  };

  void addProduct({int variantId, int quantity}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _lineItems.clear();
    _isLoading = true;
    prefs.setString('numberOfItems', _lineItems.length.toString());
    notifyListeners();
    print('ADD TO CART');
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

  void removeProduct(int lineItemId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoading = true;
    _lineItems.clear();
    prefs.setString('numberOfItems', _lineItems.length.toString());
    notifyListeners();
    http
        .delete(Settings.SERVER_URL +
            'api/v1/orders/${prefs.getString('orderNumber')}/line_items/$lineItemId?order_token=${prefs.getString('orderToken')}')
        .then((response) {
      fetchCurrentOrder();
    });
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
            headers: headers, body: json.encode(orderParams))
        .then((response) {
      fetchCurrentOrder();

      responseBody = json.decode(response.body);
      prefs.setString('orderToken', responseBody['token']);
      prefs.setString('orderNumber', responseBody['number']);
    });
  }

  void createNewLineItem(int variantId, int quantity) async {
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
      fetchCurrentOrder();

      // responseBody = json.decode(response.body);
      // print(responseBody);
      // variant = Variant(
      //     image: responseBody['variant']['images'][0]['product_url'],
      //     displayPrice: responseBody['variant']['display_price'],
      //     name: responseBody['variant']['name'],
      //     quantity: responseBody['quantity']);
      // lineItem = LineItem(
      //     id: responseBody['id'],
      //     displayAmount: responseBody['display_amount'],
      //     quantity: responseBody['quantity'],
      //     total: responseBody['total'],
      //     variant: variant,
      //     variantId: responseBody['variant_id']);
    });
  }

  fetchCurrentOrder() async {
    Map<dynamic, dynamic> responseBody;
    LineItem lineItem;
    Variant variant;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String orderToken = prefs.getString('orderToken');

    if (orderToken != null) {
      http
          .get(Settings.SERVER_URL +
              'api/v1/orders/${prefs.getString('orderNumber')}?order_token=${prefs.getString('orderToken')}')
          .then((response) {
        responseBody = json.decode(response.body);
        responseBody['line_items'].forEach((lineItem) {
          variant = Variant(
              image: lineItem['variant']['images'][0]['product_url'],
              displayPrice: lineItem['variant']['display_price'],
              name: lineItem['variant']['name'],
              quantity: lineItem['quantity']);

          lineItem = LineItem(
              id: lineItem['id'],
              displayAmount: lineItem['display_amount'],
              quantity: lineItem['quantity'],
              total: lineItem['total'],
              variant: variant,
              variantId: lineItem['variant_id']);
          _lineItems.add(lineItem);
        });
        order = Order(
            id: responseBody['id'],
            itemTotal: responseBody['item_total'],
            displayTotal: responseBody['display_item_total'],
            lineItems: _lineItems);
        _isLoading = false;
        prefs.setString('numberOfItems', _lineItems.length.toString());
        notifyListeners();
      });
    }
  }
}

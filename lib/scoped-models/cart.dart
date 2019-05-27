import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/models/order.dart';
import 'package:ofypets_mobile_app/models/line_item.dart';
import 'package:ofypets_mobile_app/models/variant.dart';

mixin CartModel on Model {
  List<LineItem> _lineItems = [];
  Order order;
  bool _isLoading = false;
  Map<String, dynamic> _shipAddress;

  Map<dynamic, dynamic> lineItemObject = Map();

  List<LineItem> get lineItems {
    return List.from(_lineItems);
  }

  bool get isLoading {
    return _isLoading;
  }

  Map<String, dynamic> get shipAddress {
    return _shipAddress;
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

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
    });
  }

  fetchCurrentOrder() async {
    Map<dynamic, dynamic> responseBody;
    String url = '';
    Map<String, String> headers;
    LineItem lineItem;
    Variant variant;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String orderToken = prefs.getString('orderToken');
    final String spreeApiKey = prefs.getString('spreeApiKey');

    if (orderToken != null && spreeApiKey == null) {
      url =
          'api/v1/orders/${prefs.getString('orderNumber')}?order_token=${prefs.getString('orderToken')}';
      headers = {
        'Content-Type': 'application/json',
        'token-type': 'Bearer',
        'ng-api': 'true'
      };
    } else if (spreeApiKey != null) {
      url = 'api/v1/orders/current';
      headers = {
        'Content-Type': 'application/json',
        'token-type': 'Bearer',
        'ng-api': 'true',
        'auth-token': prefs.getString('spreeApiKey'),
        'Guest-Order-Token': prefs.getString('orderToken')
      };
    }

    print(url);
    print('FETCH CURRENT ORDER');

    if (url != '') {
      http.get(Settings.SERVER_URL + url, headers: headers).then((response) {
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
          notifyListeners();
        });
        order = Order(
            id: responseBody['id'],
            itemTotal: responseBody['item_total'],
            displayTotal: responseBody['display_item_total'],
            lineItems: _lineItems,
            shipTotal: responseBody['display_ship_total'],
            totalQuantity: responseBody['total_quantity'],
            state: responseBody['state']);
        _isLoading = false;
        print(responseBody['token']);
        prefs.setString('numberOfItems', _lineItems.length.toString());
        prefs.setString('orderToken', responseBody['token']);
        if (responseBody['ship_address'] != null) {
          _shipAddress = responseBody['ship_address'];
        }

        notifyListeners();
      });
    }
  }

  changeState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<dynamic, dynamic> responseBody;
    headers = {
      'Content-Type': 'application/json',
      'token-type': 'Bearer',
      'ng-api': 'true',
      'auth-token': prefs.getString('spreeApiKey'),
      'Guest-Order-Token': prefs.getString('orderToken')
    };

    http
        .put(
            Settings.SERVER_URL +
                'api/v1/checkouts/${prefs.getString('orderNumber')}/next.json?order_token=${prefs.getString('orderToken')}',
            headers: headers)
        .then((response) {
      order = Order(
          id: responseBody['id'],
          itemTotal: responseBody['item_total'],
          displayTotal: responseBody['display_item_total'],
          lineItems: _lineItems,
          shipTotal: responseBody['display_ship_total'],
          totalQuantity: responseBody['total_quantity'],
          state: responseBody['state']);
      prefs.setString('numberOfItems', _lineItems.length.toString());
      notifyListeners();
    });
  }

  completeOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    headers = {
      'Content-Type': 'application/json',
      'token-type': 'Bearer',
      'ng-api': 'true',
      'auth-token': prefs.getString('spreeApiKey'),
      'Guest-Order-Token': prefs.getString('orderToken')
    };
    Map<String, dynamic> paymentPayload = {
      'payment': {'payment_method_id': 3, 'amount': order.itemTotal}
    };
    http
        .post(
            Settings.SERVER_URL +
                'api/v1/orders/${prefs.getString('orderNumber')}/payments?order_token=${prefs.getString('orderToken')}',
            body: json.encode(paymentPayload),
            headers: headers)
        .then((response) {
      prefs.setString('numberOfItems', '0');
      prefs.setString('orderToken', null);
      prefs.setString('orderNumber', null);
    });
  }
}

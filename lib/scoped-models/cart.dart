import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/models/order.dart';
import 'package:ofypets_mobile_app/models/line_item.dart';
import 'package:ofypets_mobile_app/models/variant.dart';

mixin CartModel on Model {
  List<LineItem> _lineItems = [];
  Order order;
  bool _isLoading = false;

  Map<dynamic, dynamic> lineItemObject = Map();

  List<LineItem> get lineItems {
    return List.from(_lineItems);
  }

  set shipAddress(Map<String, dynamic> shipAddress) {
    print('SETTER');
    print(shipAddress);
    _shipAddress = shipAddress;
    notifyListeners();
  }

  bool get isLoading {
    return _isLoading;
  }

  void addProduct({int variantId, int quantity}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _lineItems.clear();
    _isLoading = true;
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
    notifyListeners();
    http
        .delete(Settings.SERVER_URL +
            'api/v1/orders/${prefs.getString('orderNumber')}/line_items/$lineItemId?order_token=${prefs.getString('orderToken')}')
        .then((response) {
      fetchCurrentOrder();
    });
  }

  void createNewOrder(int variantId, int quantity) async {
    Map<String, String> headers = await getHeaders();
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
      responseBody = json.decode(response.body);
      prefs.setString('orderToken', responseBody['token']);
      prefs.setString('orderNumber', responseBody['number']);
      fetchCurrentOrder();
    });
  }

  void createNewLineItem(int variantId, int quantity) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = await getHeaders();

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
    Map<String, String> headers = await getHeaders();
    String url = '';
    LineItem lineItem;
    Variant variant;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String orderToken = prefs.getString('orderToken');
    final String spreeApiKey = prefs.getString('spreeApiKey');

    if (orderToken != null && spreeApiKey == null) {
      url =
          'api/v1/orders/${prefs.getString('orderNumber')}?order_token=${prefs.getString('orderToken')}';
    } else if (spreeApiKey != null) {
      url = 'api/v1/orders/current';
    }

    if (url != '') {
      _lineItems = [];
      http
          .get(Settings.SERVER_URL + url, headers: headers)
          .then((response) {
        print(
            '------------------------- RESPONSE ------------------------------');
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
            displaySubTotal: responseBody['display_item_total'],
            displayTotal: responseBody['display_total'],
            lineItems: _lineItems,
            shipTotal: responseBody['display_ship_total'],
            totalQuantity: responseBody['total_quantity'],
            state: responseBody['state'],
            shipAddress: responseBody['ship_address']);
        _isLoading = false;
        prefs.setString('numberOfItems', _lineItems.length.toString());
        prefs.setString('orderToken', responseBody['token']);
        prefs.setString('orderNumber', responseBody['number']);
        notifyListeners();
      });
    } else {
      _lineItems = [];
    }
  }

  Future<bool> changeState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = await getHeaders();
    Map<dynamic, dynamic> responseBody;

    _isLoading = true;
    notifyListeners();

    http.Response response = await http.put(
        Settings.SERVER_URL +
            'api/v1/checkouts/${prefs.getString('orderNumber')}/next.json?order_token=${prefs.getString('orderToken')}',
        headers: headers);

    responseBody = json.decode(response.body);

    order = Order(
        id: responseBody['id'],
        itemTotal: responseBody['item_total'],
        displaySubTotal: responseBody['display_item_total'],
        displayTotal: responseBody['display_total'],
        lineItems: _lineItems,
        shipTotal: responseBody['display_ship_total'],
        totalQuantity: responseBody['total_quantity'],
        state: responseBody['state']);
    prefs.setString('numberOfItems', _lineItems.length.toString());
    await fetchCurrentOrder();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> completeOrder() async {
    _isLoading = true;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = await getHeaders();

    Map<String, dynamic> paymentPayload = {
      'payment': {'payment_method_id': 3, 'amount': order.itemTotal}
    };
    http.Response response = await http.post(
        Settings.SERVER_URL +
            'api/v1/orders/${prefs.getString('orderNumber')}/payments?order_token=${prefs.getString('orderToken')}',
        body: json.encode(paymentPayload),
        headers: headers);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('orderToken', null);
    prefs.setString('orderNumber', null);
    _lineItems.clear();
    order = null;
    notifyListeners();
  }
}

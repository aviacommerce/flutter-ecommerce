import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/models/line_item.dart';
import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';
import 'package:ofypets_mobile_app/models/order.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/models/variant.dart';
import 'package:ofypets_mobile_app/models/payment_methods.dart';
import 'package:ofypets_mobile_app/screens/product_detail.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin CartModel on Model {
  List<LineItem> _lineItems = [];
  Order order;
  bool _isLoading = false;
  List<PaymentMethod> _paymentMethods = [];

  Map<dynamic, dynamic> lineItemObject = Map();

  List<LineItem> get lineItems {
    return List.from(_lineItems);
  }

  List<PaymentMethod> get paymentMethods {
    return List.from(_paymentMethods);
  }

  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void getProductDetail(String slug, BuildContext context) async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();
    Product tappedProduct = Product();
    _isLoading = true;
    notifyListeners();
    // setLoading(true);

    http.Response response = await http.get(
        Settings.SERVER_URL + 'api/v1/products/$slug?data_set=large',
        headers: headers);

    responseBody = json.decode(response.body);
    print("PRODUCT DETAIL RESPONSE BODY");
    print(responseBody);

    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];

    int reviewProductId = responseBody['data']['attributes']["id"];
    variants = [];
    if (responseBody['data']['attributes']['has_variants']) {
      responseBody['data']['included']['variants'].forEach((variant) {
        print(
            "CURRENCY SYMBOL + ${variant['data']['attributes']['currency_symbol']}");
        optionValues = [];
        optionTypes = [];
        variant['data']['included']['option_values'].forEach((option) {
          // setState(() {
          optionValues.add(OptionValue(
            id: option['data']['attributes']['id'],
            name: option['data']['attributes']['name'],
            optionTypeId: option['data']['attributes']['option_type_id'],
            optionTypeName: option['data']['attributes']['option_type_name'],
            optionTypePresentation: option['data']['attributes']
                ['option_type_presentation'],
          ));
          // });
        });
        // setState(() {
        variants.add(Product(
            id: variant['data']['attributes']['id'],
            name: variant['data']['attributes']['name'],
            description: variant['data']['attributes']['description'],
            optionValues: optionValues,
            displayPrice: variant['data']['attributes']['display_price'],
            price: variant['data']['attributes']['price'],
            currencySymbol: responseBody['data']['attributes']
                ['currency_symbol'],
            costPrice: variant['data']['attributes']['cost_price'],
            image: variant['data']['included']['images'][0]['data']
                ['attributes']['product_url'],
            isOrderable: variant['data']['attributes']['is_orderable'],
            avgRating:
                double.parse(responseBody['data']['attributes']['avg_rating']),
            reviewsCount:
                responseBody['data']['attributes']['reviews_count'].toString(),
            reviewProductId: reviewProductId));
        // });
      });
      responseBody['data']['included']['option_types'].forEach((optionType) {
        // setState(() {
        optionTypes.add(OptionType(
            id: optionType['data']['attributes']['id'],
            name: optionType['data']['attributes']['name'],
            position: optionType['data']['attributes']['position'],
            presentation: optionType['data']['attributes']['presentation']));
        // });
      });
      // setState(() {
      tappedProduct = Product(
        name: responseBody['data']['attributes']['name'],
        displayPrice: responseBody['data']['attributes']['display_price'],
        currencySymbol: responseBody['data']['attributes']['currency_symbol'],
        price: responseBody['data']['attributes']['price'],
        costPrice: responseBody['data']['attributes']['cost_price'],
        avgRating:
            double.parse(responseBody['data']['attributes']['avg_rating']),
        reviewsCount:
            responseBody['data']['attributes']['reviews_count'].toString(),
        image: responseBody['data']['included']['master']['data']['included']
            ['images'][0]['data']['attributes']['product_url'],
        variants: variants,
        reviewProductId: reviewProductId,
        hasVariants: responseBody['data']['attributes']['has_variants'],
        optionTypes: optionTypes,
        taxonId: responseBody['data']['attributes']['taxon_ids'].first,
      );
      // });
    } else {
      // setState(() {
      tappedProduct = Product(
        id: responseBody['data']['included']['id'],
        name: responseBody['data']['attributes']['name'],
        displayPrice: responseBody['data']['attributes']['display_price'],
        price: responseBody['data']['attributes']['display_price'],
        currencySymbol: responseBody['data']['attributes']['currency_symbol'],
        costPrice: responseBody['data']['attributes']['cost_price'],
        avgRating:
            double.parse(responseBody['data']['attributes']['avg_rating']),
        reviewsCount:
            responseBody['data']['attributes']['reviews_count'].toString(),
        image: responseBody['data']['included']['master']['data']['included']
            ['images'][0]['data']['attributes']['product_url'],
        hasVariants: responseBody['data']['attributes']['has_variants'],
        isOrderable: responseBody['data']['included']['master']['data']
            ['attributes']['is_orderable'],
        reviewProductId: reviewProductId,
        description: responseBody['data']['attributes']['description'],
        taxonId: responseBody['data']['attributes']['taxon_ids'].first,
      );
      // });
    }

    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => ProductDetailScreen(tappedProduct));
    Navigator.push(context, route);
    // setLoading(false);
    _isLoading = false;
    notifyListeners();
  }

  void addProduct({int variantId, int quantity}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _lineItems.clear();
    _isLoading = true;
    notifyListeners();
    final String orderToken = prefs.getString('orderToken');

    if (orderToken != null) {
      createNewLineItem(variantId, quantity);
    } else {
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

  Future<bool> completeOrder(int paymentMethodId) async {
    print("COMPLETE ORDER $paymentMethodId");
    _isLoading = true;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = await getHeaders();

    Map<String, dynamic> paymentPayload = {
      'payment': {
        'payment_method_id': paymentMethodId,
        'amount': order.itemTotal
      }
    };
    http.Response response = await http.post(
        Settings.SERVER_URL +
            'api/v1/orders/${prefs.getString('orderNumber')}/payments?order_token=${prefs.getString('orderToken')}',
        body: json.encode(paymentPayload),
        headers: headers);
    print(json.decode(response.body));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  getPaymentMethods() async {
    _paymentMethods = [];
    _isLoading = true;
    notifyListeners();
    Map<dynamic, dynamic> responseBody;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = await getHeaders();
    http.Response response = await http.get(
        Settings.SERVER_URL +
            'api/v1/orders/${prefs.getString('orderNumber')}/payments/new?order_token=${prefs.getString('orderToken')}',
        headers: headers);
    responseBody = json.decode(response.body);
    responseBody['payment_methods'].forEach((paymentMethodObj) {
      if (paymentMethodObj['name'] == 'Payubiz' ||
          paymentMethodObj['name'] == 'COD') {
        _paymentMethods.add(PaymentMethod(
            id: paymentMethodObj['id'], name: paymentMethodObj['name']));
        notifyListeners();
      }
    });
    _isLoading = false;
    notifyListeners();
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

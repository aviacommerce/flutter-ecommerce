import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ofypets_mobile_app/utils/params.dart';
import 'package:ofypets_mobile_app/screens/payubiz.dart';

class OrderResponse extends StatefulWidget {
  final String orderNumber;
  Map<dynamic, dynamic> detailOrder;
  bool success;
  OrderResponse({this.orderNumber, this.detailOrder, this.success});
  @override
  State<StatefulWidget> createState() {
    return _OrderResponseState();
  }
}

class _OrderResponseState extends State<OrderResponse> {
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;
  var formatter = new DateFormat('dd-MMM-yyyy hh:mm a');
  bool _isLoading = false;
  bool retryButton = false;

  @override
  void initState() {
    super.initState();
    getOrderDetails();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  getOrderDetails() async {
    print("---------GETTING ORDER RESPONSE-------");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("ORDER NUMBER ${widget.orderNumber}");
    if (widget.orderNumber != null) {
      Map<String, String> headers = await getHeaders();
      await http
          .get(Settings.SERVER_URL + '/api/v1/orders/${widget.orderNumber}',
              headers: headers)
          .then((response) {
        print("RESPONSE BODY ------- ${json.decode(response.body)}");
        // print("PAYMENTS ARRAY _________>>>>>>> ${json.decode(response.body)["payments"]}");
        setState(() {
          responseBody = json.decode(response.body);
        });
      });
    } else {
      print("DETAIL ORDER ------- ${widget.detailOrder}");
      setState(() {
        responseBody = widget.detailOrder;
      });
    }
    print("PAYMENTS ARRAY -------> ${responseBody['payments']}");
    print("CHECK RETRY BUTTON");
    if (responseBody["payments"].length > 0) {
      print("PAYMENT LENGTH >0");
      if (responseBody["payments"][0]["payment_method"]["name"] == 'Payubiz' &&
          responseBody["payment_state"] != 'paid') {
        print("------PAID----");
        retryButton = true;
      } else {
        retryButton = false;
      }
    }
  }

  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return WillPopScope(
          onWillPop: () {
            if (widget.detailOrder == null) {
              model.clearData();
              Navigator.canPop(context);
            }
            return Future<bool>.value(false);
          },
          child: Scaffold(
            appBar: new AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  if (widget.detailOrder == null) {
                    print("ORDER EXISTS------");
                    model.clearData();
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: new Text('Order Details'),
            ),
            body: responseBody != null
                ? new SingleChildScrollView(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: new Column(
                      children: <Widget>[
                        new Card(
                          child: new Container(
                            width: _deviceSize.width,
                            margin: EdgeInsets.all(10),
                            child: new Column(
                              children: <Widget>[
                                widget.orderNumber != null
                                    ? new Text(
                                        widget.success != null &&
                                                !widget.success
                                            ? 'Payment Failed!! Please try again.'
                                            : 'Your order successfully placed!',
                                        style: new TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500),
                                      )
                                    : new Text(
                                        'Your Order Details!',
                                        style: new TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500),
                                      )
                              ],
                            ),
                          ),
                        ),
                        new Card(
                          child: new Container(
                            width: _deviceSize.width,
                            margin: EdgeInsets.all(10),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text('ORDER DETAILS'),
                                Divider(),
                                SizedBox(height: 5),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(child: new Text('Order Number')),
                                    Expanded(
                                        child: new Text(responseBody["number"] +
                                            ' ( ${responseBody["total_quantity"]} items )'))
                                  ],
                                ),
                                SizedBox(height: 10),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(child: new Text('Order Date')),
                                    Expanded(
                                        child: responseBody["completed_at"] !=
                                                null
                                            ? Text((formatter.format(
                                                DateTime.parse((responseBody[
                                                        "completed_at"]
                                                    .split('+05:30')[0])))))
                                            : Text("Date Missing!"))
                                  ],
                                ),
                                SizedBox(height: 10),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(child: new Text('Payment Mode')),
                                    Expanded(
                                        child: new Text(
                                            (responseBody["payments"][0]
                                                ["payment_method"]["name"]),
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w800))),
                                  ],
                                ),
                                SizedBox(height: 10),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(child: new Text('Payment Status')),
                                    getPaymentStatus(responseBody),
                                  ],
                                ),
                                SizedBox(height: 10),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(child: new Text('Shipping')),
                                    Expanded(
                                        child: responseBody["shipment_state"] !=
                                                null
                                            ? new Text(
                                                responseBody["shipment_state"],
                                                style: new TextStyle(
                                                    fontWeight:
                                                        FontWeight.w800))
                                            : new Text('N/A',
                                                style: new TextStyle(
                                                    fontWeight:
                                                        FontWeight.w800))),
                                  ],
                                ),
                                Divider(),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(child: new Text('Order Total')),
                                    Expanded(
                                        child: new Text(
                                            (responseBody["display_total"]),
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w800))),
                                  ],
                                ),
                                retryButton
                                    ? new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: new FlatButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2)),
                                                color: Colors.green,
                                                onPressed: () {
                                                  if (!_isLoading) {
                                                    retryPayment(responseBody);
                                                  }
                                                },
                                                child: !_isLoading
                                                    ? new Text(
                                                        'Retry Payment (Payubiz)',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )
                                                    : CupertinoActivityIndicator()),
                                          ),
                                          // Expanded(
                                          //     child: new Text(
                                          //         (responseBody["display_total"]),
                                          //         style: new TextStyle(
                                          //             fontWeight: FontWeight.w800))),
                                        ],
                                      )
                                    : Container(),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        new Card(
                          child: new Container(
                            width: _deviceSize.width,
                            margin: EdgeInsets.all(10),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text('DELIVERY ADDRESS'),
                                Divider(),
                                new Text(
                                    responseBody["ship_address"]["full_name"] +
                                        ',',
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w800)),
                                SizedBox(height: 5),
                                new Text(responseBody["ship_address"]
                                        ["address1"] +
                                    ','),
                                SizedBox(height: 5),
                                new Text(
                                    '${responseBody["ship_address"]["address2"]}, ${responseBody["ship_address"]["city"]},'),
                                SizedBox(height: 5),
                                new Text(
                                    '${responseBody["ship_address"]["zipcode"]},'),
                                SizedBox(height: 5),
                                new Text(
                                    '${responseBody["ship_address"]["state"]["name"]}'),
                                SizedBox(height: 5),
                                new Text(
                                    '${responseBody["ship_address"]["phone"]}',
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w800)),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        new Card(
                          child: new Container(
                            width: _deviceSize.width,
                            margin: EdgeInsets.all(10),
                            child: new Column(
                              children:
                                  lineitemsList(responseBody["line_items"]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )),
          ));
    });
  }

  List<Widget> lineitemsList(items) {
    List<Widget> list = [];
    list.add(new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[new Text('ITEMS'), Divider()],
    ));
    items.forEach((item) => {
          list.add(
            new Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Stack(children: <Widget>[
                  new Container(
                      height: 100,
                      width: 100,
                      child: new FadeInImage(
                        image: NetworkImage(
                            item["variant"]["images"][0]["product_url"] != null
                                ? item["variant"]["images"][0]["product_url"]
                                : ''),
                        placeholder: AssetImage(
                            'images/placeholders/no-product-image.png'),
                      )),
                  Divider()
                ]),
                SizedBox(width: 30),
                Expanded(
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 5),
                        new Text('${item["variant"]["name"]}'),
                        SizedBox(height: 5),
                        new Text('Qty : ${item["quantity"]}'),
                        SizedBox(height: 5),
                        item["variant"]["options_text"] != null
                            ? new Text('${item["variant"]["options_text"]}')
                            : '',
                        SizedBox(height: 5),
                        new Text('${item["display_amount"]}',
                            style: new TextStyle(fontWeight: FontWeight.w800)),
                        Divider()
                      ]),
                ),
              ],
            ),
          )
        });
    return list;
  }

  getPaymentStatus(responseBody) {
    String payMethod = responseBody["payments"] != null
        ? responseBody["payments"][0]["payment_method"]["name"]
        : '';
    String payState = responseBody["payment_state"];
    if (payState == 'balance_due') {
      return Expanded(
          child: new Text('Balance due',
              style: new TextStyle(fontWeight: FontWeight.w800)));
    } else if (payState == 'paid') {
      return Expanded(
          child: new Text('Paid',
              style: new TextStyle(fontWeight: FontWeight.w800)));
    } else if (payState == 'void') {
      return Expanded(
          child: new Text('Void',
              style: new TextStyle(fontWeight: FontWeight.w800)));
    }
  }

  retryPayment(responseBody) async {
    setState(() {
      _isLoading = true;
    });
    String orderNumber = responseBody["number"];
    String url = await getParams(orderNumber: orderNumber);
    print("URL RECEIEVED -> $url");
    setState(() {
      _isLoading = false;
    });
    MaterialPageRoute payment = MaterialPageRoute(
        builder: (context) => PayubizScreen(
              url,
              orderNumber: orderNumber,
            ));
    Navigator.push(context, payment);
  }
}

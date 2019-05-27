import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'dart:convert';

class OrderResponse extends StatefulWidget {
  final String orderNumber;
  OrderResponse(this.orderNumber);
  @override
  State<StatefulWidget> createState() {
    return _OrderResponseState();
  }
}

class _OrderResponseState extends State<OrderResponse> {
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;
  @override
  void initState() {
    super.initState();
    getOrderDetails();
  }

  @override
  getOrderDetails() async {
    await http.get(Settings.SERVER_URL + '/api/v1/orders/${widget.orderNumber}', headers: {
      "content-type": "application/json",
      "ng-api": "true",
      "auth-token": "e4700279785ec123930be85dfecf7d7dca30fd718d5f8bfb"
    }).then((response) {
      setState(() {
        responseBody = json.decode(response.body);
      });
    });
  }

  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Order Status'),
      ),
      body: responseBody != null
          ? new SingleChildScrollView(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              // child: Text('hghsg $responseBody')
              child: new Column(
                children: <Widget>[
                  new Card(
                    child: new Container(
                      width: _deviceSize.width,
                      margin: EdgeInsets.all(10),
                      child: new Column(
                        children: <Widget>[
                          new Text(
                            'Your order successfully placed!',
                            style: new TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w500),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(child: new Text('Order Number')),
                              Expanded(
                                  child: new Text(responseBody["number"] +
                                      ' ( ${responseBody["total_quantity"]} items )'))
                            ],
                          ),
                          SizedBox(height: 10),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(child: new Text('Order Date')),
                              Expanded(
                                  child:
                                      new Text((responseBody["completed_at"])))
                            ],
                          ),
                          SizedBox(height: 10),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Divider(),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(child: new Text('Order Total')),
                              Expanded(
                                  child: new Text(
                                      (responseBody["display_total"]),
                                      style: new TextStyle(
                                          fontWeight: FontWeight.w800))),
                            ],
                          ),
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
                              responseBody["ship_address"]["full_name"] + ',',
                              style:
                                  new TextStyle(fontWeight: FontWeight.w800)),
                          SizedBox(height: 5),
                          new Text(
                              responseBody["ship_address"]["address1"] + ','),
                          SizedBox(height: 5),
                          new Text(
                              '${responseBody["ship_address"]["address2"]}, ${responseBody["ship_address"]["city"]}'),
                          SizedBox(height: 5),
                          new Text(
                              '${responseBody["ship_address"]["city"]} - ${responseBody["ship_address"]["zipcode"]}, ${responseBody["ship_address"]["state"]["name"]}'),
                          SizedBox(height: 5),
                          new Text('${responseBody["ship_address"]["phone"]}',
                              style:
                                  new TextStyle(fontWeight: FontWeight.w800)),
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
                        children: lineitemsList(responseBody["line_items"]),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
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
                            '${item["variant"]["images"][0]["product_url"]}'),
                        placeholder: AssetImage(
                            'images/placeholders/no-product-image.png'),
                      ))
                ]),
                SizedBox(width: 30),
                Expanded(
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text('${item["variant"]["name"]}'),
                        SizedBox(height: 5),
                        new Text('Qty : ${item["quantity"]}'),
                        SizedBox(height: 5),
                        item["variant"]["options_text"] != null
                            ? new Text('${item["variant"]["options_text"]}')
                            : '',
                        SizedBox(height: 5),
                        new Text('${item["display_amount"]}',
                            style: new TextStyle(fontWeight: FontWeight.w800))
                      ]),
                ),
              ],
            ),
          )
        });

    return list;
  }
}

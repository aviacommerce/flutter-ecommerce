import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ofypets_mobile_app/models/order.dart';
import 'package:ofypets_mobile_app/screens/order_response.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';

class OrderList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderList();
  }
}

class _OrderList extends State<OrderList> {
  Map<dynamic, dynamic> orderListResponse;
  var formatter = new DateFormat('dd-MMM-yyyy hh:mm a');
  final int perPage = TWENTY;
  int currentPage = ONE;
  int subCatId = ZERO;
  static const int PAGE_SIZE = 20;
  List<Order> ordersList = [];
  Map<dynamic, dynamic> responseBody;
  void initState() {
    super.initState();
  }

  Size _deviceSize;

  Future<List<Order>> getOrdersLists() async {
    ordersList = [];
    Map<String, String> headers = await getHeaders();
    final response = (await http.get(
            Settings.SERVER_URL +
                '/api/v1/orders/mine?desc&page=$currentPage&per_page=$perPage',
            headers: headers))
        .body;

    currentPage++;
    responseBody = json.decode(response);
    orderListResponse = json.decode(response);
    responseBody['orders'].forEach((order) {
      if (order["completed_at"] != null) {
        setState(() {
          ordersList.add(Order(
              completedAt: order["completed_at"],
              imageUrl: order["line_items"][0]["variant"]["images"][0]
                  ["small_url"],
              displayTotal: order["display_total"],
              number: order["number"]));
        });
      }
    });
    return ordersList;
  }

  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: Theme(
        data: ThemeData(primarySwatch: Colors.blue),
        child: PagewiseListView(
          pageSize: PAGE_SIZE,
          itemBuilder: orderItem,
          pageFuture: (pageIndex) => getOrdersLists(),
        ),
      ),
    );
  }

  Widget orderItem(BuildContext context, Order order, int index) {
    print(order.completedAt);
    if (order.completedAt != null) {
      return GestureDetector(
        onTap: () {
          goToDetailsPage(orderListResponse["orders"][index]);
        },
        child: Card(
          child: new Container(
            width: _deviceSize.width,
            margin: EdgeInsets.all(5),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: orderVariantImage(order.imageUrl),
                    title: Text('${order.number}'),
                    subtitle: Text((formatter.format(DateTime.parse(
                        (order.completedAt.split('+05:30')[0]))))),
                    trailing: Text('${order.displayTotal}'),
                  ),
                ]),
          ),
        ),
      );
    }
  }

  Widget orderVariantImage(imageUrl) {
    return FadeInImage(
      image: NetworkImage(imageUrl),
      placeholder: AssetImage('images/placeholders/no-product-image.png'),
    );
  }

  goToDetailsPage(detailOrder) {
    MaterialPageRoute orderResponse = MaterialPageRoute(
        builder: (context) =>
            OrderResponse(orderNumber: null, detailOrder: detailOrder));
    Navigator.push(context, orderResponse);
  }
}

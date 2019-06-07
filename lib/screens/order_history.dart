import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/screens/order_response.dart';
import 'dart:convert';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:intl/intl.dart';

class OrderList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderList();
  }
}

class _OrderList extends State<OrderList> {
  Map<dynamic, dynamic> orderListResponse;
  var formatter = new DateFormat('dd-MMM-yyyy hh:mm a');

  void initState() {
    super.initState();
    getOrdersLists();
  }

  Size _deviceSize;

  getOrdersLists() async {
    Map<String, String> headers = await getHeaders(); 
    await http.get(Settings.SERVER_URL + '/api/v1/orders/mine', headers: headers).then((response) {
      setState(() {
        orderListResponse = json.decode(response.body);
      });
    });
  }

  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: orderListResponse != null
          ? ListView.builder(
              itemCount: orderListResponse["orders"].length,
              itemBuilder: (BuildContext context, int index) {
                return orderItem(index);
              },
            )
          : Center(child: CircularProgressIndicator(backgroundColor: Colors.blue)),
    );
  }

  Widget orderItem(int index) {
    if (orderListResponse["orders"][index]["completed_at"] != null) {
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
                          leading: orderVariantImage(orderListResponse["orders"]
                                  [index]["line_items"][0]["variant"]["images"]
                              [0]["small_url"]),
                          title: Text(
                              '${orderListResponse["orders"][index]["number"]}'),
                          subtitle: Text((formatter.format(DateTime.parse(
                              (orderListResponse["orders"][index]
                                      ["completed_at"]
                                  .split('+05:30')[0]))))),
                          trailing: Text(
                              '${orderListResponse["orders"][index]["display_total"]}'),
                        ),
                      ]))));
    }
  }

  Widget orderVariantImage(imageUrl) {
    return FadeInImage(
      image: NetworkImage(imageUrl),
      placeholder: AssetImage('images/placeholders/no-product-image.png'),
    );
  }

  goToDetailsPage(detailOrder) {
    MaterialPageRoute orderResponse =
        MaterialPageRoute(builder: (context) => OrderResponse(orderNumber: null, detailOrder: detailOrder));
    Navigator.push(context, orderResponse);
  }
}

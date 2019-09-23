import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ofypets_mobile_app/models/order.dart';
import 'package:ofypets_mobile_app/screens/order_response.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/widgets/shopping_cart_button.dart';

class OrderList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderList();
  }
}

class _OrderList extends State<OrderList> {
  List<dynamic> orderListResponse = List();
  var formatter = new DateFormat('dd-MMM-yyyy hh:mm a');
  final int perPage = TWENTY;
  int currentPage = ONE;
  int subCatId = ZERO;
  static const int PAGE_SIZE = 20;
  List<Order> ordersList = [];
  Map<dynamic, dynamic> responseBody;
  final scrollController = ScrollController();
  bool hasMore = false;
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
    getOrdersLists();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        getOrdersLists();
      }
    });
  }

  Size _deviceSize;

  Future<List<Order>> getOrdersLists() async {
    print("GET ORDER LIST");
    setState(() {
      hasMore = false;
    });

    Map<String, String> headers = await getHeaders();
    final response = (await http.get(
            Settings.SERVER_URL +
                '/api/v1/orders/mine?desc&page=$currentPage&per_page=$perPage',
            headers: headers))
        .body;

    currentPage++;
    responseBody = json.decode(response);
    print('ORDER LIST RESPONSE $responseBody');

    responseBody['orders'].forEach((order) {
      if (order["completed_at"] != null) {
        setState(() {
          ordersList.add(Order(
              completedAt: order["completed_at"],
              imageUrl: order["line_items"][0]["variant"]["images"][0]
                  ["small_url"],
              displayTotal: order["display_total"],
              number: order["number"],
              paymentMethod: order["payments"][0]["payment_method"]["name"],
              paymentState: order["payment_state"],
              shipState: order["shipment_state"]));
          orderListResponse.add(order);
        });
      }
    });
    setState(() {
      hasMore = true;
    });
    return ordersList;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Order History'),
        actions: <Widget>[shoppingCartIconButton()],
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Theme(
            data: ThemeData(primarySwatch: Colors.green),
            child: ListView.builder(
                controller: scrollController,
                itemCount: ordersList.length + 1,
                itemBuilder: (mainContext, index) {
                  if (index < ordersList.length) {
                    // return favoriteCard(
                    //     context, searchProducts[index], index);
                    return orderItem(context, ordersList[index], index);
                  }
                  if (hasMore && ordersList.length == 0) {
                    return noProductFoundWidget();
                  }
                  if (!hasMore) {
                    return Container(
                        height: _deviceSize.height,
                        child: Center(
                            child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        )));
                  } else {
                    return Container();
                  }
                }),
          )),
      /*Theme(
        data: ThemeData(primarySwatch: Colors.green),
        child: PagewiseListView(
          pageSize: PAGE_SIZE,
          itemBuilder: orderItem,
          pageFuture: (pageIndex) => getOrdersLists(),
        ),
      ),*/
    );
  }

  Widget orderItem(BuildContext context, Order order, int index) {
    if (order.completedAt != null) {
      return GestureDetector(
        onTap: () {
          goToDetailsPage(orderListResponse[index]);
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
                      trailing: trailingSpace(order),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0)),
                ]),
          ),
        ),
      );
    }
  }

  Widget noProductFoundWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 220.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.card_giftcard,
                  size: 80.0,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'No Previous Orders',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 35.0, vertical: 5),
                  child: Text(
                    'We will save items you buy here for fast and easy shopping',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 150,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: RaisedButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      // Navigator.pop(context);
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
                    },
                    child: Text(
                      'START SHOPPING',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget orderVariantImage(imageUrl) {
    return FadeInImage(
      image: NetworkImage(imageUrl != null ? imageUrl : ''),
      placeholder: AssetImage(
        'images/placeholders/no-product-image.png',
      ),
      width: 35,
    );
  }

  goToDetailsPage(detailOrder) {
    MaterialPageRoute orderResponse = MaterialPageRoute(
        builder: (context) =>
            OrderResponse(orderNumber: null, detailOrder: detailOrder));
    Navigator.push(context, orderResponse);
  }

  trailingSpace(detailOrder) {
    return new Container(
      margin: EdgeInsets.only(top: 8),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text('${detailOrder.displayTotal}'),
            SizedBox(height: 8),
            getOrderStatus(detailOrder)
          ]),
    );
  }

  getOrderStatus(detailOrder) {
    if (detailOrder.paymentState == 'balance_due' &&
        detailOrder.shipState == 'shipped') {
      return Text('Shipped', style: TextStyle(color: Colors.green));
    } else if (detailOrder.paymentState == 'balance_due') {
      return Text('Pending', style: TextStyle(color: Colors.blue));
    } else if (detailOrder.paymentState == 'void') {
      return Text('Canceled', style: TextStyle(color: Colors.red));
    } else if (detailOrder.paymentState == 'paid' &&
        detailOrder.shipState == 'shipped') {
      return Text('Completed', style: TextStyle(color: Colors.grey));
    } else {
      return Text('Processing', style: TextStyle(color: Colors.amber));
    }
  }
}

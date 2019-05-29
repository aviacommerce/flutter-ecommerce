import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/order_response.dart';

class PaymentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PaymentScreenState();
  }
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Payment Methods'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              orderDetailColumn(),
              Card(
                elevation: 3,
                margin: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          'CASH ON DELIVERY(COD)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          'Pay with Cash or Card when your order is delivered.',
                        )),
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          'Note: All authorised notes are accepted. Credit/Debit cards are also accepted.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: paymentButton(context),
      );
    });
  }

  Widget paymentButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.all(20),
        child: FlatButton(
          color: Colors.green,
          child: Text(
            'PAY ON DELIVERY',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          onPressed: () async {
            bool isComplete = false;
            isComplete = await model.completeOrder();
            if (isComplete) {
              bool isChanged = false;

              if (model.order.state == 'payment') {
                isChanged = await model.changeState();
              }
              if (isChanged) {
                pushSuccessPage();
              }
            }
          },
        ),
      );
    });
  }

  Widget orderDetailColumn() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Card(
        elevation: 3,
        margin: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                model.order.totalQuantity.toString() + ' ITEMS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            amountRow('Sub Total', model.order.displaySubTotal, model),
            amountRow('Delivery', model.order.shipTotal, model),
            amountRow('Total', model.order.displayTotal, model)
          ],
        ),
      );
    });
  }

  Widget amountRow(String title, String displayAmount, MainModel model) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: EdgeInsets.all(10),
        child: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Text(
          displayAmount,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      )
    ]);
  }

  pushSuccessPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderNumber = prefs.getString('orderNumber');
    MaterialPageRoute payment =
        MaterialPageRoute(builder: (context) => OrderResponse(orderNumber));
    Navigator.pushAndRemoveUntil(
      context,
      payment,
      ModalRoute.withName('/'),
    );
    // Navigator.push(context, payment);
  }
}

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/order_response.dart';
import 'package:ofypets_mobile_app/widgets/order_details_card.dart';

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
            bottom: model.isLoading
                ? PreferredSize(
                    child: LinearProgressIndicator(),
                    preferredSize: Size.fromHeight(10),
                  )
                : PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(10),
                  )),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              orderDetailCard(),
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
                          'Pay U Biz',
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
  
  pushSuccessPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderNumber = prefs.getString('orderNumber');
    MaterialPageRoute payment =
        MaterialPageRoute(builder: (context) => OrderResponse(orderNumber: orderNumber));
    Navigator.pushAndRemoveUntil(
      context,
      payment,
      ModalRoute.withName('/'),
    );
    // Navigator.push(context, payment);
  }
}

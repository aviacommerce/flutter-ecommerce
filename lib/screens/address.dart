import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/payment.dart';

class AddressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddressPageState();
  }
}

class _AddressPageState extends State<AddressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Address'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          addressContainer(),
          Divider(),
          SizedBox(
            height: 10,
          ),
          itemTotalContainer(),
          paymentButton(context)
        ],
      )),
    );
  }

  Widget itemTotalContainer() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              model.order.totalQuantity.toString() + ' ITEMS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Sub Total',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                model.order.itemTotal,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Delivery',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                model.order.shipTotal,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          ])
        ],
      );
    });
  }

  Widget paymentButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: FlatButton(
        color: Colors.green,
        child: Text(
          'CONTINUE TO PAYMENT',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        onPressed: () {
          MaterialPageRoute payment =
              MaterialPageRoute(builder: (context) => PaymentScreen());
          Navigator.push(context, payment);
        },
      ),
    );
  }

  Widget textFieldContainer(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }

  Widget addressContainer() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (model.shipAddress != null) {
        return Container(
            margin: EdgeInsets.only(left: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 10,
              ),
              Text(
                model.shipAddress['full_name'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              textFieldContainer(model.shipAddress['address1']),
              textFieldContainer(model.shipAddress['address2']),
              textFieldContainer(model.shipAddress['city'] +
                  ' - ' +
                  model.shipAddress['zipcode']),
              textFieldContainer(model.shipAddress['state']['name']),
              textFieldContainer(
                  'Mobile: ' + ' - ' + model.shipAddress['phone']),
            ]));
      } else {
        return Container(child: Text('New Address Form'));
      }
    });
  }
}

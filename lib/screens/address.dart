import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/payment.dart';
import 'package:ofypets_mobile_app/screens/update_address.dart';

class AddressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddressPageState();
  }
}

class _AddressPageState extends State<AddressPage> {
  bool stateChanged = true;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Delivery Address'),
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
          children: <Widget>[
            FlatButton(
              child: Text(model.order.shipAddress != null
                  ? 'EDIT ADDRESS'
                  : 'ADD ADDRESS'),
              onPressed: () {
                MaterialPageRoute payment = MaterialPageRoute(
                    builder: (context) =>
                        UpdateAddress(model.order.shipAddress));
                Navigator.push(context, payment);
              },
            ),
            addressContainer(),
            orderDetailColumn(),
          ],
        )),
        bottomNavigationBar: paymentButton(context),
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

  Widget paymentButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.all(20),
        child: FlatButton(
          color: Colors.green,
          child: Text(
            'CONTINUE TO PAYMENT',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          onPressed: () async {
            if (model.order.state == 'delivery' ||
                model.order.state == 'address') {
              // print('STATE IS DELIVERY/ADDRESS, CHANGE STATE');
              bool _stateischanged = await model.changeState();
              if (_stateischanged) {
                if (model.order.state == 'delivery') {
                  _stateischanged = await model.changeState();
                }
              }
              setState(() {
                stateChanged = _stateischanged;
              });
            }
            if (stateChanged) {
              print('STATE IS CHANGED, FETCH CURRENT ORDER');
              model.fetchCurrentOrder();
              MaterialPageRoute payment =
                  MaterialPageRoute(builder: (context) => PaymentScreen());
              Navigator.push(context, payment);
            }
          },
        ),
      );
    });
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

  Widget addressContainer() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (model.order.shipAddress != null) {
        return Card(
            elevation: 3,
            margin: EdgeInsets.all(15),
            child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        model.order.shipAddress['full_name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      textFieldContainer(model.order.shipAddress['address1']),
                      textFieldContainer(model.order.shipAddress['address2']),
                      textFieldContainer(model.order.shipAddress['city'] +
                          ' - ' +
                          model.order.shipAddress['zipcode']),
                      textFieldContainer(
                          model.order.shipAddress['state']['name']),
                      textFieldContainer('Mobile: ' +
                          ' - ' +
                          model.order.shipAddress['phone']),
                    ])));
      }
    });
  }
}

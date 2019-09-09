import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/payment.dart';
import 'package:ofypets_mobile_app/screens/update_address.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/widgets/order_details_card.dart';
import 'package:scoped_model/scoped_model.dart';

class AddressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddressPageState();
  }
}

class _AddressPageState extends State<AddressPage> {
  bool stateChanged = true;
  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

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
              child: Text(model.isLoading
                  ? ''
                  : model.order.shipAddress != null
                      ? 'EDIT ADDRESS'
                      : 'ADD ADDRESS'),
              onPressed: () {
                MaterialPageRoute payment = MaterialPageRoute(
                    builder: (context) =>
                        UpdateAddress(model.order.shipAddress, true));
                Navigator.push(context, payment);
              },
            ),
            addressContainer(),
            Divider(),
            orderDetailCard(),
          ],
        )),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          color: Colors.green,
          child: Text(
            'PLACE ORDER',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.w300),
          ),
          onPressed: () {
            model.order.shipAddress != null ? pushPaymentScreen(model) : null;
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

  pushPaymentScreen(MainModel model) async {
    if (model.order.state == 'delivery' || model.order.state == 'address') {
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
      model.getPaymentMethods();
      MaterialPageRoute payment =
          MaterialPageRoute(builder: (context) => PaymentScreen());
      Navigator.push(context, payment);
    }
  }

  Widget addressContainer() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (model.order.shipAddress != null) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
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
                    model.order.shipAddress.firstName +
                        ' ' +
                        model.order.shipAddress.lastName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  textFieldContainer(model.order.shipAddress.address1),
                  textFieldContainer(model.order.shipAddress.address2),
                  textFieldContainer(model.order.shipAddress.city +
                      ' - ' +
                      model.order.shipAddress.pincode),
                  textFieldContainer(model.order.shipAddress.state),
                  textFieldContainer(
                      'Mobile: ' + ' - ' + model.order.shipAddress.mobile),
                ],
              ),
            ),
          ),
        );
      } else
        return Container();
    });
  }
}

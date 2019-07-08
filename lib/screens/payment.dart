import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/order_response.dart';
import 'package:ofypets_mobile_app/utils/params.dart';

class PaymentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PaymentScreenState();
  }
}

enum SingingCharacter { cod, payubiz }

class _PaymentScreenState extends State<PaymentScreen> {
// In the State of a stateful widget:
  SingingCharacter _character = SingingCharacter.cod;
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
            children: <Widget>[
              RadioListTile<SingingCharacter>(
                title: const Text('Cash on Delivery'),
                value: SingingCharacter.cod,
                groupValue: _character,
                onChanged: (SingingCharacter value) {
                  setState(() {
                    _character = value;
                  });
                },
                activeColor: Colors.green,
              ),
              RadioListTile<SingingCharacter>(
                title: const Text('PayuBiz'),
                value: SingingCharacter.payubiz,
                groupValue: _character,
                onChanged: (SingingCharacter value) {
                  setState(() {
                    _character = value;
                  });
                },
                activeColor: Colors.green,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.green,
          child: Text(
            _character == SingingCharacter.cod
                ? 'PAY ON DELIVERY'
                : 'CONTINUE TO PAYUBIZ',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w300),
          ),
          onPressed: () async {
            if (_character == SingingCharacter.cod) {
              bool isComplete = false;
              isComplete = await model.completeOrder(3);
              if (isComplete) {
                bool isChanged = false;

                if (model.order.state == 'payment') {
                  isChanged = await model.changeState();
                }
                if (isChanged) {
                  pushSuccessPage();
                }
              }
            } else {
              print('PAYUBIZ');
              bool isComplete = false;
              isComplete = await model.completeOrder(2);
              if (isComplete) {
                bool isChanged = false;

                if (model.order.state == 'payment') {
                  isChanged = await model.changeState();
                }
                if (isChanged) {
                  // pushSuccessPage();
                  getParams();
                }
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
    MaterialPageRoute payment = MaterialPageRoute(
        builder: (context) => OrderResponse(orderNumber: orderNumber));
    Navigator.pushAndRemoveUntil(
      context,
      payment,
      ModalRoute.withName('/'),
    );
  }
}

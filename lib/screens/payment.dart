import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/success.dart';

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
            children: <Widget>[
              Text(''),
              Card(
                child: Column(
                  children: <Widget>[
                    Container(child: Text('COD')),
                    FlatButton(
                      child: Text('PAY ON DELIVERY'),
                      onPressed: () {
                        if (model.order.state == 'payment') {
                          model.changeState();
                        }
                        model.completeOrder();
                        MaterialPageRoute payment = MaterialPageRoute(
                            builder: (context) => SuccessPage());
                        Navigator.push(context, payment);
                        //Push Success Page
                      },
                    )
                  ],
                ),
              ),
              Text('')
            ],
          ),
        ),
      );
    });
  }
}

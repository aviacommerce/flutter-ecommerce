import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/models/payment_methods.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/order_response.dart';
import 'package:ofypets_mobile_app/screens/payubiz.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/utils/params.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PaymentScreenState();
  }
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  static List<PaymentMethod> paymentMethods = List();
  String _character = '';
  int selectedPaymentId;

  @override
  void initState() {
    super.initState();
    // getPaymentMethods();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

// In the State of a stateful widget:
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Payment Methods'),
            bottom: model.isLoading || _isLoading
                ? PreferredSize(
                    child: LinearProgressIndicator(),
                    preferredSize: Size.fromHeight(10),
                  )
                : PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(10),
                  )),
        body: _isLoading
            ? Container()
            : ListView.builder(
                itemCount: model.paymentMethods.length,
                itemBuilder: (BuildContext context, int index) {
                  return paymentMethodsRadioButton(index);
                },
              ),
        bottomNavigationBar: !_isLoading ? paymentButton(context) : Container(),
      );
    });
  }

  paymentMethodsRadioButton(int index) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return RadioListTile<String>(
        title: Text(model.paymentMethods[index].name),
        value: model.paymentMethods[index].name,
        groupValue: _character,
        onChanged: (value) {
          setState(() {
            _character = value;
          });
        },
        activeColor: Colors.green,
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
            _character == ''
                ? 'SELECT PAYMENT METHOD'
                : _character == 'COD'
                    ? 'PAY ON DELIVERY'
                    : 'CONTINUE TO PAYUBIZ',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w300),
          ),
          onPressed: () async {
            if (_character == 'COD') {
              bool isComplete = false;
              model.paymentMethods.forEach((paymentMethodObj) async {
                if (paymentMethodObj.name == 'COD') {
                  setState(() {
                    selectedPaymentId = paymentMethodObj.id;
                  });
                }
              });
              isComplete = await model.completeOrder(selectedPaymentId);
              if (isComplete) {
                bool isChanged = false;

                if (model.order.state == 'payment') {
                  isChanged = await model.changeState();
                }
                if (isChanged) {
                  pushSuccessPage();
                }
              }
            } else if (_character == 'Payubiz') {
              print('PAYUBIZ');
              bool isComplete = false;
              // isComplete = await model.completeOrder(paymentMethods.first.id);
              model.paymentMethods.forEach((paymentMethodObj) async {
                print(paymentMethodObj.name);
                if (paymentMethodObj.name == 'Payubiz') {
                  setState(() {
                    selectedPaymentId = paymentMethodObj.id;
                  });
                }
              });
              isComplete = await model.completeOrder(selectedPaymentId);
              if (isComplete) {
                print("IS COMPLETE TRUE");
                bool isChanged = false;

                if (model.order.state == 'payment') {
                  print("STATE CHANGE TO PAYMENT");
                  isChanged = await model.changeState();
                }
                if (isChanged) {
                  // pushSuccessPage();
                  String url = await getParams();
                  print(url);
                  MaterialPageRoute payment = MaterialPageRoute(
                      builder: (context) => PayubizScreen(url));
                  Navigator.push(context, payment);
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

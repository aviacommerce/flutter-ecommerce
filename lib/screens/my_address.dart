import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/update_address.dart';
import 'package:scoped_model/scoped_model.dart';

class MyAddressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAddressPageState();
  }
}

class _MyAddressPageState extends State<MyAddressPage> {
  bool stateChanged = true;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
            title: Text('My Address'),
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
          ],
        )),
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
                  textFieldContainer(model.order.shipAddress['state']['name']),
                  textFieldContainer(
                      'Mobile: ' + ' - ' + model.order.shipAddress['phone']),
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

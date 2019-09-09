import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';

Widget orderDetailCard() {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return model.order == null
        ? Container()
        : Card(
            elevation: 3,
            margin: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    model.order.totalQuantity.toString() + ' items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(),
                amountRow('Sub Total', model.order.displaySubTotal, model),
                Divider(),
                amountRow('Delivery', model.order.shipTotal, model),
                Divider(),
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
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    ),
    Container(
      padding: EdgeInsets.all(10),
      child: Text(
        displayAmount == null ? '' : displayAmount,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    )
  ]);
}

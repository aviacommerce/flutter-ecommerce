import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/cart.dart';
import 'package:scoped_model/scoped_model.dart';

Widget shoppingCartIconButton() {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return new Padding(
      padding:
          const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 25, left: 10),
      child: new Container(
        height: 150.0,
        width: 30.0,
        child: new GestureDetector(
          onTap: () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Cart());

            Navigator.push(context, route);
          },
          child: new Stack(
            children: <Widget>[
              new IconButton(
                iconSize: 30,
                icon: new Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                onPressed: null,
              ),
              new Positioned(
                child: Container(
                  width: 21.0,
                  height: 21.0,
                  child: new Stack(
                    children: <Widget>[
                      new Icon(Icons.brightness_1,
                          size: 21.0, color: Colors.yellow),
                      new Center(
                        child: new Text(
                          model.order == null
                              ? '0'
                              : model.order.totalQuantity.toString(),
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}

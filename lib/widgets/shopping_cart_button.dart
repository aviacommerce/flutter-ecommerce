import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:ofypets_mobile_app/scoped-models/cart.dart';
import 'package:ofypets_mobile_app/screens/cart.dart';

Widget shoppingCartIconButton() {
  return ScopedModelDescendant<CartModel>(
      builder: (BuildContext context, Widget child, CartModel model) {
    return new Padding(
      padding: const EdgeInsets.all(10.0),
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
                icon: new Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                onPressed: null,
              ),
              new Positioned(
                child: new Stack(
                  children: <Widget>[
                    new Icon(Icons.brightness_1,
                        size: 20.0, color: Colors.orange),
                    new Positioned(
                        top: 3.0,
                        right: 4.0,
                        child: new Center(
                          child: new Text(
                            model.lineItems.length.toString(),
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}

import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/scoped-models/cart.dart';


class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CartState();
  }
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Shopping Cart'),
      ),
      body: items(),
    );
  }

  Widget items() {
    return ScopedModelDescendant<CartModel>(
      builder: (BuildContext context, Widget child, CartModel model) {
        model.lineItems.length;
        return ListView.builder(
          itemCount: model.lineItems.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == model.lineItems.length) {
              return FlatButton(
                onPressed: () {},
                child: Text('PROCEED TO CHECKOUT'),
              );
            } else {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              height: 150,
                              width: 150,
                              color: Colors.white,
                              child: FadeInImage(
                                image: NetworkImage(
                                    model.lineItems[index].variant.image),
                                placeholder: AssetImage(
                                    'images/placeholders/no-product-image.png'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              child: Text(
                                model.lineItems[index].variant.name,
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                model.lineItems[index].variant.displayPrice,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

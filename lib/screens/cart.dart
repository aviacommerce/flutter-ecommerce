import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/address.dart';
import 'package:ofypets_mobile_app/screens/auth.dart';

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CartState();
  }
}

class _CartState extends State<Cart> {
  List<int> quantities = [];
  bool stateChanged = true;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text('Shopping Cart'),
              bottom: model.isLoading
                  ? PreferredSize(
                      child: LinearProgressIndicator(),
                      preferredSize: Size.fromHeight(10),
                    )
                  : PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(10),
                    )),
          body: body(),
          bottomNavigationBar: proceedToCheckoutButton());
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget deleteButton(int index) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Text(model.lineItems[index].variant.quantity.toString());
    });
  }

  Widget body() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return CustomScrollView(
          slivers: <Widget>[
            items(),
            itemTotalContainer(model),
          ],
        );
      },
    );
  }

  Widget itemTotalContainer(MainModel model) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            model.order == null
                ? Container()
                : model.order.itemTotal != '0.0'
                    ? Text(
                        'SubTotal: ',
                        style: TextStyle(fontSize: 20, color: Colors.green),
                      )
                    : Container(),
            Container(
              child: Text(
                model.order == null
                    ? 'No Items in Cart'
                    : model.order.itemTotal != '0.0'
                        ? model.order.displaySubTotal
                        : 'No Items in Cart',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        )
      ]),
    );
  }

  Widget proceedToCheckoutButton() {
    MaterialPageRoute addressRoute =
        MaterialPageRoute(builder: (context) => AddressPage());

    MaterialPageRoute authRoute =
        MaterialPageRoute(builder: (context) => Authentication(0));

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.all(20),
        child: FlatButton(
          color: Colors.green,
          child: Text(
            model.order == null
                ? 'BROWSE ITEMS'
                : model.order.itemTotal == '0.0'
                    ? 'BROWSE ITEMS'
                    : 'PROCEED TO CHECKOUT',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          onPressed: () async {
            if (model.order != null) {
              if (model.order.itemTotal != '0.0') {
                if (model.isAuthenticated) {
                  if (model.order.state == 'cart') {
                    print('STATE IS CART, CHANGE');
                    bool _stateischanged = await model.changeState();
                    if (_stateischanged) {
                      if (model.order.state == 'address') {
                        print('DELIVERY, CHANGING STATE BEFORE GOING TO ADDRESS');
                        _stateischanged = await model.changeState();
                      }
                    }
                    setState(() {
                      stateChanged = _stateischanged;
                    });
                  }
                  if (stateChanged) {
                    // print('STATE IS CHANGED, FETCH CURRENT ORDER');
                    // model.fetchCurrentOrder();

                    Navigator.push(context, addressRoute);
                  }
                } else {
                  Navigator.push(context, authRoute);
                }
              } else {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              }
            } else {
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            }
          },
        ),
      );
    });
  }

  Widget items() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return GestureDetector(
                onTap: () {},
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    child: IconButton(
                                      color: Colors.grey,
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        model.removeProduct(
                                            model.lineItems[index].id);
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () {
                                        if (model.lineItems[index].quantity >=
                                            1) {
                                          model.addProduct(
                                            variantId: model
                                                .lineItems[index].variantId,
                                            quantity: -1,
                                          );
                                        }
                                      },
                                    ),
                                    Text(model.lineItems[index].quantity
                                        .toString()),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () {
                                        model.addProduct(
                                          variantId:
                                              model.lineItems[index].variantId,
                                          quantity: 1,
                                        );
                                      },
                                    ),
                                  ]),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ));
          }, childCount: model.lineItems.length),
        );
      },
    );
  }
}

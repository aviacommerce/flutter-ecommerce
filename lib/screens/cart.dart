import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/address.dart';
import 'package:ofypets_mobile_app/screens/auth.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';

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
          bottomNavigationBar: BottomAppBar(
              child: Container(
                  height: 136,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: itemTotalContainer(model),
                    ),
                    proceedToCheckoutButton(),
                  ]))));
    });
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
          ],
        );
      },
    );
  }

  Widget itemTotalContainer(MainModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        model.order == null
            ? Container()
            : model.order.itemTotal != '0.0'
                ? Text(
                    'SubTotal: (${model.order.totalQuantity} items):',
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
                fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget proceedToCheckoutButton() {
    MaterialPageRoute addressRoute =
        MaterialPageRoute(builder: (context) => AddressPage());

    MaterialPageRoute authRoute =
        MaterialPageRoute(builder: (context) => Authentication(0));

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 65.0,
          padding: EdgeInsets.all(10),
          child: FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            color: Colors.green,
            child: Text(
              model.order == null
                  ? 'BROWSE ITEMS'
                  : model.order.itemTotal == '0.0'
                      ? 'BROWSE ITEMS'
                      : 'PROCEED TO CHECKOUT',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
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
                          print(
                              'DELIVERY, CHANGING STATE BEFORE GOING TO ADDRESS');
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
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Container(
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {},
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0, top: 10.0),
                                        child: RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text:
                                                  '${model.lineItems[index].variant.name.split(' ')[0]} ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text: model
                                                  .lineItems[index].variant.name
                                                  .substring(
                                                      model.lineItems[index]
                                                              .variant.name
                                                              .split(' ')[0]
                                                              .length +
                                                          1,
                                                      model.lineItems[index]
                                                          .variant.name.length),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      color: Colors.grey,
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        model.removeProduct(
                                            model.lineItems[index].id);
                                      },
                                    ),
                                  ],
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

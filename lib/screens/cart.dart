import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/scoped-models/main.dart';

class Cart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CartState();
  }
}

class _CartState extends State<Cart> {
  List<int> quantities = [];
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
      );
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
            proceedToCheckoutButton()
          ],
        );
      },
    );
  }

  Widget itemTotalContainer(MainModel model) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              'SubTotal',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            Container(
              child: Text(
                model.order.displayTotal,
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
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        padding: EdgeInsets.all(20),
        child: FlatButton(
          color: Colors.green,
          child: Text(
            'PROCEED TO CHECKOUT',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          onPressed: () {
            
          },
        ),
      )
    ]));
  }

  Widget items() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                child: IconButton(
                                  icon: Icon(Icons.close),
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
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    if (model.lineItems[index].quantity >= 1) {
                                      model.addProduct(
                                        variantId:
                                            model.lineItems[index].variantId,
                                        quantity: -1,
                                      );
                                    }
                                  },
                                ),
                                Text(
                                    model.lineItems[index].quantity.toString()),
                                IconButton(
                                  icon: Icon(Icons.add),
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
            );
          }, childCount: model.lineItems.length),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/models/line_item.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/payment.dart';
import 'package:ofypets_mobile_app/screens/update_address.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/widgets/order_details_card.dart';
import 'package:scoped_model/scoped_model.dart';

class AddressPage extends StatefulWidget {
  List<LineItem> lineItems = [];
  AddressPage({this.lineItems});
  @override
  State<StatefulWidget> createState() {
    return _AddressPageState();
  }
}

class _AddressPageState extends State<AddressPage> {
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

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
              title: Text('Delivery Address'),
              bottom: model.isLoading
                  ? PreferredSize(
                      child: LinearProgressIndicator(),
                      preferredSize: Size.fromHeight(10),
                    )
                  : PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(10),
                    )),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  FlatButton(
                    child: Text(model.isLoading
                        ? ''
                        : model.order.shipAddress != null ? '' : 'ADD ADDRESS'),
                    onPressed: () {
                      MaterialPageRoute payment = MaterialPageRoute(
                          builder: (context) =>
                              UpdateAddress(model.order.shipAddress, true));
                      Navigator.push(context, payment);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 0.0),
                    child: Text(
                      'Shipping Address',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 16.0),
                    ),
                  ),
                  addressContainer(),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 15.0, bottom: 10.0),
                    child: Text(
                      'Order Summary',
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w100),
                    ),
                  ),
                  items(),
                  orderDetailCard(),
                  Divider(
                    indent: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'By placing this order, you agree to Ofypets.com’\s Privacy Policy and Terms of Use.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ]),
              ), //items(),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
              child: Container(
                  height: 100,
                  child: Column(children: [
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Order Total: ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Text(
                              '${model.order.displayTotal}',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            )
                          ],
                        )),
                    paymentButton(context),
                  ]))));
    });
  }

  Widget paymentButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          color: Colors.deepOrange,
          child: Text(
            model.order.shipAddress != null ? 'PLACE ORDER' : 'ADD ADDRESS',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.w300),
          ),
          onPressed: () {
            MaterialPageRoute address = MaterialPageRoute(
                builder: (context) =>
                    UpdateAddress(model.order.shipAddress, true));

            model.order.shipAddress != null
                ? pushPaymentScreen(model)
                : Navigator.push(context, address);
          },
        ),
      );
    });
  }

  Widget textFieldContainer(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
      ),
    );
  }

  pushPaymentScreen(MainModel model) async {
    if (model.order.state == 'delivery' || model.order.state == 'address') {
      // print('STATE IS DELIVERY/ADDRESS, CHANGE STATE');
      bool _stateischanged = await model.changeState();
      if (_stateischanged) {
        if (model.order.state == 'delivery') {
          _stateischanged = await model.changeState();
        }
      }
      setState(() {
        stateChanged = _stateischanged;
      });
    }
    if (stateChanged) {
      print('STATE IS CHANGED, FETCH CURRENT ORDER');
      model.fetchCurrentOrder();
      model.getPaymentMethods();
      MaterialPageRoute payment =
          MaterialPageRoute(builder: (context) => PaymentScreen());
      Navigator.push(context, payment);
    }
  }

  Widget addressContainer() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (model.order.shipAddress != null) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
            margin: EdgeInsets.all(15),
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        model.order.shipAddress.firstName +
                            ' ' +
                            model.order.shipAddress.lastName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      FlatButton(
                          onPressed: () {
                            MaterialPageRoute payment = MaterialPageRoute(
                                builder: (context) => UpdateAddress(
                                    model.order.shipAddress, true));
                            Navigator.push(context, payment);
                          },
                          child: Text(
                            'Edit',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 17.0),
                          )),
                    ],
                  ),
                  textFieldContainer(model.order.shipAddress.address1),
                  textFieldContainer(model.order.shipAddress.address2),
                  textFieldContainer(model.order.shipAddress.city +
                      ' - ' +
                      model.order.shipAddress.pincode),
                  textFieldContainer(model.order.shipAddress.state),
                  textFieldContainer(
                      'Mobile: ' + ' - ' + model.order.shipAddress.mobile),
                ],
              ),
            ),
          ),
        );
      } else
        return Container();
    });
  }

  Widget items() {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {},
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.all(4.0),
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
                                    widget.lineItems[index].variant.image),
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
                                                '${widget.lineItems[index].variant.name.split(' ')[0]} ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: widget
                                                .lineItems[index].variant.name
                                                .substring(
                                                    widget.lineItems[index]
                                                            .variant.name
                                                            .split(' ')[0]
                                                            .length +
                                                        1,
                                                    widget.lineItems[index]
                                                        .variant.name.length),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Container(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Qty: ${widget.lineItems[index].quantity.toString()}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 17),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(right: 12.0),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        widget.lineItems[index].variant
                                            .displayPrice,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ));
        },
        itemCount: widget.lineItems.length);
  }
}

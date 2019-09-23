import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/models/line_item.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/payment.dart';
import 'package:ofypets_mobile_app/screens/update_address.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/widgets/order_details_card.dart';
import 'package:ofypets_mobile_app/widgets/snackbar.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';

import 'package:scoped_model/scoped_model.dart';

class AddressPage extends StatefulWidget {
  AddressPage();
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddressPageState();
  }
  // @override
  // State<StatefulWidget> createState() {
  //   return _AddressPageState()
  //   // return _AddressPageState();
  // }
}

class _AddressPageState extends State<AddressPage> {
  bool stateChanged = true;
  String promocode;
  Size _deviceSize;
  String promoCodeResponseMsg = '';
  bool promoChecked = false;
  bool isPromoDiscount = false;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    setState(() {
      print("ORDER ADDRESS PAGE INIT-------");
      String adjustMentTotal =
          ScopedModel.of<MainModel>(context, rebuildOnChange: false)
              .order
              .adjustmentTotal;
      print(adjustMentTotal);
      promoChecked = isPromoDiscount = adjustMentTotal != '0.0';

      print(isPromoDiscount);
    });

    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              centerTitle: false,
              title: Text('Review Order'),
              bottom: model.isLoading
                  ? PreferredSize(
                      child: LinearProgressIndicator(),
                      preferredSize: Size.fromHeight(10),
                    )
                  : PreferredSize(
                      child: Container(),
                      preferredSize: Size.fromHeight(10),
                    )),
          body: Stack(children: [
            CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 35.0),
                      child: Text(
                        'Shipping Address',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w200,
                            fontSize: 16.0),
                      ),
                    ),
                    model.order.shipAddress == null
                        ? Container(
                            padding: EdgeInsets.only(top: 15),
                            height: 40,
                            margin: EdgeInsets.only(left: 40, right: 120),
                            child: FlatButton(
                              color: Colors.white,
                              child: Text(
                                model.isLoading
                                    ? ''
                                    : model.order.shipAddress != null
                                        ? ''
                                        : 'ADD NEW ADDRESS',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                MaterialPageRoute payment = MaterialPageRoute(
                                    builder: (context) => UpdateAddress(
                                        model.order.shipAddress, true));
                                Navigator.push(context, payment);
                              },
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 35,
                    ),
                    addressContainer(),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 0.0),
                      child: Text(
                        'Promotion',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w200,
                            fontSize: 16.0),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    promoCodeBox(model, context),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, top: 15.0, bottom: 10.0),
                      child: Text(
                        'Order Summary',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w100),
                      ),
                    ),
                    items(model.lineItems),
                    orderDetailCard(),
                    Divider(
                      indent: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        privacyPolicy,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    Container(
                      height: 150,
                    )
                  ]),
                ),
              ],
            ),
            Positioned(bottom: 0, child: bottomContainer(model))
          ]));
    });
  }

  Widget paymentButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 5.0),
        width: MediaQuery.of(context).size.width,
        child: model.isLoading
            ? Center(
                child: CircularProgressIndicator(backgroundColor: Colors.green))
            : FlatButton(
                disabledColor: Colors.grey.shade200,
                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                color: Colors.deepOrange,
                child: Text(
                  'PLACE ORDER',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                ),
                onPressed: model.order.shipAddress != null
                    ? () {
                        MaterialPageRoute address = MaterialPageRoute(
                            builder: (context) =>
                                UpdateAddress(model.order.shipAddress, true));

                        model.order.shipAddress != null
                            ? pushPaymentScreen(model)
                            : Navigator.push(context, address);
                      }
                    : null,
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
      bool fetched = await model.fetchCurrentOrder();
      bool paymentFetched = await model.getPaymentMethods();
      MaterialPageRoute payment =
          MaterialPageRoute(builder: (context) => PaymentScreen());
      Navigator.push(context, payment);
    }
  }

  Widget promoCodeBox(MainModel model, BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Card(
            child: _isLoading
                ? Padding(
                    padding: EdgeInsets.all(10),
                    child: CupertinoActivityIndicator())
                : !promoChecked || !isPromoDiscount
                    ? Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: _deviceSize.width * 0.60,
                              height: 70,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(bottom: 15, left: 10),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  initialValue: promocode,
                                  decoration: InputDecoration(
                                    labelText: 'Promo Code',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(0.0),
                                  ),
                                  onSaved: (String value) {
                                    setState(() {
                                      promocode = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            FlatButton(
                                child: Container(
                                  child: Text(
                                    'APPLY',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ),
                                onPressed: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());

                                  _formKey.currentState.save();
                                  if (promocode != '') {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    Map<String, dynamic> promocodeResponse =
                                        await model.promoCodeApplied(
                                            promocode: promocode);
                                    print("RESPONSE RECVD $promocodeResponse");
                                    if (promocodeResponse['successful']) {
                                      print(
                                          "RESPONSE ------> ${promocodeResponse['success'].toString()}");
                                      bool fetched =
                                          await model.fetchCurrentOrder();
                                      print(
                                          "ADJUSTMENTTOTAL ${model.order.displayAdjustmentTotal}");
                                      setState(() {
                                        _isLoading = false;
                                        promoChecked = true;
                                        isPromoDiscount = true;
                                        promoCodeResponseMsg =
                                            promocodeResponse['success'];
                                      });
                                    } else {
                                      print(
                                          "RESPONSE ------> ${promocodeResponse['error']}");
                                      setState(() {
                                        _isLoading = false;
                                        promoChecked = true;
                                        isPromoDiscount = false;
                                        promoCodeResponseMsg =
                                            promocodeResponse['error'];
                                      });
                                      _scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        content:
                                            Text(promocodeResponse['error']),
                                        duration: Duration(seconds: 3),
                                      ));
                                    }
                                  } else {
                                    _scaffoldKey.currentState
                                        .showSnackBar(promoEmpty);
                                  }
                                }),
                          ],
                        ),
                      ])
                    : Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  left: 10, bottom: 15, top: 15, right: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                promoCodeText(model).toUpperCase(),
                                style: TextStyle(
                                    color: Colors.green, fontSize: 17),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'The coupon code was successfully applied to your order. You will save ${model.order.displayAdjustmentTotal.toString().substring(1)}.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        GestureDetector(
                            onTap: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              Map<String, dynamic> promocodeResponse =
                                  await model.promoCodeRemoved(
                                      promocode: promoCodeText(model));
                              if (promocodeResponse['successful']) {
                                bool fetched = await model.fetchCurrentOrder();
                                print(model.order.displayAdjustmentTotal);
                                setState(() {
                                  promoChecked = false;
                                  isPromoDiscount = false;
                                  _isLoading = false;
                                });
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 10, bottom: 10),
                              child: Text(
                                'Remove',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                      ])));
  }

  String promoCodeText(MainModel model) {
    String codeName = '';
    model.order.adjustments.forEach((adjustmentObj) {
      String adjustmentString = adjustmentObj['label'].toString();
      if (adjustmentString.contains('Promotion')) {
        final match = RegExp(r'\(([^)]+)\)').firstMatch(adjustmentString);
        codeName = match.group(1);
      }
    });
    return codeName;
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
                      Flexible(
                        child: Text(
                          model.order.shipAddress.firstName +
                              ' ' +
                              model.order.shipAddress.lastName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FlatButton(
                          onPressed: () {
                            MaterialPageRoute payment = MaterialPageRoute(
                                builder: (context) => UpdateAddress(
                                    model.order.shipAddress, true));
                            Navigator.push(context, payment);
                          },
                          child: Text(
                            'EDIT',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  textFieldContainer(model.order.shipAddress.address1),
                  textFieldContainer(model.order.shipAddress.address2),
                  textFieldContainer(model.order.shipAddress.city +
                      ' - ' +
                      model.order.shipAddress.pincode),
                  textFieldContainer(model.order.shipAddress.stateName),
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

  Widget bottomContainer(MainModel model) {
    return BottomAppBar(
        child: Container(
            height: 90,
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
                            color: Colors.grey.shade600,
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
            ])));
  }

  Widget items(List<LineItem> lineItems) {
    return ListView.builder(
      itemCount: lineItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(5),
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
                              margin: EdgeInsets.all(14),
                              padding: EdgeInsets.all(10),
                              height: 80,
                              width: 80,
                              color: Colors.white,
                              child: FadeInImage(
                                image: NetworkImage(
                                    lineItems[index].variant.image != null
                                        ? lineItems[index].variant.image
                                        : ''),
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
                              SizedBox(
                                height: 15,
                              ),
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
                                                  '${lineItems[index].variant.name.split(' ')[0]} ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text: lineItems[index]
                                                  .variant
                                                  .name
                                                  .substring(
                                                      lineItems[index]
                                                              .variant
                                                              .name
                                                              .split(' ')[0]
                                                              .length +
                                                          1,
                                                      lineItems[index]
                                                          .variant
                                                          .name
                                                          .length),
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
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'Qty: ${lineItems[index].quantity.toString()}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w200,
                                            fontSize: 14),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(right: 24.0),
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          lineItems[index].variant.displayPrice,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        )
                      ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

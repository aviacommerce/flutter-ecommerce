import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/update_address.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
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
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
            actions: <Widget>[
              model.shipAddress != null
                  ? FlatButton(
                      child: Text(
                        'EDIT',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        MaterialPageRoute payment = MaterialPageRoute(
                            builder: (context) =>
                                UpdateAddress(model.shipAddress, false));
                        Navigator.push(context, payment);
                      },
                    )
                  : Container()
            ],
            title: Text('Addresses'),
            centerTitle: false,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
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
            child: model.shipAddress == null
                ? noAddressPage()
                : Column(
                    children: <Widget>[
                      // FlatButton(
                      //   child: Text(model.shipAddress != null
                      //       ? 'EDIT ADDRESS'
                      //       : 'ADD ADDRESS'),
                      //   onPressed: () {
                      //     MaterialPageRoute payment = MaterialPageRoute(
                      //         builder: (context) =>
                      //             UpdateAddress(model.shipAddress, false));
                      //     Navigator.push(context, payment);
                      //   },
                      // ),
                      model.shipAddress != null
                          ? addressContainer()
                          : Container(),
                    ],
                  )),
        floatingActionButton: model.shipAddress == null
            ? FloatingActionButton(
                onPressed: () {
                  MaterialPageRoute payment = MaterialPageRoute(
                      builder: (context) =>
                          UpdateAddress(model.shipAddress, false));
                  Navigator.push(context, payment);
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: Colors.deepOrange,
              )
            : Container(),
      );
    });
  }

  Widget textFieldContainer(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w100
        ),
      ),
    );
  }

  Widget addressContainer() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (model.shipAddress != null) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                      size: 20.0,
                      color: Colors.grey,
                    ),
                    Center(
                        child: Container(
                      width: 18,
                      height: 3,
                      color: Colors.grey,
                    ))
                  ],
                ),
              ),
              SizedBox(
                width: 25,
              ),
              Expanded(
                  child: Container(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        model.shipAddress.firstName +
                            ' ' +
                            model.shipAddress.lastName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10,),
                      textFieldContainer(model.shipAddress.address1),
                      textFieldContainer(model.shipAddress.address2),
                      textFieldContainer(model.shipAddress.city +
                          ' - ' +
                          model.shipAddress.pincode),
                      textFieldContainer(model.shipAddress.stateName),
                    ],
                  ),
                ),
              ))
            ],
          ),
        );
      } else
        return Container();
    });
  }

  Widget noAddressPage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 220.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.location_on,
                  size: 80.0,
                  color: Colors.grey,
                ),
                Center(
                  child: Container(
                    width: 60,
                    height: 8,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 35.0,
                ),
                Text(
                  'No Saved Addresses',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 35.0, vertical: 5),
                  child: Text(
                    'Let us know where to ship all of your Ofypets goodies.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

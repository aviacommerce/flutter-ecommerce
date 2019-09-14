import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateAddress extends StatefulWidget {
  final bool order;
  final dynamic shipAddress;
  UpdateAddress(this.shipAddress, this.order);
  @override
  State<StatefulWidget> createState() {
    return _UpdateAddressState();
  }
}

class _UpdateAddressState extends State<UpdateAddress> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _firstName = '';
  String _lastName = '';
  String selectedState = '';
  String _address1 = '';
  String _address2 = '';
  String _city = '';
  String _mobile = '';
  String _pincode = '';
  int _stateId;
  Map<String, dynamic> data = Map();
  Map<String, dynamic> address = Map();
  Map<String, String> headers = Map();
  String url = '';
  static List<Map<String, dynamic>> states = [];
  @override
  void initState() {
    getStates();
    // getUserInfo();
    super.initState();
    if (widget.shipAddress != null) {
      selectedState = widget.shipAddress.state;
      _firstName = widget.shipAddress.firstName;
      _lastName = widget.shipAddress.lastName;
      _address2 = widget.shipAddress.address2;
      _city = widget.shipAddress.city;
      _address1 = widget.shipAddress.address1;
      _mobile = widget.shipAddress.mobile;
      _pincode = widget.shipAddress.pincode;
      _stateId = widget.shipAddress.stateId;
    }
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
            title: Text(
                widget.shipAddress != null ? 'Update Address' : 'Add Address'),
            bottom: _isLoading
                ? PreferredSize(
                    child: LinearProgressIndicator(),
                    preferredSize: Size.fromHeight(10),
                  )
                : PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(10),
                  ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  submitAddress(model);
                },
              )
            ],
          ),
          body: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  buildFirstNameField('First Name *'),
                  buildLastNameField('Last Name *'),
                  buildPinCodeField('Pincode *'),
                  buildTownField('Locality/Town *'),
                  buildCityField('City/District *'),
                  buildStateField('State *'),
                  buildAddressField('Address *'),
                  buildMobileField('Mobile No. *'),
                  SizedBox(height: 20),
                  sendButton(),
                  SizedBox(
                    height: 250,
                  )
                ],
              ),
            ),
          ));
    });
  }

  Widget buildFirstNameField(String label) {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'First Name is required';
        }
      },
      initialValue: _firstName,
      decoration: InputDecoration(
        labelText: label,
      ),
      onSaved: (String value) {
        print("SETTING FIRST NAME-----> $value");
        setState(() {
          _firstName = value;
        });
      },
    );
  }

  Widget buildLastNameField(String label) {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'Last Name is required';
        }
      },
      decoration: InputDecoration(
        labelText: label,
      ),
      initialValue: _lastName,
      onSaved: (String value) {
        print("SETTING LAST NAME ------> $value");
        setState(() {
          _lastName = value;
        });
      },
    );
  }

  Widget buildAddressField(String label) {
    return TextFormField(
      maxLines: 5,
      initialValue: _address1,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Address is required';
        }
      },
      decoration: InputDecoration(
        labelText: label,
      ),
      onSaved: (String value) {
        setState(() {
          _address1 = value;
        });
      },
    );
  }

  Widget buildTownField(String label) {
    return TextFormField(
      initialValue: _address2,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Locality/Town is required';
        }
      },
      decoration: InputDecoration(
        labelText: label,
      ),
      onSaved: (String value) {
        setState(() {
          _address2 = value;
        });
      },
    );
  }

  Widget buildCityField(String label) {
    return TextFormField(
      initialValue: _city,
      validator: (String value) {
        if (value.isEmpty) {
          return 'City is required';
        }
      },
      decoration: InputDecoration(
        labelText: label,
      ),
      onSaved: (String value) {
        setState(() {
          _city = value;
        });
      },
    );
  }

  Widget buildStateField(String label) {
    List<CupertinoActionSheetAction> actions = states.map((item) {
      return CupertinoActionSheetAction(
        child: Text(
          item['name'],
          style: TextStyle(color: Colors.grey),
        ),
        onPressed: () {
          Navigator.pop(context, item['name']);
        },
      );
    }).toList();
    return GestureDetector(
        onTap: () {
          containerForSheet<String>(
            context: context,
            child: CupertinoActionSheet(
              title: const Text('Select State'),
              actions: actions,
            ),
          );
        },
        child: Container(
            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            'Select State *',
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 16),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          child: IconButton(
                            onPressed: () {
                              containerForSheet<String>(
                                context: context,
                                child: CupertinoActionSheet(
                                  title: const Text('Select State'),
                                  actions: actions,
                                ),
                              );
                            },
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 30,
                          ))
                    ],
                  ),
                  Container(
                    child: Text(
                      selectedState,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 40,
                  )
                ])));
  }

  Widget buildMobileField(String label) {
    return TextFormField(
      initialValue: _mobile,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Mobile No. is required!';
        } else if (!RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Please enter numeric value only';
        } else if (value.trim().length != 10) {
          return 'Pincode should be 10 digits only!';
        }
      },
      decoration: InputDecoration(
        labelText: label,
      ),
      onSaved: (String value) {
        setState(() {
          _mobile = value;
        });
      },
    );
  }

  Widget buildPinCodeField(String label) {
    return TextFormField(
      initialValue: _pincode,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Pincode is required!';
        } else if (!RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Please enter numeric value only';
        } else if (value.trim().length != 6) {
          return 'Pincode should be 6 digits only!';
        }
      },
      decoration: InputDecoration(labelText: label),
      onSaved: (String value) {
        setState(() {
          _pincode = value;
        });
      },
    );
  }

  getStates() async {
    Map<String, dynamic> statesResponse;
    http.Response response =
        await http.get(Settings.SERVER_URL + 'api/v1/countries/105/states');

    statesResponse = json.decode(response.body);
    statesResponse['states'].forEach((state) {
      setState(() {
        states.add(state);
      });
    });
    if (widget.shipAddress == null) {
      setState(() {
        selectedState = states.first['name'];
      });
    }
  }

  void containerForSheet<Map>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<Map>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((Map value) {
      setState(() {
        if (value == null) {
          selectedState = '';
        } else {
          selectedState = value.toString();
          states.forEach((state) {
            if (state.containsValue(value.toString())) {
              _stateId = state['id'];
            }
          });
        }
      });
    });
  }

  submitAddress(MainModel model) async {
    Map<dynamic, dynamic> updateResponse;
    Map<dynamic, dynamic> orderUpdateResponse;

    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    // getUserInfo();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    headers = {
      'Content-Type': 'application/json',
      'token-type': 'Bearer',
      'ng-api': 'true',
      'auth-token': prefs.getString('spreeApiKey'),
      'Guest-Order-Token': prefs.getString('orderToken')
    };
    address = {
      "firstname": _firstName,
      "lastname": _lastName,
      "address2": _address2,
      "city": _city,
      "address1": _address1,
      "phone": _mobile,
      "zipcode": _pincode,
      "state_name": selectedState,
      "state_id": _stateId,
      "country_id": '105'
    };

    print("FIRST NAME BEING SENT ---> $_firstName");
    print("LAST NAME BEING SENT ---> $_lastName");

    String profileAddressUrl = "address/update_address";
    Map<String, dynamic> profileAddressData = {
      "user": {"email": prefs.getString('email'), "ship_address": address}
    };

    if (!widget.order && widget.shipAddress == null) {
      url = "address/create_address";
      http.Response response = await http.post(Settings.SERVER_URL + url,
          headers: headers, body: json.encode(profileAddressData));
      updateResponse = json.decode(response.body);
      if (updateResponse['status'] == 'Address added Successfully!') {
        await model.fetchCurrentOrder();
        await model.getAddress();
        // Navigator.pop(context);
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog(context);
      }
    } else {
      if (widget.order) {
        if (widget.shipAddress != null) {
          url =
              'api/v1/orders/${prefs.getString('orderNumber')}/addresses/${widget.shipAddress.id}';
          data = {"address_params": address};
        } else {
          url =
              'api/v1/checkouts/${prefs.getString('orderNumber')}.json?order_token=${prefs.getString('orderToken')}';
          data = {
            "order": {
              "bill_address_attributes": address,
              "ship_address_attributes": address
            }
          };
        }
      }

      if (widget.order) {
        http.Response response = await http.put(Settings.SERVER_URL + url,
            headers: headers, body: json.encode(data));
        orderUpdateResponse = json.decode(response.body);
        updateResponse = json.decode(response.body);
        if (updateResponse.containsKey('id')) {
          await model.fetchCurrentOrder();
        }
      }
      http.Response response = await http.post(
          Settings.SERVER_URL + profileAddressUrl,
          headers: headers,
          body: json.encode(profileAddressData));
      updateResponse = json.decode(response.body);
      if (updateResponse['status'] == 'Address updated Successfully!') {
        await model.fetchCurrentOrder();
        await model.getAddress();
        // Navigator.pop(context);
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog(context);
      }
    }
  }

  Widget sendButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return FlatButton(
        color: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onPressed: () {
          submitAddress(model);
        },
        child: Text(
          'SAVE ADDRESS',
          style: TextStyle(color: Colors.white),
        ),
      );
    });
  }

  void _showSuccessDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ScopedModelDescendant<MainModel>(
              builder: (BuildContext context, Widget child, MainModel model) {
            return AlertDialog(
              title: Text("Address Update"),
              content: new Text("Address updated successfully."),
              actions: <Widget>[
                new FlatButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }
}

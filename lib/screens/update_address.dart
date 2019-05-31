import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';

class UpdateAddress extends StatefulWidget {
  Map<String, dynamic> shipAddress;
  UpdateAddress(this.shipAddress);
  @override
  State<StatefulWidget> createState() {
    return _UpdateAddressState();
  }
}

class _UpdateAddressState extends State<UpdateAddress> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _firstName;
  String _lastName;
  String selectedState = '';
  String _address1 = '';
  String _address2 = '';
  String _city = '';
  String _mobile = '';
  String _pincode = '';
  int _stateId;
  Map<String, dynamic> data = Map();
  Map<String, String> headers = Map();

  static List<Map<String, dynamic>> states = [];
  @override
  void initState() {
    getStates();
    // getUserInfo();
    super.initState();
    selectedState = widget.shipAddress['state']['name'];
    _firstName = widget.shipAddress['firstname'];
    _lastName = widget.shipAddress['lastname'];
    _address2 = widget.shipAddress['address2'];
    _city = widget.shipAddress['city'];
    _address1 = widget.shipAddress['address1'];
    _mobile = widget.shipAddress['phone'];
    _pincode = widget.shipAddress['zipcode'];
    _stateId = widget.shipAddress['state_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Update Address'),
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
              ],
            ),
          ),
        ));
  }

  Widget buildFirstNameField(String label) {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty) {
          return 'First Name is required';
        }
      },
      initialValue: widget.shipAddress['firstname'],
      decoration: InputDecoration(
        labelText: label,
      ),
      onSaved: (String value) {
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
      initialValue: widget.shipAddress['lastname'],
      onSaved: (String value) {
        setState(() {
          _lastName = value;
        });
      },
    );
  }

  Widget buildAddressField(String label) {
    return TextFormField(
      maxLines: 5,
      initialValue: widget.shipAddress['address1'],
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
      initialValue: widget.shipAddress['address2'],
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
      initialValue: widget.shipAddress['city'],
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
      initialValue: widget.shipAddress['phone'],
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
      initialValue: widget.shipAddress['zipcode'],
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
        // selectedState = states.first['name'];
      });
    });
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
            print(state);
            if (state.containsValue(value.toString())) {
              _stateId = state['id'];
            }
          });
        }
      });
    });
  }

  Widget sendButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return FlatButton(
        color: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onPressed: () async {
          Map<dynamic, dynamic> updateResponse;
          if (!_formKey.currentState.validate()) {
            return;
          }
          _formKey.currentState.save();

          // getUserInfo();
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          headers = {
            'Content-Type': 'application/json',
            'token-type': 'Bearer',
            'ng-api': 'true',
            'auth-token': prefs.getString('spreeApiKey'),
            'Guest-Order-Token': prefs.getString('orderToken')
          };
          data = {
            "address_params": {
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
            }
          };

          print('DATA-------------------------');
          print(data);

          http.Response response = await http.put(
              Settings.SERVER_URL +
                  'api/v1/orders/${prefs.getString('orderNumber')}/addresses/${widget.shipAddress['id']}',
              headers: headers,
              body: json.encode(data));
          updateResponse = json.decode(response.body);

          if (updateResponse.containsKey('id')) {
            print(updateResponse);
            // model.shipAddress = data;
            await model.fetchCurrentOrder();
            Navigator.pop(context);
          }
        },
        child: Text(
          'SAVE ADDRESS',
          style: TextStyle(color: Colors.white),
        ),
      );
    });
  }
}

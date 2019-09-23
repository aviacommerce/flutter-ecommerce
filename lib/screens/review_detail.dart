import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/models/review.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewDetailScreen extends StatefulWidget {
  final Product product;

  ReviewDetailScreen(this.product);

  @override
  State<StatefulWidget> createState() {
    return _ReviewDetailScreenState(product);
  }
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen>
    with SingleTickerProviderStateMixin {
  Product product;

  _ReviewDetailScreenState(this.product);

  int _rating;
  final _title = TextEditingController();
  final _review = TextEditingController();
  bool _validate = false;
  String RECORD_URL;
  Review review;
  final _formKey = GlobalKey<FormState>();

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
    return new Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text('Write Review'),
            centerTitle: true),
        body: new SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                padding: EdgeInsets.all(10),
                child: new Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    FadeInImage(
                                      image: NetworkImage(product.image != null
                                          ? product.image
                                          : ''),
                                      placeholder: AssetImage(
                                          'images/placeholders/no-product-image.png'),
                                      width: 100,
                                      height: 100,
                                    ),
                                  ],
                                )),
                            Expanded(
                              flex: 2,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 3,
                                    ),
                                  ]),
                            )
                          ]),
                      new SizedBox(height: 20),
                      new Row(children: <Widget>[
                        new Container(
                          child: new Text(
                            'Rating',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                      new SizedBox(height: 20),
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            child: new Text(
                              'Select one',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                  fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: FlutterRatingBar(
                              itemCount: 5,
                              fillColor: Colors.orange,
                              borderColor: Colors.orange,
                              itemSize: 40,
                              onRatingUpdate: (index) {
                                setState(() {
                                  _rating = index.toInt();
                                  //   print(_rating);
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      new SizedBox(height: 10),
                      new ConstrainedBox(
                          constraints: BoxConstraints(
                              //maxHeight: 60.0
                              ),
                          child: new TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter Title';
                              } else if (value.length > 80) {
                                return 'Title cannot be greater than 80 characters.';
                              }
                              return null;
                            },
                            maxLength: 80,
                            maxLines: null,
                            maxLengthEnforced: false,
                            keyboardType: TextInputType.multiline,
                            controller: _title,
                            decoration: new InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14.0,
                              ),
                            ),
                          )),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            //maxHeight: 60.0
                            ),
                        child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter Review';
                              } else if (value.length > 1000) {
                                return "Review can't be greater than 1000 characters.";
                              }
                              return null;
                            },
                            maxLength: 1000,
                            controller: _review,
                            maxLines: null,
                            maxLengthEnforced: false,
                            keyboardType: TextInputType.multiline,
                            decoration: new InputDecoration(
                                labelText: 'Review',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14.0,
                                ))),
                      ),
                      new SizedBox(
                        height: 10,
                      ),
                      new Container(
                        child: new RaisedButton(
                          color: Colors.green,
                          onPressed: () {
                            _submit(context);
                          },
                          child: Text(
                            "Submit Review",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      new SizedBox(height: 300),
                    ],
                  ),
                ))));
  }

  Future _submit(BuildContext con) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_id = prefs.getInt('id').toString();

    String email = prefs.getString('email');
    if (_formKey.currentState.validate()) {
      ShowResponseDialog(context, "Submitting..");

      Map<String, dynamic> toJson() => {
            "name": email,
            "rating": _rating.toString(),
            "title": _title.text,
            "review": _review.text,
            "user_id": user_id,
            // "user_id": int.parse("1255") ,
          };
      SubmitReview(context, toJson(), product.reviewProductId);
    }
  }

  Future<void> ShowInfoDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.info,
                  size: 20,
                ),
                SizedBox(
                  width: 7,
                ),
                Flexible(
                  child: Text(
                    message,
                    style: new TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Ok",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> SubmitReview(
      BuildContext c, Map<String, dynamic> map, int id) async {
    Map<String, dynamic> m = {"review": map};

    RECORD_URL = Settings.SERVER_URL + "products/$id/reviews";
    print(Settings.SERVER_URL + "products/$id/reviews");
    Map<String, String> headers = await getHeaders();
    String j = json.encode(m);
    return await http
        .post(RECORD_URL, headers: headers, body: j)
        .then((http.Response response) {
      print(response.body);
      final int statusCode = response.statusCode;

      Map<String, dynamic> data = json.decode(response.body);

      Navigator.pop(context);

      ShowInfoDialog(context, data["message"]).then((myPost) {
        try {
          Navigator.pop(context);
          //setState(() {});
        } catch (e) {
          print(e);
        }
      }).catchError((error) {
        print('error : $error');
      });

      return response;
    });
  }
}

void ShowResponseDialog(BuildContext context, String msg) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.0))),
            content: Container(
              height: 30,
              color: Colors.transparent,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15),
                  CupertinoActivityIndicator(
                    radius: 8,
                  ),
                  SizedBox(width: 20),
                  Text(msg)
                ],
              ),
            ),
          ));
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';

import 'package:ofypets_mobile_app/screens/auth.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget productContainer(BuildContext myContext, Product product, int index) {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return GestureDetector(
        onTap: () {
          model.getProductDetail(product.slug, myContext);
        },
        child: Card(
          margin: EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 150,
                    color: Colors.white,
                    child: FadeInImage(
                      image: NetworkImage(product.image),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0, top: 10.0),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '${product.name.split(' ')[0]}\n',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: product.name.substring(
                                product.name.split(' ')[0].length + 1,
                                product.name.length),
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            product.displayPrice,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.topRight,
                          icon: Icon(Icons.favorite),
                          color: Colors.orange,
                          onPressed: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String authToken = prefs.getString('spreeApiKey');

                            if (authToken == null) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  'Please Login to add to Favorites',
                                ),
                                action: SnackBarAction(
                                  label: 'LOGIN',
                                  onPressed: () {
                                    MaterialPageRoute route = MaterialPageRoute(
                                        builder: (context) =>
                                            Authentication(0));
                                    Navigator.push(context, route);
                                  },
                                ),
                                duration: Duration(seconds: 3),
                              ));
                            } else {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  'Adding to Favorites, please wait.',
                                ),
                                duration: Duration(seconds: 1),
                              ));
                              Map<String, String> headers = await getHeaders();
                              http
                                  .post(
                                      Settings.SERVER_URL + 'favorite_products',
                                      body: json.encode({
                                        'id': product.reviewProductId.toString()
                                      }),
                                      headers: headers)
                                  .then((response) {
                                Map<dynamic, dynamic> responseBody =
                                    json.decode(response.body);

                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(responseBody['message']),
                                  duration: Duration(seconds: 1),
                                ));
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ratingBar(product.avgRating, 20),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(product.reviewsCount),
                      ],
                    ),
                    Container(
                        padding:
                            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0),
                        alignment: Alignment.topLeft,
                        child: Text(
                          'More Options Available',
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 14),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ));
  });
}

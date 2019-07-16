import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/screens/product_detail.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/screens/auth.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

Widget productContainer(BuildContext context, Product product, _) {
  return GestureDetector(
      onTap: () {
        MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product));
        Navigator.push(context, route);
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
                  Container(
                      padding: EdgeInsets.all(10),
                      width: 150,
                      alignment: Alignment.center,
                      child: Text(
                        'MORE OPTIONS AVAILABLE',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 12),
                        textAlign: TextAlign.center,
                      ))
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
                    child: Text(
                      product.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 15),
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
                                      builder: (context) => Authentication(0));
                                  Navigator.push(context, route);
                                },
                              ),
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
                                .post(Settings.SERVER_URL + 'favorite_products',
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
                      Text(product.reviewsCount),
                    ],
                  ),
                ],
              )),
            ],
          )));
}

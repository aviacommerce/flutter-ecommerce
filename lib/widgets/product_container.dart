import 'package:flutter/material.dart';

import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/screens/product_detail.dart';

Widget productContainer(Product product, BuildContext context) {
  return Container(
      color: Colors.white,
      child: GestureDetector(
          onTap: () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => ProductDetailScreen(product));
            Navigator.push(context, route);
          },
          child: Row(
            children: <Widget>[
              Stack(
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
                    height: 150,
                    width: 150,
                    alignment: Alignment.topRight,
                    child: IconButton(
                      alignment: Alignment.topRight,
                      icon: Icon(Icons.favorite_border),
                      color: Colors.orange,
                      onPressed: () {},
                    ),
                  )
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

import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/screens/product_detail.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/widgets/todays_deals_card.dart';

Widget similarProductCard(int index, List<Product> todaysDealProducts,
    Size _deviceSize, BuildContext context) {
  Product displayProduct = todaysDealProducts[index].hasVariants
      ? todaysDealProducts[index].variants.first
      : todaysDealProducts[index];
  return GestureDetector(
      onTap: () {
        MaterialPageRoute addressRoute = MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(todaysDealProducts[index]));
        Navigator.pushReplacement(context, addressRoute);
      },
      child: SizedBox(
          width: _deviceSize.width * 0.4,
          child: Card(
            borderOnForeground: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FadeInImage(
                  image: NetworkImage(displayProduct.image),
                  placeholder:
                      AssetImage('images/placeholders/no-product-image.png'),
                  // height: _deviceSize.height * 0.2,
                  height: 100,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Text(
                    displayProduct.name,
                    maxLines: 3,
                  ),
                ),
                Text(
                  displayProduct.displayPrice,
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ratingBar(displayProduct.avgRating, 20),
                    Text(displayProduct.reviewsCount),
                  ],
                ),
                Divider(),
                AddToCart(displayProduct, index, todaysDealProducts),
              ],
            ),
          )));
}

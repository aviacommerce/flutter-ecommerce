import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/cart.dart';

Widget addToCartButton(List<Product> todaysDealProducts, int index) {
  return ScopedModelDescendant<CartModel>(
      builder: (BuildContext context, Widget child, CartModel model) {
    return FlatButton(
      onPressed: () {
        if (todaysDealProducts[index].isOrderable) {
          model.addProduct();
        }
      },
      child: Text(
        todaysDealProducts[index].isOrderable ? 'ADD TO CART' : 'OUT OF STOCK',
        style: TextStyle(
            color: todaysDealProducts[index].isOrderable
                ? Colors.green
                : Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    );
  });
}

Widget todaysDealsCard(
    int index, List<Product> todaysDealProducts, Size _deviceSize) {
  return SizedBox(
      width: _deviceSize.width * 0.4,
      child: Card(
        borderOnForeground: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FadeInImage(
              image: NetworkImage(todaysDealProducts[index].image),
              placeholder:
                  AssetImage('images/placeholders/no-product-image.png'),
              height: _deviceSize.height * 0.2,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Text(
                todaysDealProducts[index].name,
                maxLines: 3,
              ),
            ),
            Text(
              todaysDealProducts[index].displayPrice,
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ratingBar(todaysDealProducts[index].avgRating, 20),
                Text(todaysDealProducts[index].reviewsCount),
              ],
            ),
            Divider(),
            addToCartButton(todaysDealProducts, index)
          ],
        ),
      ));
}

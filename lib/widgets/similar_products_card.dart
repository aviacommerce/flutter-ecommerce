import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/widgets/todays_deals_card.dart';
import 'package:scoped_model/scoped_model.dart';

Widget similarProductCard(int index, List<Product> todaysDealProducts,
    Size _deviceSize, BuildContext context,
    [bool isSimilarListing = false]) {
  Product displayProduct = todaysDealProducts[index].hasVariants
      ? todaysDealProducts[index].variants.first
      : todaysDealProducts[index];
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return GestureDetector(
        onTap: () {
          model.getProductDetail(todaysDealProducts[index].slug, context, true);
          // MaterialPageRoute addressRoute = MaterialPageRoute(
          //     builder: (context) =>
          //         ProductDetailScreen(todaysDealProducts[index]));
          // Navigator.push(context, addressRoute);
        },
        child: SizedBox(
            width: _deviceSize.width * 0.4,
            child: Card(
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(4.0)),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FadeInImage(
                      image: NetworkImage(displayProduct.image),
                      placeholder: AssetImage(
                          'images/placeholders/no-product-image.png'),
                      // height: _deviceSize.height * 0.2,
                      height: 100,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60.0,
                    padding: EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Text(
                      displayProduct.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        displayProduct.displayPrice,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, top: 20.0, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ratingBar(displayProduct.avgRating, 20),
                        Text(displayProduct.reviewsCount),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  AddToCart(displayProduct, index, todaysDealProducts),
                  // addToCartButton(todaysDealProducts, index, displayProduct)
                ],
              ),
            )));
  });
}

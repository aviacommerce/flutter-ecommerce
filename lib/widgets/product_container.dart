import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:scoped_model/scoped_model.dart';

Widget productContainer(BuildContext myContext, Product product, int index) {
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return GestureDetector(
        onTap: () {
          model.getProductDetail(product.slug, myContext);
        },
        child: Container(
          padding: EdgeInsets.only(top: 15.0),
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: 150,
                        color: Colors.white,
                        child: FadeInImage(
                          image: NetworkImage(
                              product.image != null ? product.image : ''),
                          placeholder: AssetImage(
                              'images/placeholders/no-product-image.png'),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      width: 150,
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      alignment: Alignment.center,
                      child: Text(
                        'More Choices\nAvailable',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0, top: 0.0),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '${product.name.split(' ')[0]} ',
                            style: TextStyle(
                                color: Color(0xff676767),
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: product.name.substring(
                                product.name.split(' ')[0].length + 1,
                                product.name.length),
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w400),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        product.costPrice != null && product.costPrice != ''
                            ? discountPrice(product)
                            : Container(),
                      ],
                    ),
                    SizedBox(height: 7),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0, top: 0.0),
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'FREE 1-2 Day ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: double.parse(product.price) < 699
                                  ? 'shipping over Rs.699'
                                  : 'shipping',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
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
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      // indent: 150.0,
                      color: Colors.grey.shade400,
                      height: 1.0,
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  });
}

Widget discountPrice(Product product) {
  if (double.parse(product.costPrice) - double.parse(product.price) > 0) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      alignment: Alignment.topLeft,
      child: Text(
        product.currencySymbol + product.costPrice,
        textAlign: TextAlign.left,
        style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  } else {
    return Container();
  }
}

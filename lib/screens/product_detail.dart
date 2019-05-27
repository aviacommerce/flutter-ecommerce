import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';

import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/models/review.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/cart.dart';
import 'package:ofypets_mobile_app/widgets/shopping_cart_button.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  ProductDetailScreen(this.product);
  @override
  State<StatefulWidget> createState() {
    return _ProductDetailScreenState();
  }
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Size _deviceSize;
  int quantity = 1;
  Product selectedProduct;
  bool _hasVariants = false;
  List<Review> reviews = [];
  int total_reviews = 0;
  double recommended_percent = 0;
  double avg_rating = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    if (widget.product.hasVariants) {
      _hasVariants = widget.product.hasVariants;
      selectedProduct = widget.product.variants.first;
    } else {
      selectedProduct = widget.product;
    }
    get_reviews();
    super.initState();
  }

  get_reviews() {
    Map<dynamic, dynamic> responseBody;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'token-type': 'Bearer',
      'ng-api': 'true',
    };
    reviews = [];
    String url = Settings.SERVER_URL +
        "products/${selectedProduct.review_product_id}/reviews";
    http.get(url, headers: headers).then((response) {
      responseBody = json.decode(response.body);
      double total = 0;
      double total_given_rating = 0;
      responseBody['rating_summery'].forEach((rating) {
        if (rating['percentage'] != null) {
          total += rating["percentage"];
        }
        total_given_rating += rating['rating'] * rating['count'];
      });
      total_reviews = responseBody['total_ratings'];
      if (total_reviews > 0) {
        avg_rating = (total_given_rating / total_reviews);
      }
      recommended_percent = total;
      responseBody['reviews'].forEach((review) {
        reviews.add(Review(
            id: review['id'],
            name: review['name'],
            title: review['title'],
            review: review['review'],
            rating: review['rating'].toDouble(),
            approved: review['approved'],
            created_at: review['created_at'],
            updated_at: review['updated_at']));
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Item Details'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
            shoppingCartIconButton()
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                text: 'HIGHLIGHTS',
              ),
              Tab(
                text: 'REVIEWS',
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[highlightsTab(), reviewsTab()],
        ),
        floatingActionButton: addToCartFAB());
  }

  Widget reviewsTab() {
    if (reviews.length == 0) {
      return Container(child: Center(child: Text("No Reviews found")));
    }
    return ListView.builder(
      itemCount: reviews.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return rating_summary(avg_rating, recommended_percent, total_reviews);
        }
        return review(reviews[index - 1]);
      },
    );
  }

  Widget rating_summary(rating, recommended_percent, total_reviews) {
    return Card(
      elevation: 2.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.orange),
                          child: Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                        ratingBar(rating, 14)
                      ],
                    )),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${total_reviews} Customer Reviews",
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.w400)),
                      Text(
                          "Recommended by ${recommended_percent}% of reviewers",
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget review(Review review) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.orange),
                  child: Text(
                    review.rating.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                ratingBar(review.rating, 12)
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Color(0xFFDCDCDC), width: 0.7))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(review.title,
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(getReviewByText(review),
                        style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey)),
                  ),
                  Text(review.review,
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w300))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String getReviewByText(Review review) {
    RegExp exp = new RegExp(r"([^@]+)");
    var now = DateTime.parse(review.created_at);
    var formatter = new DateFormat('MMM d y');

    return "By ${exp.firstMatch(review.name).group(0)} - ${formatter.format(now)}";
  }

  Widget highlightsTab() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: 300,
                    child: FadeInImage(
                      image: NetworkImage(selectedProduct.image),
                      placeholder: AssetImage(
                          'images/placeholders/no-product-image.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            width: _deviceSize.width,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ratingBar(selectedProduct.avgRating, 20),
                Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Text(selectedProduct.reviewsCount)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              selectedProduct.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: Text(
                'Quantity: ',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                if (quantity > 1) {
                  setState(() {
                    quantity = quantity - 1;
                  });
                }
              },
            ),
            Text(quantity.toString()),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  quantity = quantity + 1;
                });
              },
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Text(
                  'Price :',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Text(
                  selectedProduct.displayPrice,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          addToCartFlatButton(),
          Container(
            padding: EdgeInsets.only(left: 8.0),
            alignment: Alignment.centerLeft,
            child: Text("Description", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.0))),
          HtmlWidget(selectedProduct.description)
        ],
      ),
    );
  }

  Widget addToCartFlatButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text(
              selectedProduct.isOrderable ? 'ADD TO CART' : 'OUT OF STOCK'),
          onPressed: () {
            if (selectedProduct.isOrderable) {
              model.addProduct(
                  variantId: selectedProduct.id, quantity: quantity);
            }
          },
        );
      },
    );
  }

  Widget addToCartFAB() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return FloatingActionButton(
          child: Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
          onPressed: () {
            selectedProduct.isOrderable
                ? model.addProduct(
                    variantId: selectedProduct.id, quantity: quantity)
                : null;
          },
          backgroundColor:
              selectedProduct.isOrderable ? Colors.orange : Colors.grey,
        );
      },
    );
  }
}

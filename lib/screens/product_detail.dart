import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/models/review.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/auth.dart';
import 'package:ofypets_mobile_app/screens/review_detail.dart';
import 'package:ofypets_mobile_app/screens/search.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/constants.dart' as prefix0;
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/widgets/shopping_cart_button.dart';
import 'package:ofypets_mobile_app/widgets/snackbar.dart';
import 'package:ofypets_mobile_app/screens/cart.dart';
import 'package:ofypets_mobile_app/widgets/todays_deals_card.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isFavorite = false;
  bool discount = true;
  bool _isLoading = true;
  TabController _tabController;
  Size _deviceSize;
  int quantity = 1;
  double _rating;
  Product selectedProduct;
  bool _hasVariants = false;
  List<Review> reviews = [];
  int total_reviews = 0;
  double recommended_percent = 0;
  double avg_rating = 0;
  String htmlDescription;
  List<Product> similarProducts = List();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String pincode = '';

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    if (widget.product.hasVariants != null) {
      if (widget.product.hasVariants) {
        _hasVariants = widget.product.hasVariants;
        selectedProduct = widget.product.variants.first;
        _isFavorite = widget.product.variants.first.favoritedByUser;
        discount = (double.parse(widget.product.variants.first.costPrice) -
                    double.parse(widget.product.variants.first.price)) >
                0
            ? true
            : false;
        htmlDescription = widget.product.variants.first.description != null
            ? widget.product.variants.first.description
            : '';
      } else {
        _isFavorite = widget.product.favoritedByUser;
        selectedProduct = widget.product;
        discount = (double.parse(widget.product.costPrice) -
                    double.parse(widget.product.price)) >
                0
            ? true
            : false;
        htmlDescription = widget.product.description != null
            ? widget.product.description
            : '';
      }
    } else {
      _isFavorite = widget.product.favoritedByUser;
      selectedProduct = widget.product;
      discount = (double.parse(widget.product.costPrice) -
                  double.parse(widget.product.price)) >
              0
          ? true
          : false;
      htmlDescription =
          widget.product.description != null ? widget.product.description : '';
    }
    get_reviews();
    getSimilarProducts();
    locator<ConnectivityManager>().initConnectivity(context);
    // _dropDownVariantItems = getVariants();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
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
        "products/${selectedProduct.reviewProductId}/reviews";
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
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Text('Item Details'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  MaterialPageRoute route =
                      MaterialPageRoute(builder: (context) => ProductSearch());
                  Navigator.of(context).push(route);
                },
              ),
              shoppingCartIconButton()
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Column(
                children: [
                  TabBar(
                    indicatorWeight: 4.0,
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
                  model.isLoading ? LinearProgressIndicator() : Container()
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[highlightsTab(), reviewsTab()],
          ),
          floatingActionButton: addToCartFAB());
    });
  }

  Widget reviewsTab() {
    if (reviews.length == 0) {
      return Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              writeReview(),
              Container(
                height: 400,
                alignment: Alignment.center,
                child: Text("No Reviews found"),
              )
            ],
          ));
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(20.0),
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
                      ),
                    )),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${total_reviews} Customer Reviews",
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.w400)),
                      SizedBox(
                        height: 6.0,
                      ),
                      Text(
                          "Recommended by ${recommended_percent}% of reviewers",
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              ],
            ),
            Divider(
              height: 1.0,
              indent: 100.0,
            ),
            SizedBox(
              height: 15,
            ),
            writeReview(),
          ],
        ),
      ),
    );
  }

  Widget writeReview() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 40.0,
              width: 335,
              child: GestureDetector(
                onTap: () {
                  if (model.isAuthenticated) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ReviewDetailScreen(selectedProduct)));
                  } else {
                    // Scaffold.of(context).showSnackBar(LoginErroSnackbar);
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(
                        'Please Login to write review.',
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
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          "WRITE A REVIEW",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ]);
    });
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
                  padding: const EdgeInsets.all(15.0),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(review.review,
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w300)),
                  )
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

  Widget quantityRow(MainModel model, Product selectedProduct) {
    print(
        "SELECTED PRODUCT ---> ${selectedProduct.totalOnHand}  ${selectedProduct.slug}");
    return Container(
        height: 60.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: selectedProduct.totalOnHand > 12
              ? 13
              : selectedProduct.isBackOrderable
                  ? 13
                  : selectedProduct.totalOnHand + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Container();
            } else {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    quantity = index;
                  });
                },
                child: Container(
                    width: 45,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: quantity == index
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    alignment: Alignment.center,
                    // margin: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                          color: quantity == index
                              ? Colors.green
                              : Colors.grey.shade300),
                    )),
              );
            }
          },
        ));
  }

  List<DropdownMenuItem<String>> getVariants() {
    List<DropdownMenuItem<String>> items = new List();

    widget.product.variants.forEach((variant) {
      variant.optionValues.forEach((optionValue) {
        items.add(DropdownMenuItem(
          value: optionValue.name,
          child: Text(
            optionValue.name,
            style: TextStyle(color: Colors.green),
          ),
        ));
      });
    });
    return items;
  }

  Widget variantDropDown() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        width: _deviceSize.width,
        height: 60,
        child: DropdownButton(
          elevation: 0,
          isExpanded: true,
          iconEnabledColor: Colors.green,
          items: getVariants(),
          value: selectedProduct.optionValues[0].name,
          onChanged: (value) {
            widget.product.variants.forEach((variant) {
              print(variant.optionValues[0]);
              if (variant.optionValues[0].name == value) {
                setState(() {
                  selectedProduct = variant;
                  discount = (double.parse(variant.costPrice) -
                              double.parse(variant.price)) >
                          0
                      ? true
                      : false;
                });
              }
            });
          },
        ));
  }

  Widget variantRow(int index) {
    if (widget.product.hasVariants != null) {
      if (widget.product.hasVariants) {
        List<Widget> optionValueNames = [];
        List<Widget> optionTypeNames = [];
        widget.product.optionTypes.forEach((optionType) {
          optionTypeNames.add(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: Text(optionType.name)));
        });
        widget.product.variants.forEach((variant) {
          variant.optionValues.forEach((optionValue) {
            optionValueNames.add(GestureDetector(
              onTap: () {
                setState(() {
                  quantity = index;
                });
              },
              child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: quantity == index ? Colors.green : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5)),
                  alignment: Alignment.center,
                  // margin: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  padding: EdgeInsets.all(10),
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                        color: quantity == index ? Colors.green : Colors.grey),
                  )),
            ));
          });
        });
      }
    }
  }

  // Widget variantRow() {
  //   if (widget.product.hasVariants != null) {
  //     if (widget.product.hasVariants) {
  //       List<Widget> optionValueNames = [];
  //       widget.product.variants.forEach((variant) {
  //         variant.optionValues.forEach((optionValue) {
  //           optionValueNames.add(GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   widget.product.variants.forEach((variant) {
  //                     if (variant.optionValues[0] == optionValue) {
  //                       setState(() {
  //                         selectedProduct = variant;
  //                         discount = (double.parse(variant.costPrice) -
  //                                     double.parse(variant.price)) >
  //                                 0
  //                             ? true
  //                             : false;
  //                       });
  //                     }
  //                   });
  //                 });
  //               },
  //               child: Container(
  //                   decoration: BoxDecoration(
  //                       border: Border.all(
  //                     color: selectedProduct.optionValues[0].name ==
  //                             optionValue.name
  //                         ? Colors.green
  //                         : Colors.black,
  //                   )),
  //                   alignment: Alignment.centerLeft,
  //                   margin: EdgeInsets.all(10),
  //                   padding: EdgeInsets.all(10),
  //                   child: Text(
  //                     optionValue.name,
  //                     style: TextStyle(
  //                         color: selectedProduct.optionValues[0].name ==
  //                                 optionValue.name
  //                             ? Colors.green
  //                             : Colors.black),
  //                   ))));
  //         });
  //       });
  //       return Container(
  //         height: 60.0,
  //         child: ListView(
  //           scrollDirection: Axis.horizontal,
  //           children: optionValueNames,
  //         ),
  //       );
  //     } else {
  //       return Container();
  //     }
  //   } else {
  //     return Container();
  //   }
  // }

  Widget highlightsTab() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Expanded(
                        //   child:
                        Center(
                          child: Container(
                            alignment: Alignment.center,
                            height: 300,
                            width: 220,
                            child: FadeInImage(
                              image: NetworkImage(selectedProduct.image != null
                                  ? selectedProduct.image
                                  : ''),
                              placeholder: AssetImage(
                                  'images/placeholders/no-product-image.png'),
                            ),
                          ),
                        )

                        // ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      padding: EdgeInsets.only(top: 40, right: 15.0),
                      alignment: Alignment.topRight,
                      icon: Icon(Icons.favorite),
                      color: _isFavorite ? Colors.orange : Colors.grey,
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String authToken = prefs.getString('spreeApiKey');
                        Map<String, String> headers = await getHeaders();

                        if (!_isFavorite) {
                          if (authToken == null) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
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
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                'Adding to Favorites, please wait.',
                              ),
                              duration: Duration(seconds: 1),
                            ));
                            http
                                .post(Settings.SERVER_URL + 'favorite_products',
                                    body: json.encode({
                                      'id': widget.product.reviewProductId
                                          .toString()
                                    }),
                                    headers: headers)
                                .then((response) {
                              Map<dynamic, dynamic> responseBody =
                                  json.decode(response.body);
                              setState(() {
                                _isFavorite = true;
                              });
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('Product marked as favorite!'),
                                duration: Duration(seconds: 1),
                              ));
                            });
                          }
                        } else {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                              'Removing from Favorites, please wait.',
                            ),
                            duration: Duration(seconds: 1),
                          ));
                          http
                              .delete(
                                  Settings.SERVER_URL +
                                      'favorite_products/${widget.product.reviewProductId}',
                                  headers: headers)
                              .then((response) {
                            Map<dynamic, dynamic> responseBody =
                                json.decode(response.body);
                            if (responseBody['message'] != null) {
                              setState(() {
                                _isFavorite = false;
                              });
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(responseBody['message']),
                                duration: Duration(seconds: 1),
                              ));
                            } else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('Oops! Something went wrong'),
                                duration: Duration(seconds: 1),
                              ));
                            }
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  width: _deviceSize.width,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          'By ${selectedProduct.name.split(' ')[0]}',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                              color: Colors.green,
                              fontFamily: fontFamily),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          ratingBar(selectedProduct.avgRating, 20),
                          Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Text(selectedProduct.reviewsCount)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Text(
                  selectedProduct.name,
                  style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(
                height: 18,
              ),
              widget.product.hasVariants &&
                      selectedProduct.optionValues.length > 0
                  ? Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Size ',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    )
                  : Container(),
              widget.product.hasVariants &&
                      selectedProduct.optionValues.length > 0
                  ? variantDropDown()
                  : Container(),
              SizedBox(
                height: 18,
              ),
              selectedProduct.isOrderable
                  ? Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Quantity ',
                        style: TextStyle(fontSize: 14, fontFamily: fontFamily),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 5,
              ),
              selectedProduct.isOrderable
                  ? quantityRow(model, selectedProduct)
                  : Container(),
              Divider(),
              discount
                  ? SizedBox(
                      height: 18,
                    )
                  : Container(),
              buildPriceRow('Price: ', selectedProduct.displayPrice,
                  strike: discount,
                  originalPrice:
                      '${selectedProduct.currencySymbol} ${selectedProduct.costPrice}'),
              discount
                  ? SizedBox(
                      height: 12,
                    )
                  : Container(),
              discount
                  ? Column(
                      children: <Widget>[
                        buildPriceRow(
                            'You Save: ',
                            '${selectedProduct.currencySymbol}' +
                                (double.parse(selectedProduct.costPrice) -
                                        double.parse(selectedProduct.price))
                                    .toString(),
                            strike: false,
                            discountPercent: '(' +
                                (((double.parse(selectedProduct.costPrice) -
                                                double.parse(
                                                    selectedProduct.price)) /
                                            double.parse(
                                                selectedProduct.costPrice)) *
                                        100)
                                    .round()
                                    .toString() +
                                '%)  '),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: 18,
              ),
              Divider(
                height: 1.0,
              ),
              Container(
                height: 40.0,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5.0, top: 0.0),
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Free 1-2 Day ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: double.parse(selectedProduct.costPrice.substring(
                                    1, selectedProduct.costPrice.length - 1)) <
                                699
                            ? 'shipping over Rs.699'
                            : 'shipping',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ]),
                  ),
                ),
              ),
              Divider(),
              pincodeBox(model, context),
              Divider(),
              SizedBox(
                height: 10.0,
              ),
              addToCartFlatButton(),
              SizedBox(
                height: 12.0,
              ),
              !selectedProduct.isOrderable ? Container() : buyNowFlatButton(),
              Divider(),
              SizedBox(
                height: 2,
              ),
              Column(
                children: <Widget>[
                  Container(
                      width: _deviceSize.width,
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 10.0),
                        title: Text('You May Also like',
                            style: TextStyle(
                                fontSize: 14,
                                // fontWeight: FontWeight.w600,
                                color: Colors.black)),
                      )),
                ],
              ),
              _isLoading
                  ? Container(
                      height: _deviceSize.height * 0.47,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.green,
                      ),
                    )
                  : Container(
                      height: 355,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarProducts.length,
                        itemBuilder: (context, index) {
                          return todaysDealsCard(
                              index, similarProducts, _deviceSize, context);
                          // similarProductCard(index, similarProducts,
                          //     _deviceSize, context, true);
                        },
                      ),
                    ),
              Container(
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  alignment: Alignment.centerLeft,
                  child: Text("Description",
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w600))),
              HtmlWidget(htmlDescription),
            ],
          ),
        ),
      );
    });
  }

  Widget buyNowFlatButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: double.infinity,
            height: 45.0,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: selectedProduct.isOrderable
                      ? Colors.deepOrange
                      : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                selectedProduct.isOrderable ? 'BUY NOW' : 'OUT OF STOCK',
                style: TextStyle(
                    color: selectedProduct.isOrderable
                        ? Colors.deepOrange
                        : Colors.grey),
              ),
              onPressed: selectedProduct.isOrderable
                  ? () {
                      Scaffold.of(context).showSnackBar(processSnackbar);
                      if (selectedProduct.isOrderable) {
                        model.addProduct(
                            variantId: selectedProduct.id, quantity: quantity);
                        if (!model.isLoading) {
                          Scaffold.of(context).showSnackBar(completeSnackbar);
                          MaterialPageRoute route =
                              MaterialPageRoute(builder: (context) => Cart());

                          Navigator.push(context, route);
                        }
                      }
                    }
                  : () {},
            ),
          ),
        );
      },
    );
  }

  Widget addToCartFlatButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: double.infinity,
            height: 45.0,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color:
                      selectedProduct.isOrderable ? Colors.green : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                selectedProduct.isOrderable ? 'ADD TO CART' : 'OUT OF STOCK',
                style: TextStyle(
                    color: selectedProduct.isOrderable
                        ? Colors.green
                        : Colors.grey),
              ),
              onPressed: selectedProduct.isOrderable
                  ? () {
                      Scaffold.of(context).showSnackBar(processSnackbar);
                      if (selectedProduct.isOrderable) {
                        model.addProduct(
                            variantId: selectedProduct.id, quantity: quantity);
                        if (!model.isLoading) {
                          Scaffold.of(context).showSnackBar(completeSnackbar);
                        }
                      }
                    }
                  : () {},
            ),
          ),
        );
      },
    );
  }

  Widget addToCartFAB() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _tabController.index == 0
            ? FloatingActionButton(
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                onPressed: selectedProduct.isOrderable
                    ? () {
                        Scaffold.of(context).showSnackBar(processSnackbar);
                        selectedProduct.isOrderable
                            ? model.addProduct(
                                variantId: selectedProduct.id,
                                quantity: quantity)
                            : null;
                        if (!model.isLoading) {
                          Scaffold.of(context).showSnackBar(completeSnackbar);
                        }
                      }
                    : () {},
                backgroundColor: selectedProduct.isOrderable
                    ? Colors.deepOrange
                    : Colors.grey,
              )
            : FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (model.isAuthenticated) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ReviewDetailScreen(selectedProduct)));
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'Please Login to write review.',
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
                  }
                },
                backgroundColor: Colors.orange);
      },
    );
  }

  Widget buildPriceRow(String key, String value,
      {bool strike, String originalPrice, String discountPercent}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 17,
              fontFamily: fontFamily,
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: strike
              ? RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: originalPrice,
                        style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough)),
                    TextSpan(text: '   '),
                    TextSpan(
                        text: value,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold)),
                  ]),
                )
              : discount
                  ? RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: discountPercent,
                            style: TextStyle(
                              color: Colors.red,
                            )),
                        TextSpan(
                            text: value,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.bold)),
                      ]),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
        ),
      ],
    );
  }

  Widget pincodeBox(MainModel model, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: _deviceSize.width * 0.60,
          height: 70,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(bottom: 15, left: 10),
          child: Form(
            key: _formKey,
            child: TextFormField(
              initialValue: pincode,
              decoration: InputDecoration(
                  labelText: 'Pin Code',
                  labelStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.all(0.0)),
              onSaved: (String value) {
                setState(() {
                  pincode = value;
                });
              },
            ),
          ),
        ),
        FlatButton(
            child: Container(
              child: Text(
                'CHECK',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ),
            onPressed: () async {
              FocusScope.of(context).requestFocus(new FocusNode());
              _formKey.currentState.save();
              if (pincode != '') {
                bool available =
                    await model.shipmentAvailability(pincode: pincode);
                if (available) {
                  Scaffold.of(context).showSnackBar(codAvailable);
                } else {
                  Scaffold.of(context).showSnackBar(codNotAvailable);
                }
              } else {
                Scaffold.of(context).showSnackBar(codEmpty);
              }
            }),
      ],
    );
  }

  getSimilarProducts() {
    Map<String, dynamic> responseBody = Map();
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxons/products?id=${widget.product.taxonId}&per_page=15&data_set=small')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['products'].forEach((product) {
        int reviewProductId = product["id"];
        variants = [];
        if (product['has_variants']) {
          product['variants'].forEach((variant) {
            optionValues = [];
            optionTypes = [];
            variant['option_values'].forEach((option) {
              setState(() {
                optionValues.add(OptionValue(
                  id: option['id'],
                  name: option['name'],
                  optionTypeId: option['option_type_id'],
                  optionTypeName: option['option_type_name'],
                  optionTypePresentation: option['option_type_presentation'],
                ));
              });
            });
            setState(() {
              variants.add(Product(
                  id: variant['id'],
                  name: variant['name'],
                  description: variant['description'],
                  slug: variant['slug'],
                  optionValues: optionValues,
                  displayPrice: variant['display_price'],
                  image: variant['images'][0]['product_url'],
                  isOrderable: variant['is_orderable'],
                  avgRating: double.parse(product['avg_rating']),
                  reviewsCount: product['reviews_count'].toString(),
                  reviewProductId: reviewProductId));
            });
          });
          product['option_types'].forEach((optionType) {
            setState(() {
              optionTypes.add(OptionType(
                  id: optionType['id'],
                  name: optionType['name'],
                  position: optionType['position'],
                  presentation: optionType['presentation']));
            });
          });
          setState(() {
            similarProducts.add(Product(
                taxonId: product['taxon_ids'].first,
                id: product['id'],
                name: product['name'],
                slug: product['slug'],
                displayPrice: product['display_price'],
                avgRating: double.parse(product['avg_rating']),
                reviewsCount: product['reviews_count'].toString(),
                image: product['master']['images'][0]['product_url'],
                variants: variants,
                reviewProductId: reviewProductId,
                hasVariants: product['has_variants'],
                optionTypes: optionTypes));
          });
        } else {
          setState(() {
            similarProducts.add(Product(
              taxonId: product['taxon_ids'].first,
              id: product['id'],
              name: product['name'],
              slug: product['slug'],
              displayPrice: product['display_price'],
              avgRating: double.parse(product['avg_rating']),
              reviewsCount: product['reviews_count'].toString(),
              image: product['master']['images'][0]['product_url'],
              hasVariants: product['has_variants'],
              isOrderable: product['master']['is_orderable'],
              reviewProductId: reviewProductId,
              description: product['description'],
            ));
          });
        }
      });
      setState(() {
        _isLoading = false;
      });
    });
  }
}

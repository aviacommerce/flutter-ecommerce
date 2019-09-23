import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/models/favorites.dart';
import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/drawer_homescreen.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/widgets/shopping_cart_button.dart';
import 'package:scoped_model/scoped_model.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavoritesScreenState();
  }
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Favorite> favoriteProducts = [];
  List<Favorite> deletedProducts = [];
  Future<List<Favorite>> futureFavoriteProducts;
  bool _isLoading = false;
  Product tappedProduct;
  final int perPage = TWENTY;
  int currentPage = ONE;
  int subCatId = ZERO;
  static const int PAGE_SIZE = 20;
  final scrollController = ScrollController();

  bool hasMore = false;
  @override
  void initState() {
    super.initState();
    locator<ConnectivityManager>().initConnectivity(context);
    getPaginatedFavorites();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        getPaginatedFavorites();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          title: Text('Favorites'),
          actions: <Widget>[
            shoppingCartIconButton(),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  child: LinearProgressIndicator(),
                  preferredSize: Size.fromHeight(10),
                )
              : PreferredSize(
                  child: Container(),
                  preferredSize: Size.fromHeight(10),
                ),
        ),
        drawer: HomeDrawer(),
        body: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: model.isLoading
                ? LinearProgressIndicator()
                : Theme(
                    data: ThemeData(primarySwatch: Colors.green),
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: favoriteProducts.length + 1,
                        itemBuilder: (mainContext, index) {
                          if (index < favoriteProducts.length) {
                            // return favoriteCard(
                            //     context, searchProducts[index], index);
                            return favoriteCardPaginated(
                                _scaffoldKey.currentContext,
                                favoriteProducts[index],
                                index);
                          }
                          if (hasMore && favoriteProducts.length == 0) {
                            return noProductFoundWidget();
                          }
                          if (!hasMore || _isLoading) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                  child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )),
                            );
                          } else {
                            return Container();
                          }
                        }),
                  )),
      );
    });
  }

  Widget noProductFoundWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 220.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.favorite_border,
                  size: 80.0,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Welcome to Favorites',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 35.0, vertical: 5),
                  child: Text(
                    "Save, organize, and shop all your pet's favorites in one spot!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 150,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: RaisedButton(
                    color: Colors.deepOrange,
                    onPressed: () {
                      // Navigator.pop(context);
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
                    },
                    child: Text(
                      'START SHOPPING',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget favoriteCardPaginated(
      BuildContext context, Favorite favorite, int index) {
    bool isDeleted = false;
    deletedProducts.forEach((deletedItem) {
      if (deletedItem.id == favorite.id) {
        isDeleted = true;
      }
    });
    if (isDeleted) {
      return Container();
    } else {
      return ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return GestureDetector(
          onTap: () {
            // getProductDetail(favorite.slug);
            model.getProductDetail(favorite.slug, context);
          },
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            margin: EdgeInsets.all(4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: EdgeInsets.all(10),
                height: 150,
                width: 150,
                color: Colors.white,
                child: FadeInImage(
                  image: NetworkImage(
                      favorite.image != null ? favorite.image : ''),
                  placeholder:
                      AssetImage('images/placeholders/no-product-image.png'),
                ),
              ),
              Expanded(
                child: Container(
                  height: 150.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0, top: 10.0),
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: '${favorite.name.split(' ')[0]} ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: favorite.name.substring(
                                          favorite.name.split(' ')[0].length +
                                              1,
                                          favorite.name.length),
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                            IconButton(
                              color: Colors.grey,
                              icon: Icon(Icons.clear),
                              onPressed: () async {
                                Map<String, String> headers =
                                    await getHeaders();
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                    'Removing from Favorites, please wait.',
                                  ),
                                  duration: Duration(seconds: 1),
                                ));
                                http
                                    .delete(
                                        Settings.SERVER_URL +
                                            'favorite_products/${favorite.id}',
                                        headers: headers)
                                    .then((response) {
                                  Map<dynamic, dynamic> responseBody =
                                      json.decode(response.body);
                                  if (responseBody['message'] != null) {
                                    setState(() {
                                      addItemtoDeleteList(favorite);
                                    });
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(responseBody['message']),
                                      duration: Duration(seconds: 1),
                                    ));
                                  } else {
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text('Oops! Something went wrong'),
                                      duration: Duration(seconds: 1),
                                    ));
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Price',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade700),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Text(
                                favorite.currencySymbol + favorite.price,
                                textAlign: TextAlign.left,
                                style:
                                    TextStyle(fontSize: 15, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        );
      });
    }
  }

  void addItemtoDeleteList(Favorite favorite) {
    deletedProducts.add(favorite);
  }

  Future<int> getProductDetail(String slug) async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();

    http.Response response = await http.get(
        Settings.SERVER_URL + 'api/v1/products/$slug?data_set=large',
        headers: headers);
    responseBody = json.decode(response.body);
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];

    int reviewProductId = responseBody['data']['attributes']["id"];
    variants = [];
    if (responseBody['data']['attributes']['has_variants']) {
      return responseBody['data']['included']['variants'].first['data']
          ['attributes']['id'];
    } else {
      return responseBody['data']['included']['id'];
    }
  }

  Future<List<Favorite>> getPaginatedFavorites() async {
    setState(() {
      hasMore = false;
    });

    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();
    http.Response response = await http.get(
        Settings.SERVER_URL +
            'spree/user_favorite_products.json?page=$currentPage&per_page=$perPage&data_set=small',
        headers: headers);
    currentPage++;
    responseBody = json.decode(response.body);
    print(responseBody['data']);
    responseBody['data'].forEach((favoriteObj) {
      favoriteProducts.add(Favorite(
          id: favoriteObj['id'],
          name: favoriteObj['attributes']['name'],
          image: favoriteObj['attributes']['product_url'],
          price: favoriteObj['attributes']['price'],
          currencySymbol: favoriteObj['attributes']['currency_symbol'],
          slug: favoriteObj['attributes']['slug']));
    });
    setState(() {
      hasMore = true;
      _isLoading = false;
    });

    return favoriteProducts;
  }
}

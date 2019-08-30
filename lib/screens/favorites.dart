import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:ofypets_mobile_app/models/favorites.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';

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
  @override
  void initState() {
    // getFavorites();
    super.initState();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Favorites'),
          bottom: _isLoading || model.isLoading
              ? PreferredSize(
                  child: LinearProgressIndicator(),
                  preferredSize: Size.fromHeight(10),
                )
              : PreferredSize(
                  child: Container(),
                  preferredSize: Size.fromHeight(10),
                ),
        ),
        body: Theme(
          data: ThemeData(primarySwatch: Colors.green),
          child: PagewiseListView(
            pageSize: PAGE_SIZE,
            itemBuilder: favoriteCardPaginated,
            pageFuture: (pageIndex) {
              return getPaginatedFavorites();
            },
          ),
        ),
      );
    });
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
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    height: 150,
                    width: 150,
                    color: Colors.white,
                    child: FadeInImage(
                      image: NetworkImage(favorite.image),
                      placeholder: AssetImage(
                          'images/placeholders/no-product-image.png'),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            favorite.name,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Text(
                            favorite.currencySymbol + favorite.price,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 15, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: IconButton(
                      color: Colors.grey,
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        Map<String, String> headers = await getHeaders();
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
                      },
                    ),
                  ),
                ])
              ],
            ),
          ),
        );
      });
    }
  }

  void addItemtoDeleteList(Favorite favorite) {
    deletedProducts.add(favorite);
  }

  // getProductDetail(String slug) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Map<String, String> headers = await getHeaders();
  //   Map<String, dynamic> responseBody = Map();

  //   http.Response response = await http.get(
  //       Settings.SERVER_URL + 'api/v1/products/$slug?data_set=large',
  //       headers: headers);
  //   responseBody = json.decode(response.body);
  //   List<Product> variants = [];
  //   List<OptionValue> optionValues = [];
  //   List<OptionType> optionTypes = [];

  //   int reviewProductId = responseBody['data']['attributes']["id"];
  //   variants = [];
  //   if (responseBody['data']['attributes']['has_variants']) {
  //     responseBody['data']['included']['variants'].forEach((variant) {
  //       optionValues = [];
  //       optionTypes = [];
  //       variant['data']['included']['option_values'].forEach((option) {
  //         setState(() {
  //           optionValues.add(OptionValue(
  //             id: option['data']['attributes']['id'],
  //             name: option['data']['attributes']['name'],
  //             optionTypeId: option['data']['attributes']['option_type_id'],
  //             optionTypeName: option['data']['attributes']['option_type_name'],
  //             optionTypePresentation: option['data']['attributes']
  //                 ['option_type_presentation'],
  //           ));
  //         });
  //       });
  //       setState(() {
  //         variants.add(Product(
  //             id: variant['data']['attributes']['id'],
  //             name: variant['data']['attributes']['name'],
  //             description: variant['data']['attributes']['description'],
  //             optionValues: optionValues,
  //             displayPrice: variant['data']['attributes']['display_price'],
  //             image: variant['data']['included']['images'][0]['data']
  //                 ['attributes']['product_url'],
  //             isOrderable: variant['data']['attributes']['is_orderable'],
  //             avgRating: double.parse(
  //                 responseBody['data']['attributes']['avg_rating']),
  //             reviewsCount: responseBody['data']['attributes']['reviews_count']
  //                 .toString(),
  //             reviewProductId: reviewProductId));
  //       });
  //     });
  //     responseBody['data']['included']['option_types'].forEach((optionType) {
  //       setState(() {
  //         optionTypes.add(OptionType(
  //             id: optionType['data']['attributes']['id'],
  //             name: optionType['data']['attributes']['name'],
  //             position: optionType['data']['attributes']['position'],
  //             presentation: optionType['data']['attributes']['presentation']));
  //       });
  //     });
  //     setState(() {
  //       tappedProduct = Product(
  //           taxonId: responseBody['data']['attributes']['taxon_ids'].first,
  //           id: responseBody['data']['included']['id'],
  //           name: responseBody['data']['attributes']['name'],
  //           displayPrice: responseBody['data']['attributes']['display_price'],
  //           avgRating:
  //               double.parse(responseBody['data']['attributes']['avg_rating']),
  //           reviewsCount:
  //               responseBody['data']['attributes']['reviews_count'].toString(),
  //           image: responseBody['data']['included']['master']['data']
  //               ['included']['images'][0]['data']['attributes']['product_url'],
  //           variants: variants,
  //           reviewProductId: reviewProductId,
  //           hasVariants: responseBody['data']['attributes']['has_variants'],
  //           optionTypes: optionTypes);
  //     });
  //   } else {
  //     setState(() {
  //       tappedProduct = Product(
  //         taxonId: responseBody['data']['attributes']['taxon_ids'].first,
  //         id: responseBody['data']['included']['id'],
  //         name: responseBody['data']['attributes']['name'],
  //         displayPrice: responseBody['data']['attributes']['display_price'],
  //         avgRating:
  //             double.parse(responseBody['data']['attributes']['avg_rating']),
  //         reviewsCount:
  //             responseBody['data']['attributes']['reviews_count'].toString(),
  //         image: responseBody['data']['included']['master']['data']['included']
  //             ['images'][0]['data']['attributes']['product_url'],
  //         hasVariants: responseBody['data']['attributes']['has_variants'],
  //         isOrderable: responseBody['data']['included']['master']['data']
  //             ['attributes']['is_orderable'],
  //         reviewProductId: reviewProductId,
  //         description: responseBody['data']['attributes']['description'],
  //       );
  //     });
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  //   MaterialPageRoute route = MaterialPageRoute(
  //       builder: (context) => ProductDetailScreen(tappedProduct));
  //   Navigator.push(context, route);
  // }

  Future<List<Favorite>> getPaginatedFavorites() async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();
    http.Response response = await http.get(
        Settings.SERVER_URL +
            'spree/user_favorite_products.json?page=$currentPage&per_page=$perPage&data_set=small',
        headers: headers);
    currentPage++;
    responseBody = json.decode(response.body);
    responseBody['data'].forEach((favoriteObj) {
      setState(() {
        favoriteProducts.add(Favorite(
            id: favoriteObj['id'],
            name: favoriteObj['attributes']['name'],
            image: favoriteObj['attributes']['product_url'],
            price: favoriteObj['attributes']['price'],
            currencySymbol: favoriteObj['attributes']['currency_symbol'],
            slug: favoriteObj['attributes']['slug']));
      });
    });
    return favoriteProducts;
  }
}

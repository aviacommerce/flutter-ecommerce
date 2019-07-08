import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/models/favorites.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';
import 'package:ofypets_mobile_app/screens/product_detail.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavoritesScreenState();
  }
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Favorite> favoriteProducts = [];
  bool _isLoading = true;
  Product tappedProduct;

  @override
  void initState() {
    getFavorites();
    super.initState();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Favorites'),
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
        body: ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              return favoriteCard(index);
            }));
  }

  Widget favoriteCard(int index) {
    return GestureDetector(
        onTap: () {
          getProductDetail(index);
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
                      image: NetworkImage(favoriteProducts[index].image),
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
                            favoriteProducts[index].name,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Text(
                            favoriteProducts[index].currencySymbol +
                                favoriteProducts[index].price,
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
                                    'favorite_products/${favoriteProducts[index].id}',
                                headers: headers)
                            .then((response) {
                          Map<dynamic, dynamic> responseBody =
                              json.decode(response.body);
                          if (responseBody['message'] != null) {
                            setState(() {
                              favoriteProducts.removeAt(index);
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
            )));
  }

  getProductDetail(int index) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();

    http.Response response = await http.get(
        Settings.SERVER_URL +
            'api/v1/products/${favoriteProducts[index].slug}?data_set=large',
        headers: headers);
    responseBody = json.decode(response.body);
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];

    int review_product_id = responseBody['data']['attributes']["id"];
    variants = [];
    if (responseBody['data']['attributes']['has_variants']) {
      responseBody['data']['included']['variants'].forEach((variant) {
        optionValues = [];
        optionTypes = [];
        variant['data']['included']['option_values'].forEach((option) {
          setState(() {
            optionValues.add(OptionValue(
              id: option['data']['attributes']['id'],
              name: option['data']['attributes']['name'],
              optionTypeId: option['data']['attributes']['option_type_id'],
              optionTypeName: option['data']['attributes']['option_type_name'],
              optionTypePresentation: option['data']['attributes']
                  ['option_type_presentation'],
            ));
          });
        });
        setState(() {
          variants.add(Product(
              id: variant['data']['attributes']['id'],
              name: variant['data']['attributes']['name'],
              description: variant['data']['attributes']['description'],
              optionValues: optionValues,
              displayPrice: variant['data']['attributes']['display_price'],
              image: variant['data']['included']['images'][0]['data']
                  ['attributes']['product_url'],
              isOrderable: variant['data']['attributes']['is_orderable'],
              avgRating: double.parse(
                  responseBody['data']['attributes']['avg_rating']),
              reviewsCount: responseBody['data']['attributes']['reviews_count']
                  .toString(),
              reviewProductId: review_product_id));
        });
      });
      responseBody['data']['included']['option_types'].forEach((optionType) {
        setState(() {
          optionTypes.add(OptionType(
              id: optionType['data']['attributes']['id'],
              name: optionType['data']['attributes']['name'],
              position: optionType['data']['attributes']['position'],
              presentation: optionType['data']['attributes']['presentation']));
        });
      });
      setState(() {
        tappedProduct = Product(
            taxonId: responseBody['data']['attributes']['taxon_ids'].first,
            id: responseBody['data']['included']['id'],
            name: responseBody['data']['attributes']['name'],
            displayPrice: responseBody['data']['attributes']['display_price'],
            avgRating:
                double.parse(responseBody['data']['attributes']['avg_rating']),
            reviewsCount:
                responseBody['data']['attributes']['reviews_count'].toString(),
            image: responseBody['data']['included']['master']['data']
                ['included']['images'][0]['data']['attributes']['product_url'],
            variants: variants,
            reviewProductId: review_product_id,
            hasVariants: responseBody['data']['attributes']['has_variants'],
            optionTypes: optionTypes);
      });
    } else {
      setState(() {
        tappedProduct = Product(
          taxonId: responseBody['data']['attributes']['taxon_ids'].first,
          id: responseBody['data']['included']['id'],
          name: responseBody['data']['attributes']['name'],
          displayPrice: responseBody['data']['attributes']['display_price'],
          avgRating:
              double.parse(responseBody['data']['attributes']['avg_rating']),
          reviewsCount:
              responseBody['data']['attributes']['reviews_count'].toString(),
          image: responseBody['data']['included']['master']['data']['included']
              ['images'][0]['data']['attributes']['product_url'],
          hasVariants: responseBody['data']['attributes']['has_variants'],
          isOrderable: responseBody['data']['included']['master']['data']
              ['attributes']['is_orderable'],
          reviewProductId: review_product_id,
          description: responseBody['data']['attributes']['description'],
        );
      });
    }
    setState(() {
      _isLoading = false;
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => ProductDetailScreen(tappedProduct));
    Navigator.push(context, route);
  }

  getFavorites() async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();

    http.Response response = await http.get(
        Settings.SERVER_URL +
            'spree/user_favorite_products.json?data_set=small',
        headers: headers);

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
    setState(() {
      _isLoading = false;
    });
  }
}

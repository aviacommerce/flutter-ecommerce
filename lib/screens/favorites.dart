import 'package:flutter/material.dart';

import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/models/favorites.dart';
import 'package:ofypets_mobile_app/models/product.dart';

// import 'package:ofypets_mobile_app/models/option_type.dart';
// import 'package:ofypets_mobile_app/models/option_value.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // getProductDetail(index);
        },
        child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: <Widget>[
                //     Container(
                //       child: IconButton(
                //         color: Colors.grey,
                //         icon: Icon(Icons.delete),
                //         onPressed: () {},
                //       ),
                //     ),
                //   ],
                // ),
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
                  )
                ])
              ],
            )));
  }

  // getProductDetail(int index) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Map<String, String> headers = await getHeaders();
  //   Map<String, dynamic> responseBody = Map();
  //   List<Product> variants = [];
  //   List<OptionValue> optionValues = [];
  //   List<OptionType> optionTypes = [];

  //   http.Response response = await http.get(
  //       Settings.SERVER_URL +
  //           'api/v1/products/${favoriteProducts[index].slug}?data_set=large',
  //       headers: headers);

  //   responseBody = json.decode(response.body);
  //   print(responseBody);
  //   int review_product_id = responseBody['data']['attributes']["id"];
  //   variants = [];
  //   if (responseBody['data']['attributes']['has_variants']) {
  //     responseBody['data']['attributes']['variants'].forEach((variant) {
  //       optionValues = [];
  //       optionTypes = [];
  //       variant['option_values'].forEach((option) {
  //         setState(() {
  //           optionValues.add(OptionValue(
  //             id: option['id'],
  //             name: option['name'],
  //             optionTypeId: option['option_type_id'],
  //             optionTypeName: option['option_type_name'],
  //             optionTypePresentation: option['option_type_presentation'],
  //           ));
  //         });
  //       });
  //       setState(() {
  //         variants.add(Product(
  //             id: variant['id'],
  //             name: variant['name'],
  //             description: variant['description'],
  //             optionValues: optionValues,
  //             displayPrice: variant['display_price'],
  //             image: variant['images'][0]['product_url'],
  //             isOrderable: variant['is_orderable'],
  //             avgRating: double.parse(
  //                 responseBody['data']['attributes']['avg_rating']),
  //             reviewsCount: responseBody['data']['attributes']['reviews_count']
  //                 .toString(),
  //             reviewProductId: review_product_id));
  //       });
  //     });
  //     responseBody['data']['attributes']['option_types'].forEach((optionType) {
  //       setState(() {
  //         optionTypes.add(OptionType(
  //             id: optionType['id'],
  //             name: optionType['name'],
  //             position: optionType['position'],
  //             presentation: optionType['presentation']));
  //       });
  //     });
  //     setState(() {
  //       tappedProduct = Product(
  //           name: responseBody['data']['attributes']['name'],
  //           displayPrice: responseBody['data']['attributes']['display_price'],
  //           avgRating:
  //               double.parse(responseBody['data']['attributes']['avg_rating']),
  //           reviewsCount:
  //               responseBody['data']['attributes']['reviews_count'].toString(),
  //           image: responseBody['data']['attributes']['master']['images'][0]
  //               ['product_url'],
  //           variants: variants,
  //           reviewProductId: review_product_id,
  //           hasVariants: responseBody['data']['attributes']['has_variants'],
  //           optionTypes: optionTypes);
  //     });
  //   } else {
  //     setState(() {
  //       tappedProduct = Product(
  //         id: responseBody['data']['included']['id'],
  //         name: responseBody['data']['attributes']['name'],
  //         displayPrice: responseBody['data']['attributes']['display_price'],
  //         avgRating:
  //             double.parse(responseBody['data']['attributes']['avg_rating']),
  //         reviewsCount:
  //             responseBody['data']['attributes']['reviews_count'].toString(),
  //         image: responseBody['data']['attributes']['master']['images'][0]
  //             ['product_url'],
  //         hasVariants: responseBody['data']['attributes']['has_variants'],
  //         isOrderable: responseBody['data']['attributes']['master']
  //             ['is_orderable'],
  //         reviewProductId: review_product_id,
  //         description: responseBody['data']['attributes']['description'],
  //       );
  //     });
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  getFavorites() async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();

    http.Response response = await http.get(
        Settings.SERVER_URL +
            'spree/user_favorite_products.json?data_set=small',
        headers: headers);

    responseBody = json.decode(response.body);
    print(responseBody);
    responseBody['data'].forEach((favoriteObj) {
      print(favoriteObj['attributes']['slug']);

      setState(() {
        favoriteProducts.add(Favorite(
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

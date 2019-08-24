  // import 'package:flutter/material.dart';

  // import 'package:http/http.dart' as http;
  // import 'dart:convert';

  // import 'package:ofypets_mobile_app/utils/headers.dart';
  // import 'package:ofypets_mobile_app/utils/constants.dart';
  // import 'package:ofypets_mobile_app/models/product.dart';
  // import 'package:ofypets_mobile_app/models/option_type.dart';
  // import 'package:ofypets_mobile_app/models/option_value.dart';
    
  // getProductDetail(String slug) async {
  //   // setState(() {
  //   //   _isLoading = true;
  //   // });
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
  //         // setState(() {
  //           optionValues.add(OptionValue(
  //             id: option['data']['attributes']['id'],
  //             name: option['data']['attributes']['name'],
  //             optionTypeId: option['data']['attributes']['option_type_id'],
  //             optionTypeName: option['data']['attributes']['option_type_name'],
  //             optionTypePresentation: option['data']['attributes']
  //                 ['option_type_presentation'],
  //           ));
  //         // });
  //       });
  //       // setState(() {
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
  //       // });
  //     });
  //     responseBody['data']['included']['option_types'].forEach((optionType) {
  //       // setState(() {
  //         optionTypes.add(OptionType(
  //             id: optionType['data']['attributes']['id'],
  //             name: optionType['data']['attributes']['name'],
  //             position: optionType['data']['attributes']['position'],
  //             presentation: optionType['data']['attributes']['presentation']));
  //       });
  //     // });
  //     // setState(() {
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
  //     // });
  //   } else {
  //     // setState(() {
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
  //     // });
  //   }
  //   // setState(() {
  //     _isLoading = false;
  //   // });
  // }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/models/brand.dart';
import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/search.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/drawer_homescreen.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/widgets/product_container.dart';
import 'package:ofypets_mobile_app/widgets/shopping_cart_button.dart';
import 'package:scoped_model/scoped_model.dart';

class BrandList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BrandListState();
  }
}

class _BrandListState extends State<BrandList> {
  Map<dynamic, dynamic> responseBody;
  List<Brand> brands = [];
  List<Product> productsByBrand = [];
  bool _isLoading = true;
  bool _isSelected = false;
  Size _deviceSize;
  String _brandName = '';
  String _heading = 'By Brand';
  final int perPage = TWENTY;
  int currentPage = ONE;
  int subCatId = ZERO;
  int brandId = 0;
  static const int PAGE_SIZE = 20;
  @override
  void initState() {
    super.initState();
    getBrandsList();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return WillPopScope(
          onWillPop: () => _canLeave(),
          child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(140.0),
                child: AppBar(
                    title: Text('Shop'),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          MaterialPageRoute route = MaterialPageRoute(
                              builder: (context) => ProductSearch());
                          Navigator.of(context).push(route);
                        },
                      ),
                      shoppingCartIconButton()
                    ],
                    bottom: PreferredSize(
                        preferredSize: Size(_deviceSize.width, 40),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSelected = false;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: 70,
                                      bottom: 20,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _heading,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: _isSelected
                                              ? FontWeight.w200
                                              : FontWeight.bold),
                                    ),
                                  )),
                              _isSelected
                                  ? Container(
                                      margin: EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        ' > ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w200),
                                      ),
                                    )
                                  : Container(),
                              _isSelected
                                  ? Container(
                                      margin: EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _brandName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                          _isLoading || model.isLoading
                              ? LinearProgressIndicator()
                              : Container()
                        ]))),
              ),
              drawer: HomeDrawer(),
              body: Scrollbar(
                  child: _isLoading
                      ? Container(
                          height: _deviceSize.height,
                        )
                      : !_isSelected
                          ? ListView.builder(
                              itemCount: brands.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    color: Colors.white,
                                    child: Column(children: [
                                      GestureDetector(
                                          onTap: () {
                                            productsByBrand = [];
                                            brandId = brands[index].id;
                                            setState(() {
                                              _isSelected = true;
                                              //_isLoading = true;
                                              _brandName = brands[index].name;
                                            });
                                          },
                                          child: Container(
                                              color: Colors.white,
                                              width: _deviceSize.width,
                                              alignment: Alignment.centerLeft,
                                              margin: EdgeInsets.all(10),
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                brands[index].name,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ))),
                                      Divider()
                                    ]));
                              })
                          : Theme(
                              data: ThemeData(primarySwatch: Colors.green),
                              child: PagewiseListView(
                                pageSize: PAGE_SIZE,
                                itemBuilder: productContainer,
                                pageFuture: (pageIndex) => getBrandProducts(0),
                              ),
                            ))));
    });
  }

  getBrandsList() {
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies?q[name_cont]=Brands&set=nested')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxonomies'][0]['root']['taxons'].forEach((brandObj) {
        setState(() {
          brands.add(Brand(name: brandObj['name'], id: brandObj['id']));
        });
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<List<Product>> getBrandProducts(int id) async {
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    final response = (await http.get(Settings.SERVER_URL +
            'api/v1/taxons/products?id=$brandId&page=$currentPage&per_page=$perPage&data_set=small'))
        .body;
    currentPage++;
    responseBody = json.decode(response);
    responseBody['products'].forEach((product) {
      print('---------TAXON ID---------');
      print(product['taxon_ids'].first);
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
                slug: variant['slug'],
                id: variant['id'],
                name: variant['name'],
                description: variant['description'],
                price: variant['price'],
                optionValues: optionValues,
                displayPrice: variant['display_price'],
                costPrice: variant['cost_price'],
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
          productsByBrand.add(Product(
              slug: product['slug'],
              taxonId: product['taxon_ids'].first,
              id: product['id'],
              price: product['price'],
              name: product['name'],
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
          productsByBrand.add(Product(
            slug: product['slug'],
            taxonId: product['taxon_ids'].first,
            id: product['id'],
            name: product['name'],
            displayPrice: product['display_price'],
            costPrice: product['cost_price'],
            avgRating: double.parse(product['avg_rating']),
            reviewsCount: product['reviews_count'].toString(),
            image: product['master']['images'][0]['product_url'],
            hasVariants: product['has_variants'],
            price: product['price'],
            isOrderable: product['master']['is_orderable'],
            reviewProductId: reviewProductId,
            description: product['description'],
          ));
        });
      }
    });
    return productsByBrand;
    /*setState(() {
        _isLoading = false;
      });
    });*/
  }

  Future<bool> _canLeave() {
    if (!_isSelected) {
      return Future<bool>.value(true);
    } else {
      setState(() {
        _isSelected = false;
      });
      return Future<bool>.value(false);
    }
  }
}

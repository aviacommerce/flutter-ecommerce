import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/models/brand.dart';
import 'package:ofypets_mobile_app/models/category.dart';
import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/models/searchProduct.dart';
import 'package:ofypets_mobile_app/screens/product_detail.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';

class ProductSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductSearchState();
  }
}

class _ProductSearchState extends State<ProductSearch> {
  String slug = '';
  TextEditingController _controller;
  List<SearchProduct> searchProducts = [];
  bool _isLoading = false;
  Product tappedProduct = Product();
  final int perPage = TWENTY;
  int currentPage = ONE;
  int subCatId = ZERO;
  bool isSearched = false;
  Size _deviceSize;
  static const int PAGE_SIZE = 20;
  final scrollController = ScrollController();
  bool hasMore = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Category> _listViewData = [];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentItem;
  Map<dynamic, dynamic> responseBody;
  List<Brand> brands = [];
  List<Product> productsByBrand = [];
  List filterItems = [
    "Newest",
    "Avg.Customer Review",
    "Most Reviews",
    "A TO Z",
    "Z TO A"
  ];
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in filterItems) {
      items.add(new DropdownMenuItem(
          value: city,
          child: Text(
            city,
            style: TextStyle(color: Colors.black),
          )));
    }
    return items;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentItem = _dropDownMenuItems[0].value;
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        searchProduct();
      }
    });
    getBrandsList();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          bottom: PreferredSize(
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.green,
                  ),
                  // margin: EdgeInsets.all(10),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 49,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  margin: EdgeInsets.all(10),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        slug = value;
                      });
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: 'Find the best for your pet...',
                        border: InputBorder.none,
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 18)),
                  ),
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      isSearched = true;
                      searchProducts = [];
                      currentPage = 1;
                      searchProduct();
                    },
                  ),
                )
              ],
            ),
            preferredSize: Size.fromHeight(20),
          ),
        ),
        endDrawer: filterDrawer(),
        body: Stack(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator()
                : isSearched
                    ? Theme(
                        data: ThemeData(primarySwatch: Colors.green),
                        child: ListView.builder(
                            controller: scrollController,
                            itemCount: searchProducts.length + 1,
                            itemBuilder: (context, index) {
                              if (index < searchProducts.length) {
                                return favoriteCard(
                                    context, searchProducts[index], index);
                              }
                              if (hasMore && searchProducts.length == 0) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 50.0),
                                  child: Center(
                                    child: Text(
                                      'No Product Found',
                                      style: TextStyle(fontSize: 20.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              if (!hasMore) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else {
                                return Container();
                              }
                            }),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.green,
                        ),
                      ),
            Container(
              padding: EdgeInsets.only(right: 20.0, top: 15.0),
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                onPressed: () {
                  _scaffoldKey.currentState.openEndDrawer();
                },
                child: Icon(
                  Icons.filter_list,
                  color: Colors.white,
                ),
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ));
  }

  Widget favoriteCard(BuildContext context, SearchProduct product, int index) {
    return GestureDetector(
        onTap: () {
          getProductDetail(product);
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
                    child: product.image != null
                        ? FadeInImage(
                            image: NetworkImage(product.image),
                            placeholder: AssetImage(
                                'images/placeholders/no-product-image.png'),
                          )
                        : Image.asset(
                            'images/placeholders/no-product-image.png'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            product.name,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Text(
                            product.currencySymbol + product.price,
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

  getProductDetail(SearchProduct searchProduct) async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();
    print('GETTING DETAILS');
    setState(() {
      _isLoading = true;
    });
    http.Response response = await http.get(
        Settings.SERVER_URL +
            'api/v1/products/${searchProduct.slug}?data_set=large',
        headers: headers);

    responseBody = json.decode(response.body);
    print('------------IMAGE URL RECEIVED----------');
    print(responseBody['data']['included']['master']['data']['included']
        ['images'][0]['data']['attributes']['product_url']);
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
    print('PRODUCT IS');
    print(tappedProduct);
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => ProductDetailScreen(tappedProduct));
    Navigator.push(context, route);
  }

  Future<List<SearchProduct>> searchProduct([String sortBy]) async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();
    print('SENDING REQUEST');
    setState(() {
      hasMore = false;
    });
    http.Response response;
    if (sortBy != null) {
      response = await http.get(
          Settings.SERVER_URL +
              'api/v1/products?q[name_cont_all]=$slug&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small',
          headers: headers);
    } else {
      response = await http.get(
          Settings.SERVER_URL +
              'api/v1/products?q[name_cont_all]=$slug&page=$currentPage&per_page=$perPage&data_set=small',
          headers: headers);
    }
    currentPage++;
    responseBody = json.decode(response.body);
    print('------------SEARCH RESPONSE----------');
    print(responseBody);
    responseBody['data'].forEach((favoriteObj) {
      print(favoriteObj['attributes']['slug']);

      searchProducts.add(SearchProduct(
          name: favoriteObj['attributes']['name'],
          image: favoriteObj['attributes']['product_url'],
          price: favoriteObj['attributes']['price'],
          currencySymbol: favoriteObj['attributes']['currency_symbol'],
          slug: favoriteObj['attributes']['slug']));
    });
    setState(() {
      hasMore = true;
    });

    return searchProducts;
  }

  Widget filterDrawer() {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Material(
            elevation: 3.0,
            child: Container(
                alignment: Alignment.centerLeft,
                color: Colors.orange,
                height: 180.0,
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        'Sort By:  ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18.0),
                      ),
                      DropdownButton(
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                        value: _currentItem,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        items: _dropDownMenuItems,
                        onChanged: changedDropDownItem,
                      )
                    ],
                  ),
                )),
          ),
          Expanded(
            child: Theme(
                data: ThemeData(primarySwatch: Colors.green),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          productsByBrand = [];
                          setState(() {
                            //_isLoading = true;
                            slug = brands[index].name;
                            isSearched = true;
                            searchProducts = [];
                            currentPage = 1;
                            searchProduct();
                          });
                        },
                        child: Container(
                            width: _deviceSize.width,
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            child: Text(
                              brands[index].name,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            )));
                  },
                  itemCount: brands.length,
                )),
          ),
        ],
      ),
    );
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
    });
  }

  void changedDropDownItem(String selectedCity) {
    String sortingWith = '';
    setState(() {
      _currentItem = selectedCity;
      switch (_currentItem) {
        case 'Newest':
          sortingWith = 'updated_at+asc';
          break;
        case 'Avg.Customer Review':
          sortingWith = 'avg_rating+desc ';
          break;
        case 'Most Reviews':
          sortingWith = 'reviews_count+desc';
          break;
        case 'A TO Z':
          sortingWith = 'name+asc';
          break;
        case 'Z TO A':
          sortingWith = 'name+desc';
          break;
      }
      isSearched = true;
      searchProducts = [];
      currentPage = 1;
      searchProduct(sortingWith);
    });
  }
}

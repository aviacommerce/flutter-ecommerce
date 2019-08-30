import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/models/brand.dart';
import 'package:ofypets_mobile_app/models/category.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';
import 'package:ofypets_mobile_app/widgets/product_container.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductSearch extends StatefulWidget {
  final String slug;
  ProductSearch({this.slug});
  @override
  State<StatefulWidget> createState() {
    return _ProductSearchState();
  }
}

class _ProductSearchState extends State<ProductSearch> {
  String slug = '';
  TextEditingController _controller;
  // List<SearchProduct> searchProducts = [];
  List<Product> searchProducts = [];
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
    if (widget.slug != null) {
      print("SLUG AVAILABLE ${widget.slug}");
      setState(() {
        slug = widget.slug;
        isSearched = true;
        searchProducts = [];
        currentPage = 1;
      });
      searchProduct();
    }
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        searchProduct();
      }
    });
    getBrandsList();
  }

  @override
  Widget build(BuildContext mainContext) {
    _deviceSize = MediaQuery.of(mainContext).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            bottom: PreferredSize(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30.0,
                    child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  Container(
                    width: MediaQuery.of(mainContext).size.width - 40.0,
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(mainContext).size.width,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.green,
                          ),
                          // margin: EdgeInsets.all(10),
                        ),
                        Container(
                          width: MediaQuery.of(mainContext).size.width,
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
                              FocusScope.of(mainContext)
                                  .requestFocus(new FocusNode());

                              isSearched = true;
                              searchProducts = [];
                              currentPage = 1;
                              searchProduct();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              preferredSize: Size.fromHeight(20),
            ),
          ),
          endDrawer: filterDrawer(),
          body: Stack(
            children: <Widget>[
              model.isLoading
                  ? LinearProgressIndicator()
                  : isSearched
                      ? Theme(
                          data: ThemeData(primarySwatch: Colors.green),
                          child: ListView.builder(
                              controller: scrollController,
                              itemCount: searchProducts.length + 1,
                              itemBuilder: (mainContext, index) {
                                if (index < searchProducts.length) {
                                  // return favoriteCard(
                                  //     context, searchProducts[index], index);
                                  return productContainer(
                                      _scaffoldKey.currentContext,
                                      searchProducts[index],
                                      index);
                                }
                                if (hasMore && searchProducts.length == 0) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 50.0),
                                    child: Center(
                                      child: Text(
                                        'No Product Found',
                                        style: TextStyle(fontSize: 20.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }
                                if (!hasMore || model.isLoading) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 25.0),
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      backgroundColor: Colors.green,
                                    )),
                                  );
                                } else {
                                  return Container();
                                }
                              }),
                        )
                      : Container(),
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
    });
  }

  Future<List<Product>> searchProduct([String sortBy]) async {
    Map<String, String> headers = await getHeaders();
    Map<String, dynamic> responseBody = Map();
    print('SENDING REQUEST $slug');
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
      print("searching $slug");
      response = await http.get(
          Settings.SERVER_URL +
              'api/v1/products?q[name_cont_all]=$slug&page=$currentPage&per_page=$perPage&data_set=small',
          headers: headers);
    }
    currentPage++;
    responseBody = json.decode(response.body);
    print("got response");
    print(responseBody);
    responseBody['data'].forEach((searchObj) {
      searchProducts.add(Product(
          reviewProductId: searchObj['id'],
          name: searchObj['attributes']['name'],
          image: searchObj['attributes']['product_url'],
          displayPrice: searchObj['attributes']['currency_symbol'] +
              searchObj['attributes']['price'],
          slug: searchObj['attributes']['slug'],
          avgRating: double.parse(searchObj['attributes']['avg_rating']),
          reviewsCount: searchObj['attributes']['reviews_count'].toString()));
    });
    setState(() {
      hasMore = true;
      _isLoading = false;
    });

    print(hasMore);
    print(searchProducts.length);

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
                            _isLoading = true;
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

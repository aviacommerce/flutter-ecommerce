import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ofypets_mobile_app/models/category.dart';
import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/search.dart';
import 'package:ofypets_mobile_app/utils/color_list.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/drawer_homescreen.dart';
import 'package:ofypets_mobile_app/utils/locator.dart';
import 'package:ofypets_mobile_app/widgets/product_container.dart';
import 'package:ofypets_mobile_app/widgets/shopping_cart_button.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ofypets_mobile_app/utils/headers.dart';

class CategoryListing extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  final int parentId;

  CategoryListing(this.categoryName, this.categoryId, this.parentId);
  @override
  State<StatefulWidget> createState() {
    return _CategoryListingState();
  }
}

class _CategoryListingState extends State<CategoryListing> {
  Size _deviceSize;
  bool _isLoading = true;
  int level = 0;
  static const int PAGE_SIZE = 20;
  List<Category> categoryList = [];
  List<Category> subCategoryList = [];
  List<Product> productsByCategory = [];
  List<Widget> header = [];
  final int perPage = TWENTY;
  int currentPage = ONE;
  int subCatId = ZERO;
  int currentIndex = -1;
  int totalCount = 0;
  List<Widget> subCatList = [];
  final scrollController = ScrollController();
  bool hasMore = false, isFilterDataLoading = false;
  bool isChecked = false;
  List<Category> filterSubCategoryList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(); // ADD THIS LINE
  Map<dynamic, dynamic> responseBody;
  List<Category> _listViewData = [];
  String sortBy = '';
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentItem;
  String _currentCategory = '';
  int _currentCatIndex;
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
            // style: TextStyle(color: Colors.red),
          )));
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    sortBy = '';
    _dropDownMenuItems = getDropDownMenuItems();
    _currentItem = _dropDownMenuItems[0].value;
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        getProductsByCategory();
      }
    });
    header
        .add(textField(widget.categoryName, FontWeight.w100, 0, Colors.white));
    getCategory();
    locator<ConnectivityManager>().initConnectivity(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectivityManager>().dispose();
  }

  void getSubCatList(int categoryId, String catName) async {
    setState(() {
      isFilterDataLoading = true;
    });
    if (currentIndex >= 0) {
      _listViewData = [];
      await http
          .get(Settings.SERVER_URL +
              'api/v1/taxonomies/${widget.parentId}/taxons/$categoryId')
          .then((response) {
        responseBody = json.decode(response.body);
        responseBody['taxons'].forEach((category) {
          _listViewData.add(Category(
            id: category['id'],
            name: category['name'],
            parentId: widget.parentId,
          ));
        });
      });
    }
    List<Widget> subCatList = [];
    for (Category cat in _listViewData) {
      print('Data');
      subCatList.add(InkWell(
        onTap: () {
          setState(() {
            productsByCategory = [];
            subCatId = cat.id;
            Navigator.pop(context);
            adjustHeaders(cat.name);
            loadProductsByCategory();
          });
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(cat.name),
            ),
            Divider(),
          ],
        ),
      ));
    }
    setState(() {
      isFilterDataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return WillPopScope(
        onWillPop: () => _canLeave(),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Shop'),
              elevation: 0.0,
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
            ),
            drawer: HomeDrawer(),
            endDrawer: filterDrawer(),
            body: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 59.0),
                  child: !_isLoading ? body(level) : Container(),
                ),
                Container(
                  color: Colors.green,
                  height: 59.0,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          left: 70,
                        ),
                        height: 30.0,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              headerRow(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 59.0),
                  child: model.isLoading || _isLoading
                      ? LinearProgressIndicator()
                      : Container(),
                ),
                level == 2
                    ? Container(
                        padding: EdgeInsets.only(right: 20.0, top: 30.0),
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
                      )
                    : Container(),
              ],
            )),
      );
    });
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
                height: 150.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
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
                            underline: Container(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal),
                            value: null,
                            hint: Text(
                              _currentItem,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  ),
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white60,
                            ),
                            items: _dropDownMenuItems,
                            onChanged: changedDropDownItem,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                      child: Text(
                        '$totalCount Results',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )),
          ),
          categoryDropDown(),
          Divider(
            height: 1.0,
            color: Colors.grey,
            indent: 10.0,
          ),
        ],
      ),
    );
  }

  Widget categoryDropDown() {
    return Expanded(
      child: Theme(
        data: ThemeData(primarySwatch: Colors.green),
        child: ListView(
          children: [
            ExpansionTile(
                initiallyExpanded: true,
                onExpansionChanged: (value) {
                  if (value) {}
                },
                title: Text(_currentCategory),
                children: subCatList)
          ],
        ),
      ),
    );
  }

  List<Widget> progressBar() {
    List<Widget> progressBar = [];
    progressBar.add(
      CircularProgressIndicator(
        backgroundColor: Colors.white,
      ),
    );
    return progressBar;
  }

  List<Widget> emptyWidget() {
    List<Widget> widgetList = [];
    widgetList.add(Container());
    return widgetList;
  }

  Widget body(int level) {
    switch (level) {
      case 0:
        return (categoryList.length == 0)
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: Center(
                  child: Text(
                    'No Product Found',
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    return getCategoryBox(index, level);
                  },
                  itemCount: categoryList.length,
                ),
              );

        break;
      case 1:
        return (subCategoryList.length == 0)
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: Center(
                  child: Text(
                    'No Product Found',
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    return getCategoryBox(index, level);
                  },
                  itemCount: subCategoryList.length,
                ),
              );

        break;
      case 2:
        return Theme(
          data: ThemeData(primarySwatch: Colors.green),
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: ListView.builder(
                controller: scrollController,
                itemCount: productsByCategory.length + 1,
                itemBuilder: (context, index) {
                  if (index < productsByCategory.length) {
                    return productContainer(
                        context, productsByCategory[index], index);
                  }
                  if (hasMore && productsByCategory.length == 0) {
                    print("LENGTH 00000000");
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
                          child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      )),
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
        );
        break;
      default:
        return Container();
    }
  }

  Widget headerRow() {
    return Row(
      children: header,
    );
  }

  Widget textField(
      String text, FontWeight fontWeight, int categoryLevel, Color textColor) {
    int sublevel;
    print("LEVEL ${level == 2} BUILDING TEXTFIELD $text");

    return GestureDetector(
        onTap: () {
          sublevel = level - categoryLevel;
          setState(() {
            for (int i = 0; i < sublevel; i++) {
              header.removeLast();
            }
            level = level - sublevel;
          });
          print("LEVEL $level BUILDING TEXTFIELD $text");
        },
        child: Text(
          text,
          style: TextStyle(
              color: level == 2 ? Colors.white : Colors.white60,
              fontSize: 18,
              fontWeight: level == 2 ? FontWeight.w500 : fontWeight),
        ));
  }

  Widget getCategoryBox(int index, int level) {
    return GestureDetector(
        onTap: () {
          if (level == 0) {
            getSubCategory(categoryList[index].id);
            setState(() {
              _currentCategory = categoryList[index].name;
              _currentCatIndex = categoryList[index].id;
              header.add(Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white60,
                        size: 16,
                      )),
                  textField(categoryList[index].name, FontWeight.w100, 1,
                      Colors.white)
                ],
              ));
            });
          } else {
            subCatId = subCategoryList[index].id;
            loadProductsByCategory();
            setState(() {
              header.add(Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white60,
                        size: 16,
                      )),
                  textField(subCategoryList[index].name, FontWeight.w100, 2,
                      Colors.white)
                ],
              ));
            });
          }
        },
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          width: _deviceSize.width * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: colorList[index],
          ),
          child: Text(
            level == 0 ? categoryList[index].name : subCategoryList[index].name,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ));
  }

  void adjustHeaders(String subCatName) {
    setState(() {
      header.removeLast();
      setState(() {
        header.add(Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white60,
                  size: 16,
                )),
            textField(subCatName, FontWeight.w100, 2, Colors.white)
          ],
        ));
      });
    });
  }

  getCategory() {
    categoryList = [];
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies/${widget.parentId}/taxons/${widget.categoryId}')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxons'].forEach((category) {
        categoryList.add(Category(
            id: category['id'],
            name: category['name'],
            parentId: widget.parentId));
      });
      setState(() {
        _isLoading = false;
        level = 0;
      });
    });
  }

  getSubCategory(int categoryId) {
    setState(() {
      _isLoading = true;
      isFilterDataLoading = true;
      subCategoryList = [];
      subCatList = [];
    });
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies/${widget.parentId}/taxons/$categoryId')
        .then((response) {
      responseBody = json.decode(response.body);
      print(responseBody);
      responseBody['taxons'].forEach((category) {
        subCategoryList.add(Category(
            id: category['id'],
            name: category['name'],
            parentId: widget.parentId));
      });
      for (Category cat in subCategoryList) {
        subCatList.add(InkWell(
          onTap: () {
            setState(() {
              productsByCategory = [];
              subCatId = cat.id;
              Navigator.pop(context);
              adjustHeaders(cat.name);
              loadProductsByCategory();
            });
          },
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(cat.name),
              ),
              // Divider(),
            ],
          ),
        ));
      }
      setState(() {
        level = 1;
        _isLoading = false;
        isFilterDataLoading = false;
      });
    });
  }

  void getProductsByCategory() async {
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    Map<String, String> headers = await getHeaders();
    print(
        "CATEGORY URL + ${Settings.SERVER_URL + 'api/v1/taxons/products?id=$subCatId&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small'}");
    setState(() {
      hasMore = false;
    });
    var response;

    if (sortBy != null && sortBy.length > 0) {
      response = (await http.get(
              Settings.SERVER_URL +
                  'api/v1/taxons/products?id=$subCatId&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small',
              headers: headers))
          .body;
    } else {
      response = (await http.get(
              Settings.SERVER_URL +
                  'api/v1/taxons/products?id=$subCatId&page=$currentPage&per_page=$perPage&data_set=small',
              headers: headers))
          .body;
    }
    print(Settings.SERVER_URL +
        'api/v1/taxons/products?id=$subCatId&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small');
    currentPage++;
    responseBody = json.decode(response);
    print(responseBody);
    totalCount = responseBody['pagination']['total_count'];
    responseBody['data'].forEach((product) {
      productsByCategory.add(Product(
          reviewProductId: product['id'],
          name: product['attributes']['name'],
          image: product['attributes']['product_url'],
          currencySymbol: product['attributes']['currency_symbol'],
          displayPrice: product['attributes']['currency_symbol'] +
              product['attributes']['price'],
          price: product['attributes']['price'],
          costPrice: product['attributes']['cost_price'],
          slug: product['attributes']['slug'],
          avgRating: double.parse(product['attributes']['avg_rating']),
          reviewsCount: product['attributes']['reviews_count'].toString()));
    });

    setState(() {
      hasMore = true;
    });
  }

  void loadProductsByCategory([String sortBy]) {
    setState(() {
      currentPage = ONE;
      productsByCategory = [];
      this.sortBy = sortBy;
      getProductsByCategory();
      level = 2;
      _isLoading = false;
    });
  }

  Future<bool> _canLeave() {
    if (level == 0) {
      return Future<bool>.value(true);
    } else {
      setState(() {
        level = level - 1;
        header.removeLast();
      });
      return Future<bool>.value(false);
    }
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

      loadProductsByCategory(sortingWith);
    });
  }
}

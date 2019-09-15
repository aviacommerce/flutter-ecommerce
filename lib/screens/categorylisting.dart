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
  Map<int, List<Widget>> subCatListForFilter = Map();
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
    super.initState();
    sortBy = '';
    _dropDownMenuItems = getDropDownMenuItems();
    _currentItem = _dropDownMenuItems[0].value;
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        getProductsByCategory(0);
      }
    });
    header.add(
        textField(widget.categoryName, FontWeight.normal, 0, Colors.white));
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
        print(responseBody);
        responseBody['taxons'].forEach((category) {
          _listViewData.add(Category(
              id: category['id'],
              name: category['name'],
              parentId: widget.parentId,
              isChecked: false));
        });
      });
      print("SUBCAT LENGTH +$_listViewData");
    }
    print(_listViewData);
    List<Widget> subCatList = [];
    for (Category cat in _listViewData) {
      print('Data');
      subCatList.add(InkWell(
        onTap: () {
          setState(() {
            productsByCategory = [];
            cat.isChecked = cat.isChecked ? false : true;
            subCatId = cat.id;
            Navigator.pop(context);
            adjustHeaders(catName, cat.name);
            loadProductsByCategory();
          });
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(cat.name),
              /*trailing: cat.isChecked
                ? Icon(
                    Icons.radio_button_checked,
                    color: Colors.green,
                  )
                : Icon(Icons.radio_button_unchecked),*/
            ),
            Divider(),
          ],
        ),
      ));
    }
    setState(() {
      subCatListForFilter[currentIndex] = subCatList;
      isFilterDataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(level != 0 && subCategoryList.length == 0);
    print("LEVEL -----> $level");
    print("SUBCAT LENGTH -----> ${subCategoryList.length}");
    print("CAT LENGTH -----> ${categoryList.length}");

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
          Expanded(
            child: Theme(
                data: ThemeData(primarySwatch: Colors.green),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  separatorBuilder: (context, index) => Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return ExpansionTile(
                        onExpansionChanged: (value) {
                          if (value) {
                            // widget.getSubCat(index);
                            currentIndex = index;
                            getSubCatList(categoryList[index].id,
                                categoryList[index].name);
                          }
                        },
                        title: Text(categoryList[index].name),
                        children: subCatListForFilter[index] != null
                            ? subCatListForFilter[index]
                            : isFilterDataLoading
                                ? progressBar()
                                : subCatListForFilter[index] != null
                                    ? subCatListForFilter[index]
                                    : emptyWidget());
                  },
                  itemCount: categoryList != null ? categoryList.length : 0,
                )),
          ),
          Divider(
            height: 1.0,
            color: Colors.grey,
            indent: 10.0,
          ),
        ],
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
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(
                    indent: 150.0,
                    color: Colors.grey.shade400,
                    height: 1.0,
                  );
                },
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

    return GestureDetector(
        onTap: () {
          sublevel = level - categoryLevel;
          setState(() {
            for (int i = 0; i < sublevel; i++) {
              header.removeLast();
            }
            level = level - sublevel;
          });
        },
        child: Text(
          text,
          style:
              TextStyle(color: textColor, fontSize: 18, fontWeight: fontWeight),
        ));
  }

  Widget getCategoryBox(int index, int level) {
    return GestureDetector(
        onTap: () {
          if (level == 0) {
            getSubCategory(categoryList[index].id);
            setState(() {
              header.add(Row(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      )),
                  textField(categoryList[index].name, FontWeight.normal, 1,
                      Colors.white)
                ],
              ));
              // header.add(Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 12),
              //     child: Icon(
              //       Icons.arrow_forward_ios,
              //       color: Colors.white,
              //       size: 16,
              //     )));
              // header.add(textField(categoryList[index].name, FontWeight.normal,
              //     1, Colors.white));
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
                        color: Colors.white,
                        size: 16,
                      )),
                  textField(subCategoryList[index].name, FontWeight.normal, 2,
                      Colors.white)
                ],
              ));
              // header.add(Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 12),
              //     child: Icon(
              //       Icons.arrow_forward_ios,
              //       color: Colors.white,
              //       size: 16,
              //     )));
              // header.add(textField(subCategoryList[index].name,
              //     FontWeight.normal, 2, Colors.white));
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
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ));
  }

  void adjustHeaders(String catName, String subCatName) {
    setState(() {
      header.removeLast();
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
      //print(Settings.SERVER_URL + 'api/v1/taxonomies/${widget.parentId}/taxons/${widget.categoryId}');
      setState(() {
        _isLoading = false;
        level = 0;
      });
    });
  }

  getSubCategory(int categoryId) {
    setState(() {
      _isLoading = true;
      subCategoryList = [];
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
      setState(() {
        level = 1;
        _isLoading = false;
      });
    });
  }

  void getProductsByCategory(int id) async {
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    print(
        "CATEGORY URL + ${Settings.SERVER_URL + 'api/v1/taxons/products?id=$subCatId&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small'}");
    setState(() {
      hasMore = false;
    });
    var response;
    print(sortBy);
    if (sortBy != null && sortBy.length > 0) {
      response = (await http.get(Settings.SERVER_URL +
              'api/v1/taxons/products?id=$subCatId&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small'))
          .body;
    } else {
      response = (await http.get(Settings.SERVER_URL +
              'api/v1/taxons/products?id=$subCatId&page=$currentPage&per_page=$perPage&data_set=small'))
          .body;
    }
    print(Settings.SERVER_URL +
        'api/v1/taxons/products?id=$subCatId&page=$currentPage&per_page=$perPage&q[s]=$sortBy&data_set=small');
    currentPage++;
    responseBody = json.decode(response);
    print(responseBody);
    totalCount = responseBody['total_count'];
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
                slug: variant['slug'],
                id: variant['id'],
                price: variant['price'],
                name: variant['name'],
                description: variant['description'],
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
          productsByCategory.add(Product(
              slug: product['slug'],
              taxonId: product['taxon_ids'].first,
              id: product['id'],
              name: product['name'],
              price: product['price'],
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
          productsByCategory.add(Product(
            slug: product['slug'],
            taxonId: product['taxon_ids'].first,
            id: product['id'],
            name: product['name'],
            price: product['price'],
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
      hasMore = true;
    });
  }

  void loadProductsByCategory([String sortBy]) {
    setState(() {
      currentPage = ONE;
      productsByCategory = [];
      this.sortBy = sortBy;
      getProductsByCategory(0);
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

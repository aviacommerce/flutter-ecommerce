import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ofypets_mobile_app/utils/drawer_homescreen.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/color_list.dart';
import 'package:ofypets_mobile_app/models/category.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/widgets/product_container.dart';
import 'package:ofypets_mobile_app/widgets/shopping_cart_button.dart';
import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';

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
  List<Category> categoryList = [];
  List<Category> subCategoryList = [];
  List<Product> productsByCategory = [];
  List<Widget> header = [];
  Map<dynamic, dynamic> responseBody;
  @override
  void initState() {
    super.initState();
    header.add(textField(widget.categoryName, FontWeight.bold, 0));
    getCategory();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => _canLeave(),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Shop'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
              shoppingCartIconButton()
            ],
            bottom: PreferredSize(
              preferredSize: Size(_deviceSize.width, 40),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      left: 70,
                      bottom: 20,
                    ),
                    alignment: Alignment.centerLeft,
                    child: headerRow(),
                  ),
                  _isLoading ? LinearProgressIndicator() : Container()
                ],
              ),
            ),
          ),
          drawer: HomeDrawer(),
          body: !_isLoading ? body(level) : Container()),
    );
  }

  Widget body(int level) {
    switch (level) {
      case 0:
        return GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            return getCategoryBox(index, level);
          },
          itemCount: categoryList.length,
        );
        break;
      case 1:
        return GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            return getCategoryBox(index, level);
          },
          itemCount: subCategoryList.length,
        );
        break;
      case 2:
        return ListView.builder(
          itemCount: productsByCategory.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
                onTap: () {},
                child: productContainer(productsByCategory[index], context));
          },
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

  Widget textField(String text, FontWeight fontWeight, int categoryLevel) {
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
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: fontWeight),
        ));
  }

  Widget getCategoryBox(int index, int level) {
    return GestureDetector(
        onTap: () {
          if (level == 0) {
            getSubCategory(categoryList[index].id);
            setState(() {
              header.add(textField(
                  ' > ' + categoryList[index].name, FontWeight.bold, 1));
            });
          } else {
            getProductsByCategory(subCategoryList[index].id);
            setState(() {
              header.add(textField(
                  ' > ' + subCategoryList[index].name, FontWeight.bold, 2));
            });
          }
        },
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(10),
          width: _deviceSize.width * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
      subCategoryList = [];
    });
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies/${widget.parentId}/taxons/$categoryId')
        .then((response) {
      responseBody = json.decode(response.body);
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

  getProductsByCategory(int id) {
    List<Product> variants = [];
    List<OptionValue> optionValues = [];
    List<OptionType> optionTypes = [];
    setState(() {
      _isLoading = true;
      productsByCategory = [];
    });
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxons/products?id=$id&per_page=20&data_set=small')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['products'].forEach((product) {
        int review_product_id = product["id"];
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
                  id: variant['id'],
                  name: variant['name'],
                  description: variant['description'],
                  optionValues: optionValues,
                  displayPrice: variant['display_price'],
                  image: variant['images'][0]['product_url'],
                  isOrderable: variant['is_orderable'],
                  avgRating: double.parse(product['avg_rating']),
                  reviewsCount: product['reviews_count'].toString(),
                  reviewProductId: review_product_id));
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
                taxonId: product['taxon_ids'].first,
                id: product['id'],
                name: product['name'],
                displayPrice: product['display_price'],
                avgRating: double.parse(product['avg_rating']),
                reviewsCount: product['reviews_count'].toString(),
                image: product['master']['images'][0]['product_url'],
                variants: variants,
                reviewProductId: review_product_id,
                hasVariants: product['has_variants'],
                optionTypes: optionTypes));
          });
        } else {
          setState(() {
            productsByCategory.add(Product(
              taxonId: product['taxon_ids'].first,
              id: product['id'],
              name: product['name'],
              displayPrice: product['display_price'],
              avgRating: double.parse(product['avg_rating']),
              reviewsCount: product['reviews_count'].toString(),
              image: product['master']['images'][0]['product_url'],
              hasVariants: product['has_variants'],
              isOrderable: product['master']['is_orderable'],
              reviewProductId: review_product_id,
              description: product['description'],
            ));
          });
        }
      });
      setState(() {
        level = 2;
        _isLoading = false;
      });
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
}

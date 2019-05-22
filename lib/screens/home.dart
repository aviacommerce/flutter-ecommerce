import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

import 'package:ofypets_mobile_app/utils/drawer_homescreen.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/utils/color_list.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/models/category.dart';
import 'package:ofypets_mobile_app/screens/auth.dart';
import 'package:ofypets_mobile_app/screens/brandslisting.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/screens/categorylisting.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  Size _deviceSize;
  Map<dynamic, dynamic> responseBody;
  bool _isBannerLoading = true;
  bool _isCategoryLoading = true;
  bool _isDealsLoading = true;
  bool _isAuthenticated = false;
  List<Product> todaysDealProducts = [];
  List<Category> categories = [];
  List<String> bannerImageUrls = [];

  @override
  void initState() {
    super.initState();
    getBanners();
    getCategories();
    getTodaysDeals();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    Widget bannerCarousel = CarouselSlider(
      items: <Widget>[
        bannerCards(0),
        bannerCards(1),
        bannerCards(2),
        bannerCards(3),
        bannerCards(4),
      ],
      autoPlay: true,
      enlargeCenterPage: true,
    );
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'ofypets',
            style: TextStyle(fontFamily: 'HolyFat', fontSize: 50),
          ),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: _deviceSize.width * 0.01),
                child: Icon(
                  Icons.shopping_cart,
                  semanticLabel: 'Shopping Cart',
                ))
          ],
          bottom: PreferredSize(
            preferredSize: Size(_deviceSize.width, 50),
            child: Container(
              width: _deviceSize.width,
              height: 50,
              margin: EdgeInsets.all(10),
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.search),
                title: Text(
                  'Find the best for your pet...',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
            ),
          )),
      drawer: HomeDrawer(),
      body: CustomScrollView(slivers: [
        SliverList(
          delegate: SliverChildListDelegate([bannerCarousel]),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
                width: _deviceSize.width,
                color: Colors.white,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.category,
                    color: Colors.blue,
                  ),
                  title: Text('Categories',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue)),
                ))
          ]),
        ),
        _isCategoryLoading
            ? SliverList(
                delegate: SliverChildListDelegate([
                Container(
                  height: _deviceSize.height * 0.5,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  ),
                )
              ]))
            : SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return categoryBox(index);
                }, childCount: categories.length + 1),
              ),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
                width: _deviceSize.width,
                color: Colors.white,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.today,
                    color: Colors.deepOrange,
                  ),
                  title: Text('Today\'s Deals',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange)),
                ))
          ]),
        ),
        _isDealsLoading
            ? SliverList(
                delegate: SliverChildListDelegate([
                Container(
                  height: _deviceSize.height * 0.5,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  ),
                )
              ]))
            : SliverToBoxAdapter(
                child: Container(
                  height: _deviceSize.height * 0.5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return todaysDealsCard(index);
                    },
                  ),
                ),
              ),
        SliverToBoxAdapter(
          child: Divider(),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              width: _deviceSize.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              alignment: Alignment.centerRight,
              child: Text(
                'SEE ALL',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            )
          ]),
        ),
      ]),
      bottomNavigationBar: !_isAuthenticated
          ? BottomNavigationBar(
              onTap: (index) {
                MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => Authentication(index));

                Navigator.push(context, route);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, color: Colors.green),
                  title: Text('SIGN IN'),
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person_outline,
                      color: Colors.green,
                    ),
                    title: Text('CREATE ACCOUNT',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                            fontWeight: FontWeight.w600))),
              ],
            )
          : null,
    );
  }

  Widget bannerCards(int index) {
    if (_isBannerLoading) {
      return Container(
        width: _deviceSize.width * 0.8,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 2,
          margin: EdgeInsets.symmetric(
              vertical: _deviceSize.height * 0.05,
              horizontal: _deviceSize.width * 0.02),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: Image.asset(
                'images/placeholders/slider1.jpg',
                fit: BoxFit.fill,
              )),
        ),
      );
    } else {
      return Container(
        width: _deviceSize.width * 0.8,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 2,
          margin: EdgeInsets.symmetric(
              vertical: _deviceSize.height * 0.05,
              horizontal: _deviceSize.width * 0.02),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: FadeInImage(
              image: NetworkImage(bannerImageUrls[index]),
              placeholder: AssetImage('images/placeholders/slider1.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    }
  }

  Widget todaysDealsCard(int index) {
    return SizedBox(
        width: _deviceSize.width * 0.4,
        child: Card(
          borderOnForeground: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FadeInImage(
                image: NetworkImage(todaysDealProducts[index].image),
                placeholder:
                    AssetImage('images/placeholders/no-product-image.png'),
                height: _deviceSize.height * 0.2,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: Text(
                  todaysDealProducts[index].name,
                  maxLines: 3,
                ),
              ),
              Text(
                todaysDealProducts[index].displayPrice,
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ratingBar(todaysDealProducts[index].avgRating, 20),
                  Text(todaysDealProducts[index].reviewsCount),
                ],
              ),
              Divider(),
              Text(
                'ADD TO CART',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ));
  }

  Widget categoryBox(int index) {
    if (index > 4) {
      return GestureDetector(
          onTap: () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => BrandList());
            Navigator.push(context, route);
          },
          child: Container(
              margin: EdgeInsets.all(10.0),
              width: _deviceSize.width * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorList[index],
              ),
              child: Stack(children: [
                Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Shop By Brand',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w700),
                          ),
                          Text('A-Z',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  fontWeight: FontWeight.w700)),
                        ])),
              ])));
    }
    return GestureDetector(
        onTap: () {
          MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => CategoryListing(categories[index].name,
                  categories[index].id, categories[index].parentId));
          Navigator.push(context, route);
        },
        child: Container(
            margin: EdgeInsets.all(10.0),
            width: _deviceSize.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorList[index],
            ),
            child: Stack(children: [
              Container(
                alignment: Alignment.bottomRight,
                child: Image.network(categories[index].image),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  categories[index].name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ])));
  }

  getCategories() async {
    int petsId;
    http.Response response =
        await http.get(Settings.SERVER_URL + 'api/v1/taxonomies?q[name_cont]=Pets');
    responseBody = json.decode(response.body);
    petsId = responseBody['taxonomies'][0]['id'];
    http
        .get(Settings.SERVER_URL + 'api/v1/taxonomies?q[name_cont]=Pets&set=nested')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxonomies'][0]['root']['taxons'].forEach((category) {
        setState(() {
          categories.add(Category(
              parentId: petsId,
              name: category['name'],
              image: category['icon'],
              id: category['id']));
        });
      });
      setState(() {
        _isCategoryLoading = false;
      });
    });
  }

  getTodaysDeals() async {
    String todaysDealsId;
    http.Response response = await http
        .get(Settings.SERVER_URL + 'api/v1/taxonomies?q[name_cont]=Today\'s Deals');
    responseBody = json.decode(response.body);
    todaysDealsId = responseBody['taxonomies'][0]['id'].toString();
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxons/products?id=$todaysDealsId&per_page=10&data_set=small')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['products'].forEach((product) {
        print(product['has_variants']);
        if (product['has_variants']) {
          setState(() {
            todaysDealProducts.add(Product(
                name: product['variants'][0]['name'],
                displayPrice: product['variants'][0]['display_price'],
                avgRating: double.parse(product['avg_rating']),
                reviewsCount: product['reviews_count'].toString(),
                image: product['variants'][0]['images'][0]['product_url']));
          });
        } else {
          setState(() {
            todaysDealProducts.add(Product(
                name: product['name'],
                displayPrice: product['display_price'],
                avgRating: double.parse(product['avg_rating']),
                reviewsCount: product['reviews_count'].toString(),
                image: product['master']['images'][0]['product_url']));
          });
        }
      });
      setState(() {
        _isDealsLoading = false;
      });
    });
  }

  getBanners() async {
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxonomies?q[name_cont]=Landing_Banner&set=nested')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxonomies'][0]['root']['taxons'].forEach((banner) {
        setState(() {
          bannerImageUrls.add(banner['icon']);
        });
      });
      setState(() {
        _isBannerLoading = false;
      });
    });
  }
}

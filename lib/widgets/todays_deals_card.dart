import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/screens/product_detail.dart';
import 'package:ofypets_mobile_app/widgets/snackbar.dart';

class AddToCart extends StatefulWidget {
  List<Product> todaysDealProducts;
   int index;
   Product product;
  AddToCart(this.product, this.index, this.todaysDealProducts);
  @override
  State<StatefulWidget> createState() {
    return _AddToCartState();
  }
}

class _AddToCartState extends State<AddToCart> {
  int selectedIndex;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return FlatButton(
        onPressed: () async {
          print('selectedProductIndex'); print(widget.index);
          setState(() {
            selectedIndex = widget.index;
          });
          if (widget.product.isOrderable) {
            Scaffold.of(context).showSnackBar(processSnackbar);
            model.addProduct(variantId: widget.product.id, quantity: 1);
            if (!model.isLoading) {
              Scaffold.of(context).showSnackBar(completeSnackbar);
            }
          }
        },
        child: !model.isLoading
            ? buttonContent(widget.index, widget.product)
            : widget.index == selectedIndex
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.green,
                  ))
                : buttonContent(widget.index, widget.product),
      );
    });
  }
}

Widget buttonContent(int index, Product product) {
  return Text(
    product.isOrderable ? 'ADD TO CART' : 'OUT OF STOCK',
    style: TextStyle(
        color: product.isOrderable ? Colors.green : Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w500),
  );
}

Widget todaysDealsCard(int index, List<Product> todaysDealProducts,
    Size _deviceSize, BuildContext context) {
  Product displayProduct = todaysDealProducts[index].hasVariants
      ? todaysDealProducts[index].variants.first
      : todaysDealProducts[index];
  return GestureDetector(
      onTap: () {
        MaterialPageRoute addressRoute = MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(todaysDealProducts[index]));
        Navigator.push(context, addressRoute);
      },
      child: SizedBox(
          width: _deviceSize.width * 0.4,
          child: Card(
            borderOnForeground: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FadeInImage(
                  image: NetworkImage(displayProduct.image),
                  placeholder:
                      AssetImage('images/placeholders/no-product-image.png'),
                  // height: _deviceSize.height * 0.2,
                  height: 100,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Text(
                    displayProduct.name,
                    maxLines: 3,
                  ),
                ),
                Text(
                  displayProduct.displayPrice,
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ratingBar(displayProduct.avgRating, 20),
                    Text(displayProduct.reviewsCount),
                  ],
                ),
                Divider(),
                AddToCart(displayProduct, index, todaysDealProducts),
                // addToCartButton(todaysDealProducts, index, displayProduct)
              ],
            ),
          )));
}

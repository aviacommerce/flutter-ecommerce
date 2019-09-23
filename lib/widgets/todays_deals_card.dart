import 'package:flutter/material.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/scoped-models/main.dart';
import 'package:ofypets_mobile_app/widgets/rating_bar.dart';
import 'package:ofypets_mobile_app/widgets/snackbar.dart';
import 'package:scoped_model/scoped_model.dart';

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
        onPressed: widget.product.isOrderable
            ? () async {
                print('selectedProductIndex');
                print(widget.index);
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
              }
            : () {},
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
  return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
    return GestureDetector(
        onTap: () {
          model.getProductDetail(todaysDealProducts[index].slug, context);
        },
        child: SizedBox(
            width: _deviceSize.width * 0.4,
            child: Card(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(4.0)),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(15),
                    child: FadeInImage(
                      image: NetworkImage(displayProduct.image != null
                          ? displayProduct.image
                          : ''),
                      placeholder: AssetImage(
                          'images/placeholders/no-product-image.png'),
                      height: 120,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    padding: EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Text(
                      displayProduct.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 20.0),
                      child: Text(
                        displayProduct.displayPrice,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, top: 20.0, bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ratingBar(displayProduct.avgRating, 20),
                        Text(displayProduct.reviewsCount),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  AddToCart(displayProduct, index, todaysDealProducts),
                ],
              ),
            )));
  });
}

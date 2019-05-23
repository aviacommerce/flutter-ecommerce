import 'package:scoped_model/scoped_model.dart';

import 'package:ofypets_mobile_app/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartModel extends Model {
  List<Product> _lineItems = [];

  List<Product> get lineItems {
    return List.from(_lineItems);
  }

  void addProduct() async {
    print('ADD TO CART');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String orderToken = prefs.getString('orderToken');

    notifyListeners();
  }
}

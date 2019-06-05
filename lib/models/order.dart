import 'package:ofypets_mobile_app/models/line_item.dart';

class Order {
  final int id;
  final String itemTotal;
  final String displayTotal;
  final String displaySubTotal;
  final List<LineItem> lineItems;
  int totalQuantity;
  String shipTotal;
  String state;
  Map<String, dynamic> shipAddress;

  Order(
      {this.id,
      this.displaySubTotal,
      this.displayTotal,
      this.itemTotal,
      this.lineItems,
      this.shipTotal,
      this.totalQuantity,
      this.state,
      this.shipAddress});
}

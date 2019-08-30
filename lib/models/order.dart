import 'package:ofypets_mobile_app/models/line_item.dart';
import 'package:ofypets_mobile_app/models/address.dart';

class Order {
  final int id;
  final String itemTotal;
  final String displayTotal;
  final String displaySubTotal;
  final List<LineItem> lineItems;
  int totalQuantity;
  String shipTotal;
  String state;
  String completedAt, imageUrl, number;
  Address shipAddress;

  Order(
      {this.id,
      this.completedAt,
      this.imageUrl,
      this.number,
      this.displayTotal,
      this.displaySubTotal,
      this.itemTotal,
      this.lineItems,
      this.shipTotal,
      this.totalQuantity,
      this.state,
      this.shipAddress});
}

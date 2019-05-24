import 'package:ofypets_mobile_app/models/variant.dart';

class LineItem {
  final int id;
  int quantity;
  final String total;
  final String displayAmount;
  final int variantId;
  final Variant variant;

  LineItem(
      {this.displayAmount,
      this.id,
      this.quantity,
      this.total,
      this.variant,
      this.variantId});
}

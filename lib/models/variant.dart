class Variant {
  final String image;
  final String displayPrice;
  final int quantity;
  final String name;
  final String costPrice;
  final bool isBackOrderable;
  final int totalOnHand;

  Variant(
      {this.image,
      this.displayPrice,
      this.name,
      this.quantity,
      this.costPrice,
      this.isBackOrderable,
      this.totalOnHand});
}

class Favorite {
  int productId;
  int id;
  String name;
  String image;
  String price;
  String currencySymbol;
  String slug;
  Favorite(
      {this.currencySymbol,
      this.image,
      this.price,
      this.name,
      this.slug,
      this.id,
      this.productId});
}

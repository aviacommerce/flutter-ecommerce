class Product {
  final int id;
  final String title;
  final String name;
  final String displayPrice;
  final String image;
  final double avgRating;
  final String reviewsCount;
  final bool isOrderable;
  final bool hasVariants;
  final List<Product> variants;
  final List<Map<dynamic, dynamic>> optionValues;
  String description;
  
  Product({
    this.id,
    this.title,
    this.name,
    this.displayPrice,
    this.image,
    this.avgRating,
    this.reviewsCount,
    this.isOrderable,
    this.variants,
    this.hasVariants,
    this.description,
    this.optionValues,
  });

}

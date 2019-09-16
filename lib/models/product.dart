import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';

class Product {
  final int id;
  final String slug;
  final int taxonId;
  final String title;
  final String name;
  final String displayPrice;
  final String costPrice;
  final String price;
  final String currencySymbol;
  final String image;
  final double avgRating;
  final String reviewsCount;
  final int totalOnHand;
  final bool isOrderable;
  final bool isBackOrderable;
  final bool hasVariants;
  final List<Product> variants;
  final List<OptionValue> optionValues;
  final List<OptionType> optionTypes;
  String description;
  final int reviewProductId;
  final bool favoritedByUser;

  Product(
      {this.taxonId,
      this.id,
      this.slug,
      this.title,
      this.name,
      this.displayPrice,
      this.costPrice,
      this.price,
      this.image,
      this.avgRating,
      this.reviewsCount,
      this.totalOnHand,
      this.isOrderable,
      this.isBackOrderable,
      this.variants,
      this.hasVariants,
      this.description,
      this.optionValues,
      this.reviewProductId,
      this.optionTypes,
      this.currencySymbol,
      this.favoritedByUser});
}

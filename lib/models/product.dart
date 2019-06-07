import 'package:ofypets_mobile_app/models/option_type.dart';
import 'package:ofypets_mobile_app/models/option_value.dart';

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
  final List<OptionValue> optionValues;
  final List<OptionType> optionTypes;
  String description;
  final int reviewProductId;

  Product(
      {this.id,
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
      this.reviewProductId,
      this.optionTypes});
}

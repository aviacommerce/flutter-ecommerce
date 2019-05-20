import 'package:flutter/material.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Widget ratingBar(double initialRating, double itemSize) {
  return FlutterRatingBar(
    itemCount: 5,
    allowHalfRating: true,
    fillColor: Colors.orange,
    borderColor: Colors.orange,
    ignoreGestures: true,
    initialRating: initialRating,
    onRatingUpdate: (index) {},
    itemSize: itemSize,
  );
}

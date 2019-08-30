import 'package:flutter/material.dart';

final processSnackbar = SnackBar(content: Text('Adding Product to the cart...'), duration: Duration(seconds: 1),);
final completeSnackbar = SnackBar(content: Text('Product Added Successfully!'), duration: Duration(seconds: 1),);
final ErrorSnackbar = SnackBar(content: Text('Please Enter title and review'), duration: Duration(seconds: 1),);
final LoginErroSnackbar = SnackBar(content: Text('Please Login to write review.'), duration: Duration(seconds: 1),);

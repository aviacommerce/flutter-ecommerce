import 'package:scoped_model/scoped_model.dart';
import './cart.dart';
import './user.dart';

class MainModel extends Model with CartModel, UserModel {
}

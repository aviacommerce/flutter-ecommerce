class User {
  String id;
  String email;
  Map billAddress;
  Map shipAddress;

  User({this.billAddress, this.email, this.id, this.shipAddress});
}

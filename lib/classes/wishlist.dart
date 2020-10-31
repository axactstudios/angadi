import 'package:angadi/services/database_helper_wishlist.dart';

class Wishlist {
  int id;
  String productName, imgUrl, price;
//  String details;

  Wishlist(this.id, this.productName, this.imgUrl, this.price);

  Wishlist.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    productName = map['productName'];
    imgUrl = map['imgUrl'];
    price = map['price'];

//    details = map['details'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper2.columnId: id,
      DatabaseHelper2.columnProductName: productName,
      DatabaseHelper2.columnImageUrl: imgUrl,
      DatabaseHelper2.columnPrice: price
//      DatabaseHelper2.columnDetail: details
    };
  }
}

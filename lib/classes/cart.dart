import 'package:angadi/services/database_helper.dart';

class Cart {
  int id;
  String productName, imgUrl, price;
//  String details;
  int qty;

  Cart(this.id, this.productName, this.imgUrl, this.price, this.qty);

  Cart.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    productName = map['productName'];
    imgUrl = map['imgUrl'];
    price = map['price'];
    qty = map['qty'];
//    details = map['details'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnProductName: productName,
      DatabaseHelper.columnImageUrl: imgUrl,
      DatabaseHelper.columnPrice: price,
      DatabaseHelper.columnQuantity: qty,
//      DatabaseHelper.columnDetail: details
    };
  }
}

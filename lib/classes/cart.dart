import 'package:angadi/services/database_helper.dart';

class Cart {
  String id;
  String productName, imgUrl, price, qtyTag;
//  String details;
  int qty;

  Cart(this.id, this.productName, this.imgUrl, this.price, this.qty,
      this.qtyTag);

  Cart.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    productName = map['productName'];
    imgUrl = map['imgUrl'];
    price = map['price'];
    qty = map['qty'];
    qtyTag = map['qtyTag'];
//    details = map['details'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnProductName: productName,
      DatabaseHelper.columnImageUrl: imgUrl,
      DatabaseHelper.columnPrice: price,
      DatabaseHelper.columnQuantity: qty,
      DatabaseHelper.columnQuantityTag: qtyTag
//      DatabaseHelper.columnDetail: details
    };
  }
}

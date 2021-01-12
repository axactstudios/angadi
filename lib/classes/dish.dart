import 'package:angadi/classes/quantity.dart';

class Dish {
  String url;
  String name;
  String desc;
  String category;
  String rating;
  String id;
  String price;
  String iPrice;
  String boughtTogetherID;
  String boughtTogetherDiscount;
  String boughtTogetherQuantity;
  List<Quantity>allquantities=[];

  Dish(
      {this.name,
      this.url,
      this.category,
      this.rating,
      this.id,
      this.price,
      this.iPrice,
      this.desc,
      this.boughtTogetherID,
      this.boughtTogetherDiscount,this.boughtTogetherQuantity,
      this.allquantities});
}

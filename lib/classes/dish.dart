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
      this.boughtTogetherDiscount,this.boughtTogetherQuantity});
}

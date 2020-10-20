import 'package:angadi/classes/dish.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/spaces.dart';

import '../routes/router.dart';

class CategoryDetailScreen extends StatefulWidget {
  CategoryDetailScreen({
    @required this.categoryName,
    @required this.imagePath,
    @required this.numberOfCategories,
    @required this.selectedCategory,
    @required this.gradient,
  });

  final String categoryName;
  final int numberOfCategories;
  final int selectedCategory;
  final String imagePath;
  final Gradient gradient;

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var widthOfScreen = MediaQuery.of(context).size.width;
    var marginBetweenPills = 4;
    var marginAroundPills = 92;
    var margin = marginAroundPills +
        ((widget.numberOfCategories - 1) * marginBetweenPills);
    var widthOfEachPill = (widthOfScreen - margin) / widget.numberOfCategories;
    List<Dish> dishes = new List<Dish>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: <Widget>[
              Positioned(
                child: Image.network(
                  widget.imagePath,
                  width: MediaQuery.of(context).size.width,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                child: Opacity(
                  opacity: 0.85,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: widget.gradient,
                    ),
                  ),
                ),
              ),
              Positioned(
                child: SafeArea(
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () => R.Router.navigator.pop(),
                              child: Image.asset(ImagePath.arrowBackIcon),
                            ),
                            Spacer(flex: 1),
                            Text(
                              widget.categoryName,
                              style: textTheme.title.copyWith(
                                fontSize: Sizes.TEXT_SIZE_22,
                                color: AppColors.white,
                              ),
                            ),
                            Spacer(flex: 1),
                          ],
                        ),
                        SpaceH24(),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: generatePills(
                              numberOfPills: widget.numberOfCategories,
                              widthOfPill: widthOfEachPill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(
          left: Sizes.MARGIN_16,
          right: Sizes.MARGIN_16,
          top: Sizes.MARGIN_16,
        ),
        child: StreamBuilder(
          stream: Firestore.instance.collection('Dishes').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
            if (snap.hasData && !snap.hasError && snap.data != null) {
              dishes.clear();

              for (int i = 0; i < snap.data.documents.length; i++) {
//              print(snap.data.documents[i]['url']);
                if (snap.data.documents[i]['category'] == widget.categoryName)
                  dishes.add(Dish(
                      name: snap.data.documents[i]['name'],
                      category: snap.data.documents[i]['category'],
                      rating: snap.data.documents[i]['rating'],
                      price: snap.data.documents[i]['price'],
                      iPrice: snap.data.documents[i]['iPrice'],
                      desc: snap.data.documents[i]['description'],
                      url: snap.data.documents[i]['url']));
                print(snap.data.documents[i]['price']);
              }

              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                      itemCount: dishes.length,
                      separatorBuilder: (context, index) {
                        return SpaceH8();
                      },
                      itemBuilder: (context, index) {
                        print('============${dishes[index].price}');
                        return Container(
                          margin: EdgeInsets.only(right: 4.0),
                          child: FoodyBiteCard(
                            onTap: () => R.Router.navigator.pushNamed(
                              R.Router.restaurantDetailsScreen,
                              arguments: RestaurantDetails(
                                url: dishes[index].url,
                                name: dishes[index].name,
                                desc: dishes[index].desc,
                                category: dishes[index].category,
                                rating: dishes[index].rating,
                                price: dishes[index].price,
                              ),
                            ),
                            imagePath: dishes[index].url,
//                            status: status[index],
                            cardTitle: dishes[index].name,
                            rating: dishes[index].rating,
                            price: dishes[index].price,
                            iPrice: dishes[index].iPrice,
                            category: dishes[index].category,
//                            distance: distance[index],
                            address: dishes[index].desc,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else
              return Container(
                  child: Center(
                      child: Text(
                "No Data",
                style: TextStyle(color: Colors.black),
              )));
          },
        ),
      ),
    );
  }

  List<Widget> generatePills({
    @required int numberOfPills,
    @required double widthOfPill,
  }) {
    List<Widget> pills = [];
    for (var index = 0; index < numberOfPills; index++) {
      pills.add(
        Pill(
          width: widthOfPill,
          color: (index == widget.selectedCategory)
              ? AppColors.white
              : AppColors.whiteShade_50,
          marginRight:
              (index == numberOfPills - 1) ? Sizes.MARGIN_0 : Sizes.MARGIN_4,
        ),
      );
    }

    return pills;
  }
}

class Pill extends StatelessWidget {
  Pill({
    this.width = 30,
    this.height = 4,
    this.marginRight = 4,
    this.color = AppColors.whiteShade_50,
    this.borderRadius = Sizes.RADIUS_30,
  });

  final double width;
  final double height;
  final double marginRight;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, //28,
      height: height,
      margin: EdgeInsets.only(right: marginRight),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

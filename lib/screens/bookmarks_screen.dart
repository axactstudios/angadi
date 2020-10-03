import 'package:flutter/material.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/foody_bite_card.dart';
import 'package:angadi/widgets/spaces.dart';

class BookmarksScreen extends StatefulWidget {
  static const int TAB_NO = 1;

  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'My Cart',
          style: Styles.customTitleTextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color(0xFF5563FB),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                margin: EdgeInsets.only(right: Sizes.MARGIN_16),
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Checkout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
          margin: const EdgeInsets.only(
            left: Sizes.MARGIN_16,
            right: Sizes.MARGIN_16,
            top: Sizes.MARGIN_16,
          ),
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            itemCount: 4,
            separatorBuilder: (context, index) {
              return SpaceH8();
            },
            itemBuilder: (context, index) {
              return Container(
                child: FoodyBiteCard(
                  onTap: () => R.Router.navigator.pushNamed(
                    R.Router.restaurantDetailsScreen,
                    arguments: RestaurantDetails(
                      imagePath: imagePaths[index],
                      restaurantName: restaurantNames[index],
                      restaurantAddress: addresses[index],
                      rating: ratings[index],
                      category: category[index],
                      distance: distance[index],
                    ),
                  ),
                  imagePath: imagePaths[index],
                  status: status[index],
                  cardTitle: 'Hamburger',
                  rating: ratings[index],
                  bookmark: true,
                  category: category[index],
                  distance: distance[index],
                  address: 'Made with exotic ingredients',
                ),
              );
            },
          )

//        ListView(
//          scrollDirection: Axis.vertical,
//          children: <Widget>[
//            FoodyBiteCard(
//              imagePath: ImagePath.breakfastInBed,
//              status: StringConst.STATUS_OPEN,
//              cardTitle: "Happy Bones",
//              category: StringConst.ITALIAN,
//              distance: "12 km",
//              address: "394 Broome St, New York, NY 10013, USA",
//              bookmark: true,
//              onTap: () => navigateToDetailScreen(),
//            ),
//            SizedBox(height: Sizes.WIDTH_16),
//            FoodyBiteCard(
//              imagePath: ImagePath.dinnerIsServed,
//              status: StringConst.STATUS_OPEN,
//              rating: "4.8",
//              cardTitle: "Pappas Pizza",
//              category: StringConst.CHINESE,
//              distance: "2 km",
//              address: "917 Zoom St, California, CA 20093, USA",
//              bookmark: true,
//              onTap: () => navigateToDetailScreen(),
//            ),
//            SizedBox(height: Sizes.WIDTH_16),
//            FoodyBiteCard(
//              imagePath: ImagePath.breakfastInBed,
//              status: StringConst.STATUS_CLOSE,
//              rating: "3.7",
//              cardTitle: "Shantell's",
//              category: StringConst.ITALIAN,
//              distance: "4 km",
//              address: "34 Devil St, New York, NY 11013, USA",
//              bookmark: true,
//              onTap: () => navigateToDetailScreen(),
//            ),
//            SizedBox(height: Sizes.WIDTH_16),
//            FoodyBiteCard(
//              imagePath: ImagePath.dinnerIsServed,
//              status: StringConst.STATUS_CLOSE,
//              rating: "2.3",
//              cardTitle: "Dragon Heart",
//              category: StringConst.CHINESE,
//              distance: "5 km",
//              address: "417 Doom St, California, CA 90013, USA",
//              bookmark: true,
//              onTap: () => navigateToDetailScreen(),
//            ),
//          ],
//        ),
          ),
    );
  }
}

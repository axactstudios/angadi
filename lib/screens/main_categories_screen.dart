import 'package:angadi/routes/router.dart';
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/category_card.dart';
import 'package:angadi/widgets/custom_floating_button.dart';
import 'package:flutter/material.dart';

import 'categories_screen.dart';

class MainCategoriesScreen extends StatefulWidget {
  @override
  _MainCategoriesScreenState createState() => _MainCategoriesScreenState();
}

class _MainCategoriesScreenState extends State<MainCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: CustomFloatingButton(
            CurrentScreen(tab_no: 12, currentScreen: MainCategoriesScreen())),
        appBar: AppBar(
          elevation: 0.0,
//        leading: InkWell(
//          onTap: () => R.Router.navigator.pop(),
//          child: Image.asset(
//            ImagePath.arrowBackIcon,
//            color: AppColors.headingText,
//          ),
//        ),
          centerTitle: true,
          title: Text(
            StringConst.CATEGORY,
            style: Styles.customTitleTextStyle(
              color: AppColors.headingText,
              fontWeight: FontWeight.w600,
              fontSize: Sizes.TEXT_SIZE_20,
            ),
          ),
//        actions: <Widget>[
//          InkWell(
//            onTap: () {},
//            child: Image.asset(
//              ImagePath.searchIcon,
//              color: AppColors.headingText,
//            ),
//          )
//        ],
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: Sizes.MARGIN_16, vertical: Sizes.MARGIN_16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FoodyBiteCategoryCard(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.75,
                  imagePath:
                      'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FUlundu%20Vada%20Mix%2F1-4.JPG?alt=media&token=f3955753-5fd0-43a6-914c-d7a6a560834e',
                  category: 'Food Items',
                  gradient: gradients[2],
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return CategoriesScreen('Food');
                    }));
                  },
                ),
                FoodyBiteCategoryCard(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.75,
                  imagePath:
                      'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FPuliyodarai%20Paste%2F1-2.JPG?alt=media&token=7cd79faf-090f-4537-99fd-74fbcb86458b',
                  category: 'Grocery Items',
                  gradient: gradients[2],
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return CategoriesScreen('Grocery');
                    }));
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

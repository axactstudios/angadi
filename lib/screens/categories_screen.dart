import 'package:angadi/widgets/custom_floating_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/category_card.dart';
import 'package:angadi/widgets/spaces.dart';

import '../routes/router.dart';
import '../routes/router.gr.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static const int TAB_NO = 1;
  String sCat;
  CategoriesScreen(this.sCat);
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Widget> categoriesTop = new List();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      floatingActionButton: CustomFloatingButton(CurrentScreen(
          tab_no: CategoriesScreen.TAB_NO,
          currentScreen: CategoriesScreen('Both'))),
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
      body: Container(
        margin: EdgeInsets.symmetric(
            horizontal: Sizes.MARGIN_16, vertical: Sizes.MARGIN_16),
        child: StreamBuilder(
            stream: Firestore.instance.collection('Categories').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
              if (snap.hasData && !snap.hasError && snap.data != null) {
                categoriesTop.clear();

                for (int i = 0; i < snap.data.documents.length; i++) {
                  if (widget.sCat == 'Food' || widget.sCat == 'Grocery') {
                    if (snap.data.documents[i]['sCat'] == widget.sCat) {
                      categoriesTop.add(Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Container(
                              child: FoodyBiteCategoryCard(
                                onTap: () {
                                  print('L');
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return CategoryDetailScreen(
                                      categoryName: snap.data.documents[i]
                                          ['catName'],
                                      imagePath: snap.data.documents[i]
                                          ['imageURL'],
                                      selectedCategory: i,
                                      numberOfCategories: categoriesTop.length,
                                      gradient: gradients[i],
                                      sCat: widget.sCat,
                                    );
                                  }));
                                },
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width,
                                imagePath: snap.data.documents[i]
                                    ['liveImageURL'],
                                gradient: gradients[i],
                                category: snap.data.documents[i]['catName'],
                                opacity: 0.7,
                                categoryTextStyle: textTheme.title.copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: Sizes.TEXT_SIZE_16,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            )
                          ],
                        ),
                      ));
                    }
                  } else {
                    categoriesTop.add(Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Container(
                            child: FoodyBiteCategoryCard(
                              onTap: () {
                                print('L');
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return CategoryDetailScreen(
                                    categoryName: snap.data.documents[i]
                                        ['catName'],
                                    imagePath: snap.data.documents[i]
                                        ['imageURL'],
                                    selectedCategory: i,
                                    numberOfCategories: categoriesTop.length,
                                    gradient: gradients[i],
                                    sCat: widget.sCat,
                                  );
                                }));
                              },
                              width: MediaQuery.of(context).size.width,
                              imagePath: snap.data.documents[i]['liveImageURL'],
                              gradient: gradients[i],
                              category: snap.data.documents[i]['catName'],
                              opacity: 0.7,
                              categoryTextStyle: textTheme.title.copyWith(
                                color: AppColors.primaryColor,
                                fontSize: Sizes.TEXT_SIZE_16,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          )
                        ],
                      ),
                    ));
                  }
                }
              }
              return categoriesTop.length != 0
                  ? GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.vertical,
                      children: categoriesTop,
                    )
                  : Container();
            }),
      ),
    );
  }
}

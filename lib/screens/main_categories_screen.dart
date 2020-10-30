import 'package:angadi/routes/router.dart';
import 'package:angadi/values/data.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/category_card.dart';
import 'package:angadi/widgets/custom_floating_button.dart';
import 'package:angadi/widgets/nav_drawer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: AppColors.secondaryElement,
          actions: [
            InkWell(
                onTap: () {
                  launch('tel:+919027553376');
                },
                child: Icon(Icons.phone, color: Color(0xFF6b3600))),
            SizedBox(
              width: 8,
            ),
            InkWell(
                onTap: () {
//                print(1);
                  launch(
                      'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
                },
                child: Icon(Icons.mail, color: Color(0xFF6b3600))),
            SizedBox(
              width: 14,
            )
          ],
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Angadi.ae',
            style: Styles.customTitleTextStyle(
              color: Color(0xFF6b3600),
              fontWeight: FontWeight.w600,
              fontSize: Sizes.TEXT_SIZE_22,
            ),
          ),
        ),
        drawer: CustomDrawer(),
        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: Sizes.MARGIN_16, vertical: Sizes.MARGIN_16),
            child: Column(
              children: [
                Text(StringConst.CATEGORY.toUpperCase(),
                    style: Styles.customTitleTextStyle(
                      color: Color(0xFF6b3600),
                      fontWeight: FontWeight.w600,
                      fontSize: Sizes.TEXT_SIZE_20,
                    )),
                SizedBox(height: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FoodyBiteCategoryCard(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.65,
                        imagePath:
                            'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FUlundu%20Vada%20Mix%2F1-4.JPG?alt=media&token=f3955753-5fd0-43a6-914c-d7a6a560834e',
                        category: 'Food Items',
                        gradient: gradients[2],
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return CategoriesScreen('Food');
                          }));
                        },
                      ),
                      FoodyBiteCategoryCard(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.65,
                        imagePath:
                            'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/Dishes%2FPuliyodarai%20Paste%2F1-2.JPG?alt=media&token=7cd79faf-090f-4537-99fd-74fbcb86458b',
                        category: 'Grocery Items',
                        gradient: gradients[2],
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return CategoriesScreen('Grocery');
                          }));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

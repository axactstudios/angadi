import 'package:angadi/classes/dish.dart';
import 'package:angadi/classes/quantity.dart';
import 'package:angadi/screens/bookmark_screen_2.dart';
import 'package:auto_route/auto_route.dart';
import 'package:auto_route/auto_route_annotations.dart';
import 'package:flutter/material.dart';
import 'package:angadi/screens/add_ratings_screen.dart';
import 'package:angadi/screens/bookmarks_screen.dart';
import 'package:angadi/screens/categories_screen.dart';
import 'package:angadi/screens/category_detail_screen.dart';
import 'package:angadi/screens/change_language_screen.dart';
import 'package:angadi/screens/change_password_screen.dart';
import 'package:angadi/screens/edit_profile_screen.dart';
import 'package:angadi/screens/filter_screen.dart';
import 'package:angadi/screens/find_friends_screen.dart';
import 'package:angadi/screens/forgot_password_screen.dart';
import 'package:angadi/screens/home_screen.dart';
import 'package:angadi/screens/login_screen.dart';
import 'package:angadi/screens/menu_photos_screen.dart';
import 'package:angadi/screens/new_review_screen.dart';
import 'package:angadi/screens/notification_screen.dart';
import 'package:angadi/screens/preview_menu_photos.dart';
import 'package:angadi/screens/profile_screen.dart';
import 'package:angadi/screens/register_screen.dart';
import 'package:angadi/screens/restaurant_details_screen.dart';
import 'package:angadi/screens/review_rating_screen.dart';
import 'package:angadi/screens/root_screen.dart';
import 'package:angadi/screens/search_results.dart';
import 'package:angadi/screens/set_location_screen.dart';
import 'package:angadi/screens/settings_screen.dart';
import 'package:angadi/screens/splash_screen.dart';
import 'package:angadi/screens/trending_restaurant_screen.dart';
import 'package:meta/meta.dart';

//@MaterialAutoRouter()
//@CustomAutoRouter(transitionsBuilder: TransitionsBuilders.slideLeft, durationInMilliseconds: 200)

@CupertinoAutoRouter()
class $Router {
  LoginScreen loginScreen;

  SplashScreen splashScreen;

  ForgotPasswordScreen forgotPasswordScreen;

  @MaterialRoute()
  RegisterScreen registerScreen;

  SetLocationScreen setLocationScreen;

  HomeScreen homeScreen;

  RootScreen rootScreen;

  ProfileScreen profileScreen;

  NotificationsScreen notificationsScreen;

  TrendingRestaurantsScreen trendingRestaurantsScreen;
  RestaurantDetailsScreen restaurantDetailsScreen;
  BookmarksScreen bookmarksScreen;
  BookmarksScreen2 bookmarksScreen2;

  FilterScreen filterScreen;
  SearchResultsScreen searchResultsScreen;
  ReviewRatingScreen reviewRatingScreen;

  AddRatingsScreen addRatingsScreen;
  MenuPhotosScreen menuPhotosScreen;
  PreviewMenuPhotosScreen previewMenuPhotosScreen;
  CategoriesScreen categoriesScreen;

  CategoryDetailScreen categoryDetailScreen;
  FindFriendsScreen findFriendsScreen;
  SettingsScreen settingsScreen;
  ChangePasswordScreen changePasswordScreen;

  ChangeLanguageScreen changeLanguageScreen;
  EditProfileScreen editProfileScreen;
  NewReviewScreen newReviewScreen;
}

class SearchValue {
  final String value;

  SearchValue(this.value);
}

class ReviewRating {
  final String name;

  ReviewRating(this.name);
}

class RestaurantDetails {
  String url;
  String name;
  String desc;
  String category;
  String rating;
  Dish boughtTogether;
  String boughtTogetherQuantity;
  String price;
  String boughtTogetherDiscount;
  List<Quantity>allquantities=[];

  RestaurantDetails(
      {@required this.url,
      @required this.name,
      @required this.desc,
      @required this.category,
      @required this.rating,
      @required this.price,
      @required this.boughtTogether,
      @required this.boughtTogetherDiscount,
      @required this.boughtTogetherQuantity,
      @required this.allquantities});
}

class CurrentScreen {
  final Widget currentScreen;
  final int tab_no;

  CurrentScreen({
    @required this.tab_no,
    @required this.currentScreen,
  });
}

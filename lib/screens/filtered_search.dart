import 'package:angadi/classes/dish.dart';
import 'package:angadi/routes/router.dart';
import 'package:angadi/screens/restaurant_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/types/gf_loader_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class FilteredSearch extends StatefulWidget {
  @override
  _FilteredSearchState createState() => _FilteredSearchState();
}

List<Dish> dogList1 = [];
List<Widget> dogCardsList1 = [];

class _FilteredSearchState extends State<FilteredSearch> {
  List<DocumentSnapshot> docList = [];
  List<Dish> dogList = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = TextEditingController(text: "");
  Widget appBarTitle = Text(
    'Jab We Mate',
    style: GoogleFonts.openSans(
        fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
  );
  Icon actionIcon = new Icon(Icons.search);

  int number = 0;
  int max = 10;

  @override
  void initState() {
    getData();
    getData1();
  }

  void getData1() async {
    dogCardsList1.clear();
    dogList1.clear();
    print('started loading');
    await databaseReference
        .collection("Dishes")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) async {
        Dish dp = Dish(
            name: f['name'],
            category: f['category'],
            rating: f['rating'].toString(),
            price: f['price'],
            desc: f['description'],
            url: f['url']);
        await dogList1.add(dp);
        // await dogCardsList1.add(MyDogCard(dp, width, height));
        print('Dog added');
        print(f['imageLinks'].toString());
      });
    });
    setState(() {
      print(dogList1.length.toString());
      print(dogCardsList1.length.toString());
    });
  }

  double width, height;
  List<Widget> dogCardsList = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(Icons.close);
                  this.appBarTitle = new TextFormField(
                    style: TextStyle(color: Colors.white),
                    controller: searchController,
                    decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      hintText: 'Search for Names or Breeds..',
                      hintStyle: GoogleFonts.openSans(
                          textStyle: TextStyle(color: Colors.white)),
                    ),
                    onChanged: (String query) {
                      getCaseDetails(query);
                    },
                  );
                } else {
                  this.appBarTitle = Text(
                    'Jab We Mate',
                    style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white),
                  );
                  this.actionIcon = new Icon(Icons.search);
                }
              });
            },
          ),
        ],
        centerTitle: true,
        title: appBarTitle,
        flexibleSpace: Container(
          decoration: BoxDecoration(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: height * 0.75,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: dogList.length,
                  itemBuilder: (BuildContext, index) {
                    var item = dogList[index];
                    return InkWell(
                      onTap: () {
                        pushNewScreen(
                          context,
                          screen: RestaurantDetailsScreen(
                            RestaurantDetails(
                              url: item.url,
                              name: item.name,
                              desc: item.desc,
                              category: item.category,
                              rating: item.rating,
                              price: item.price,
                            ),
                          ),
                          withNavBar: true, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                        // _scaffoldKey.currentState.showBottomSheet((context) {
                        //   return StatefulBuilder(
                        //       builder: (context, StateSetter state) {
                        //     return ProfilePullUp(item, width, height);
                        //   });
                        // });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: width * 0.8,
                          child: Row(
                            children: <Widget>[
                              // Container(
                              //   height: 50,
                              //   width: 50,
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.all(
                              //       Radius.circular(25),
                              //     ),
                              //   ),
                              //   child: ClipRRect(
                              //     borderRadius: BorderRadius.circular(25.0),
                              //     child: CachedNetworkImage(
                              //       height: 50,
                              //       width: 50,
                              //       imageUrl: item.url,
                              //       imageBuilder: (context, imageProvider) =>
                              //           Container(
                              //         decoration: BoxDecoration(
                              //           image: DecorationImage(
                              //               image: imageProvider,
                              //               fit: BoxFit.fill),
                              //         ),
                              //       ),
                              //       placeholder: (context, url) => GFLoader(
                              //         type: GFLoaderType.ios,
                              //       ),
                              //       errorWidget: (context, url, error) =>
                              //           Icon(Icons.error),
                              //     ),
                              //   ),
                              // ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Container(
                                    child: Text(
                                      '${item.name} in ${item.category}',
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.call_made_sharp,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getCaseDetails(String query) async {
    docList.clear();
    dogList.clear();
    setState(() {
      print('Updated');
    });

    if (query == '') {
      print(query);
      getData();
      return;
    }

    await Firestore.instance
        .collection('Dishes')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      docList.clear();
      dogList.clear();
      snapshot.documents.forEach((f) {
        List<String> dogName = List<String>.from(f['nameSearch']);
        List<String> dogBreed = List<String>.from(f['categorySearch']);
        List<String> dogLowerCase = [];
        List<String> breedLowerCase = [];
        for (var dog in dogName) {
          dogLowerCase.add(dog.toLowerCase());
        }
        for (var breed in dogBreed) {
          breedLowerCase.add(breed.toLowerCase());
        }
        if (dogLowerCase.contains(query.toLowerCase()) ||
            breedLowerCase.contains(query.toLowerCase())) {
          print('Match found ${f['name']}');
          docList.add(f);
          Dish dog = Dish(
              name: f['name'],
              category: f['category'],
              rating: f['rating'].toString(),
              price: f['price'],
              desc: f['description'],
              url: f['url']);
          dogList.add(dog);
          setState(() {
            print('Updated');
          });
        }
      });
    });
  }

  final databaseReference = Firestore.instance;

  void getData() async {
    await databaseReference
        .collection("Dishes")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        dogList.add(Dish(
            name: f['name'],
            category: f['category'],
            rating: f['rating'].toString(),
            price: f['price'],
            desc: f['description'],
            url: f['url']));
        print('Dog added');
        print(f['profileImage'].toString());
      });
    });
    setState(() {
      print(dogList.length.toString());
    });
  }
}

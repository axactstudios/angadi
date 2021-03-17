import 'package:angadi/classes/offer.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/offer_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Offer discount;

class ApplyOffers extends StatefulWidget {
  State state;
  BuildContext ctxt;
  ApplyOffers(this.state, this.ctxt);
  @override
  _ApplyOffersState createState() => _ApplyOffersState();
}

class _ApplyOffersState extends State<ApplyOffers> {
  List<Offer> offers = new List<Offer>();
  List<Offer>filteroffers=[];
  FirebaseUser user;
  List test=[];

void check()async{
  test.clear();
  user=await FirebaseAuth.instance.currentUser();
  await Firestore.instance.collection('Users').document(user.uid).get().then((value) {
  Map map=value.data;
  test=map['couponUsed'];
  });
print('---------------------${test.length}');
filter();
}
int add=0;
List<Offer>alloffers=[];
String checking='';
void filter()async{
  user=await FirebaseAuth.instance.currentUser();
  filteroffers.clear();
  alloffers.clear();
  Firestore.instance.collection('Offers').snapshots().forEach((element) {
    for(int i=0;i<element.documents.length;i++){
      alloffers.add(
          Offer(
              element.documents[i]['Title'],
              element.documents[i]['Subtitle'],
              element.documents[i]['ImageURL'],
              element.documents[i]['discountPercentage'],

              element.documents[i]['perUserLimit'])
      );
    }
    for(int j=0;j<alloffers.length;j++){
      add=0;
      for(int k=0;k<test.length;k++){
        print(test[k].toString());
        if(test[k]==alloffers[j].title){
          add++;
          
          print('----------Add:${add}');
        }
      }
      if(int.parse(alloffers[j].perUserLimit)!=add){
        setState(() {
          filteroffers.add(Offer(
              alloffers[j].title,
              alloffers[j].subtitle,
              alloffers[j].imageURL,
              alloffers[j].discount,

              alloffers[j].perUserLimit));
        });
      print('-----------Filter${filteroffers.length}');
      }
    }
  });





}
@override
  void initState() {
    check();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Apply Coupon',
          style: Styles.customTitleTextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('Offers').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
            if (snap.hasData && !snap.hasError && snap.data != null) {
              offers.clear();

              for (int i = 0; i < snap.data.documents.length; i++) {
                offers.add(Offer(
                    snap.data.documents[i]['Title'],
                    snap.data.documents[i]['Subtitle'],
                    snap.data.documents[i]['ImageURL'],
                    snap.data.documents[i]['discountPercentage'],

                    snap.data.documents[i]['perUserLimit']));


              }
//              for(int j=0;j<offers.length;j++){
//                add=0;
//               for(int k=0;k<test.length;k++){
//                 print(test[k].toString());
//                 if(test[k]==offers[j].title){
//                   add++;
//                   print('----------Add:${add}');
//                 }
//               }
//               if(int.parse(offers[j].perUserLimit)!=add){
//                 filteroffers.add(Offer(
//                     snap.data.documents[j]['Title'],
//                     snap.data.documents[j]['Subtitle'],
//                     snap.data.documents[j]['ImageURL'],
//                     snap.data.documents[j]['discountPercentage'],
//
//                     snap.data.documents[j]['perUserLimit']));
//               }
//              }
             
              return (filteroffers.length!=0)?Container(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: filteroffers.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 280,
                        margin: EdgeInsets.only(right: 4.0),
                        child: OfferCardApply(
                          onTap: () {
                            setState(() {
                              discount = Offer(
                                  filteroffers[index].title,
                                  filteroffers[index].subtitle,
                                  filteroffers[index].imageURL,
                                  filteroffers[index].discount,
                                  filteroffers[index].perUserLimit);

                              widget.state.setState(() {
                                print(1);
                              });
                              Navigator.of(context).pop();
                            });
                          },
                          imagePath: filteroffers[index].imageURL,
                          // status: '90% OFF',
                          cardTitle: filteroffers[index].title,
                          // rating: ratings[index],
                          // category: category[index],
                          // distance: '',
                          details: filteroffers[index].subtitle,
                        ),
                      );
                    }),
              ):Center(
                child: Container(
                  height:100,
                  width:MediaQuery.of(context).size.width,
                  child:Center(child: Text('No promo codes available!'))
                ),
              );
            } else {
              return Container(
                child:Center(child: Text('No coupons available'))
              );
            }
          }),
    );
  }
}

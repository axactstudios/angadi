import 'package:angadi/classes/offer.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/offer_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
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
                    snap.data.documents[i]['discountPercentage']));
              }

              return Container(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 280,
                        margin: EdgeInsets.only(right: 4.0),
                        child: OfferCardApply(
                          onTap: () {
                            setState(() {
                              discount = Offer(
                                  offers[index].title,
                                  offers[index].subtitle,
                                  offers[index].imageURL,
                                  offers[index].discount);

                              widget.state.setState(() {
                                print(1);
                              });
                              Navigator.of(context).pop();
                            });
                          },
                          imagePath: offers[index].imageURL,
                          // status: '90% OFF',
                          cardTitle: offers[index].title,
                          // rating: ratings[index],
                          // category: category[index],
                          // distance: '',
                          details: offers[index].subtitle,
                        ),
                      );
                    }),
              );
            } else {
              return Container();
            }
          }),
    );
  }
}

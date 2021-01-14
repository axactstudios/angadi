import 'dart:io';

import 'package:angadi/screens/order_placed.dart';
import 'package:angadi/values/values.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class Order {
  String total, type, status, orderString, id;
  Timestamp timestamp;
  var date;
  List items, prices, quantities;
  Order(
      {this.prices,
      this.quantities,
      this.items,
      this.type,
      this.status,
      this.total,
      this.timestamp,
      this.orderString,
      this.id,
      this.date});
}

class _MyOrdersState extends State<MyOrders> {
  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?   phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Order> orders = List<Order>();
    var date2;

    Widget bill(timestamp, total, id1, status, str) {
      return Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Order Id- $id1',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 3,
                ),
                Container(
                  color: Colors.black.withOpacity(0.1),
                  height: 1,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Items',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  str,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Ordered On',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  timestamp.toDate().day.toString() +
                      '-' +
                      timestamp.toDate().month.toString() +
                      '-' +
                      timestamp.toDate().year.toString() +
                      ' at ' +
                      timestamp.toDate().hour.toString() +
                      ':' +
                      timestamp.toDate().minute.toString(),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Total',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'AED ' + total,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 3,
                ),
                Container(
                  color: Colors.black.withOpacity(0.1),
                  height: 1,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  status,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
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
                  launchWhatsApp(
                      phone: '7060222315',
                      message: 'Check out this awesome app');
                },
                child: Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.whatsapp,
                        color: Color(0xFF6b3600)))),
            SizedBox(width: 8),
            InkWell(
                onTap: () {
//                print(1);
                  launch(
                      'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
                },
                child: Icon(Icons.mail, color: Color(0xFF6b3600))),
            SizedBox(
              width: 10,
            )
          ],
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Angadi.ae',
            style: Styles.customTitleTextStyle(
              color: Color(0xFF6b3600),
              fontWeight: FontWeight.w600,
              fontSize: Sizes.TEXT_SIZE_18,
            ),
          ),
        ),
        body: Container(
          child: StreamBuilder(
            stream: Firestore.instance.collection('Orders').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
              if (snap.hasData && !snap.hasError && snap.data != null) {
                orders.clear();

                for (int i = 0; i < snap.data.documents.length; i++) {
                  print(snap.data.documents[i]['Price'].toString());
                  print('------------------');
                  print(snap.data.documents[i]['Qty'].toString());
                  print('items');
                  print(snap.data.documents[i]['Items'].toString());

                  print(orders.length);
                  String str = '';
                  for (int it = 0;
                      it <= snap.data.documents[i]['Items'].length - 1;
                      it++) {
                    it != snap.data.documents[i]['Items'].length -1
                        ? str = str +
                            '${snap.data.documents[i]['Qty'][it]} x ${snap.data.documents[i]['Items'][it]}, '
                        : str = str +
                            '${snap.data.documents[i]['Qty'][it]} x ${snap.data.documents[i]['Items'][it]}';
                  }
                  orders.add(Order(
                      prices: snap.data.documents[i]['Price'],
                      items: snap.data.documents[i]['Items'],
                      total: snap.data.documents[i]['GrandTotal'].toString(),
                      quantities: snap.data.documents[i]['Qty'],
                      status: snap.data.documents[i]['Status'],
                      timestamp: snap.data.documents[i]['TimeStamp'],
                      type: snap.data.documents[i]['Type'],
                      date: snap.data.documents[i]['DeliveryDate'],
                      orderString: str,
                      id: snap.data.documents[i].documentID));
                }
                return orders.length != 0
                    ? ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 8, 8, 8),
                            child: InkWell(
                              onTap: () async {
                                String status;
                                await Firestore.instance
                                    .collection('Orders')
                                    .getDocuments()
                                    .then((value) {
                                  value.documents.forEach((element) {
                                    print(orders[index].id);
                                    print(element.documentID);
                                    if (element.documentID ==
                                        orders[index].id) {
                                      status = element['Status'];
                                      date2 = element['DeliveryDate'];
                                      DateTime myDateTime = date2.toDate();
                                      pushNewScreen(context,
                                          screen: OrderPlaced(
                                              bill(
                                                  orders[index].timestamp,
                                                  orders[index].total,
                                                  orders[index].id,
                                                  orders[index].status,
                                                  orders[index].orderString),
                                              orders[index].id,
                                              status,
                                              myDateTime));
                                      print('Push pressed');
                                    }
                                  });
                                });
                              },
                              child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Order Id-${orders[index].id}',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Container(
                                          color: Colors.black.withOpacity(0.1),
                                          height: 1,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Items',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          orders[index].orderString,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Ordered On',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          orders[index]
                                                  .timestamp
                                                  .toDate()
                                                  .day
                                                  .toString() +
                                              '-' +
                                              orders[index]
                                                  .timestamp
                                                  .toDate()
                                                  .month
                                                  .toString() +
                                              '-' +
                                              orders[index]
                                                  .timestamp
                                                  .toDate()
                                                  .year
                                                  .toString() +
                                              ' at ' +
                                              orders[index]
                                                  .timestamp
                                                  .toDate()
                                                  .hour
                                                  .toString() +
                                              ':' +
                                              orders[index]
                                                  .timestamp
                                                  .toDate()
                                                  .minute
                                                  .toString(),
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.spaceEvenly,
                                        //   children: [
                                        //     Container(
                                        //         width: MediaQuery.of(context)
                                        //                 .size
                                        //                 .width *
                                        //             0.3,
                                        //         child: Center(
                                        //             child: Text('Name'))),
                                        //     Container(
                                        //         width: MediaQuery.of(context)
                                        //                 .size
                                        //                 .width *
                                        //             0.3,
                                        //         child: Center(
                                        //             child: Text('Quantity'))),
                                        //     Container(
                                        //         width: MediaQuery.of(context)
                                        //                 .size
                                        //                 .width *
                                        //             0.3,
                                        //         child: Center(
                                        //             child: Text('Price'))),
                                        //   ],
                                        // ),
                                        // Container(
                                        //   height:
                                        //       40.0 * orders[index].items.length,
                                        //   child: ListView.builder(
                                        //       itemCount:
                                        //           orders[index].items.length,
                                        //       itemBuilder: (context, i) {
                                        //         return Row(
                                        //           // mainAxisAlignment:
                                        //           //     MainAxisAlignment
                                        //           //         .spaceEvenly,
                                        //           children: [
                                        //             Container(
                                        //               width:
                                        //                   MediaQuery.of(context)
                                        //                           .size
                                        //                           .width *
                                        //                       0.3,
                                        //               child: Center(
                                        //                 child: Text(
                                        //                   orders[index]
                                        //                       .items[i]
                                        //                       .toString(),
                                        //                   textAlign:
                                        //                       TextAlign.center,
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //             Container(
                                        //               width:
                                        //                   MediaQuery.of(context)
                                        //                           .size
                                        //                           .width *
                                        //                       0.3,
                                        //               child: Center(
                                        //                 child: Text(
                                        //                     orders[index]
                                        //                         .quantities[i]
                                        //                         .toString()),
                                        //               ),
                                        //             ),
                                        //             Container(
                                        //               width:
                                        //                   MediaQuery.of(context)
                                        //                           .size
                                        //                           .width *
                                        //                       0.3,
                                        //               child: Center(
                                        //                 child: Text(
                                        //                     orders[index]
                                        //                         .prices[i]
                                        //                         .toString()),
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         );
                                        //       }),
                                        // ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.spaceAround,
                                        //   children: [
                                        //     Container(
                                        //         width: MediaQuery.of(context)
                                        //                 .size
                                        //                 .width *
                                        //             0.45,
                                        //         child: Center(
                                        //             child: Text('Amount-'))),
                                        //     Container(
                                        //         width: MediaQuery.of(context)
                                        //                 .size
                                        //                 .width *
                                        //             0.45,
                                        //         child: Center(
                                        //           child:
                                        //               Text(orders[index].total),
                                        //         )),
                                        //   ],
                                        // ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.spaceAround,
                                        //   children: [
                                        //     Container(
                                        //         width: MediaQuery.of(context)
                                        //                 .size
                                        //                 .width *
                                        //             0.45,
                                        //         child: Center(
                                        //             child: Text('Status-'))),
                                        //     Container(
                                        //       width: MediaQuery.of(context)
                                        //               .size
                                        //               .width *
                                        //           0.45,
                                        //       child: Center(
                                        //         child: Text(orders[index]
                                        //             .status
                                        //             .toString()),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        // SizedBox(
                                        //   height: 10,

                                        // ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'AED ' + orders[index].total,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Container(
                                          color: Colors.black.withOpacity(0.1),
                                          height: 1,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          orders[index].status,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        orders[index].status ==
                                                'Order Delivered'
                                            ? Container(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                height: 1,
                                              )
                                            : Container(),
                                        orders[index].status ==
                                                'Order Delivered'
                                            ? SizedBox(
                                                height: 10,
                                              )
                                            : Container(),
                                        orders[index].status ==
                                                'Order Delivered'
                                            ? Center(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 2),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5))),
                                                  //hjh
                                                  height: 40,
                                                  width: 320,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 30,
                                                        width: 200,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                            'Rate this product now'),
                                                      ),
                                                      Container(
                                                        height: 30,
                                                        width: 116,
                                                        alignment:
                                                            Alignment.center,
                                                        child: RatingBar(
                                                          initialRating: 3,
                                                          minRating: 1,
                                                          itemSize: 20,
                                                          direction:
                                                              Axis.horizontal,
                                                          allowHalfRating: true,
                                                          itemCount: 5,
                                                          itemPadding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      1.0),
                                                          itemBuilder:
                                                              (context, _) =>
                                                                  Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 20,
                                                          ),
                                                          onRatingUpdate:
                                                              (rating) {
                                                            print(rating);
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                    : Container();
              } else
                return Container(
                    child: Center(
                        child: Container(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator())));
            },
          ),
        ));
  }
}

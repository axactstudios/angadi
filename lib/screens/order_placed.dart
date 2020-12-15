//import 'dart:async';
//
//import 'package:angadi/values/values.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:location/location.dart';
//
//class MapPage extends StatefulWidget {
//  LocationData currentPosition;
//  MapPage(this.currentPosition);
//  @override
//  State<StatefulWidget> createState() => MapPageState();
//}
//
//class MapPageState extends State<MapPage> {
//  // ignore: non_constant_identifier_names
//  double CAMERA_ZOOM = 11;
//  // ignore: non_constant_identifier_names
//  double CAMERA_TILT = 0;
//  // ignore: non_constant_identifier_names
//  double CAMERA_BEARING = 30;
//  // ignore: non_constant_identifier_names
//  PointLatLng SOURCE_LOCATION = PointLatLng(25.336860, -55.399680);
//  // ignore: non_constant_identifier_names
//
//  PointLatLng DEST_LOCATION = PointLatLng(42.6871386, -71.2143403);
//  // ignore: non_constant_identifier_names
//  LatLng SOURCE_LOCATION1 = LatLng(25.336860, -55.399680);
//  // ignore: non_constant_identifier_names
//  LatLng DEST_LOCATION1 = LatLng(42.6871386, -71.2143403);
//  Completer<GoogleMapController> _controller = Completer();
//  Set<Marker> _markers = {};
//  Set<Polyline> _polylines = {};
//  List<LatLng> polylineCoordinates = [];
//
//  PolylinePoints polylinePoints = PolylinePoints();
//  String googleAPIKey = "AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw";
//  // for my custom icons
//  BitmapDescriptor sourceIcon;
//  BitmapDescriptor destinationIcon;
//
//  @override
//  void initState() {
//    super.initState();
//    setSourceAndDestinationIcons();
//  }
//
//  void setSourceAndDestinationIcons() async {
//    sourceIcon = await BitmapDescriptor.fromAssetImage(
//        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
//    destinationIcon = await BitmapDescriptor.fromAssetImage(
//        ImageConfiguration(devicePixelRatio: 2.5),
//        'assets/destination_map_marker.png');
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    CameraPosition initialLocation = CameraPosition(
//        zoom: CAMERA_ZOOM,
//        bearing: CAMERA_BEARING,
//        tilt: CAMERA_TILT,
//        target: SOURCE_LOCATION1);
//    return Scaffold(

//      body: Padding(
//        padding: const EdgeInsets.all(8.0),
//        child: Container(
//          decoration: ShapeDecoration(
//              shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.all(
//              Radius.circular(20),
//            ),
//          )),
//          height: MediaQuery.of(context).size.height * 0.4,
//          child: Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: _polylines != null || _polylines.length != 0
//                ? GoogleMap(
//                    myLocationEnabled: true,
//                    compassEnabled: true,
//                    tiltGesturesEnabled: false,
//                    markers: _markers,
//                    polylines: _polylines,
//                    mapType: MapType.normal,
//                    initialCameraPosition: initialLocation,
//                    onMapCreated: onMapCreated)
//                : CircularProgressIndicator(),
//          ),
//        ),
//      ),
//    );
//  }
//
//  void onMapCreated(GoogleMapController controller) {
//    controller.setMapStyle(Utils.mapStyles);
//    _controller.complete(controller);
//    setMapPins();
//    setPolylines();
//  }
//
//  void setMapPins() {
//    setState(() {
//      // source pin
//      _markers.add(Marker(
//          markerId: MarkerId('sourcePin'),
//          position: SOURCE_LOCATION1,
//          icon: sourceIcon));
//      // destination pin
//      _markers.add(Marker(
//          markerId: MarkerId('destPin'),
//          position: LatLng(widget.currentPosition.latitude,
//              widget.currentPosition.longitude),
//          icon: destinationIcon));
//    });
//  }
//
//  setPolylines() async {
//    PolylineResult result = await polylinePoints?.getRouteBetweenCoordinates(
//      googleAPIKey,
//      SOURCE_LOCATION,
//      PointLatLng(
//          widget.currentPosition.latitude, widget.currentPosition.longitude),
//    );
//    if (result.points.isNotEmpty) {
//      result.points.forEach((PointLatLng point) {
//        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//      });
//    }
//
//    setState(() {
//      // create a Polyline instance
//      // with an id, an RGB color and the list of LatLng pairs
//      Polyline polyline = Polyline(
//          polylineId: PolylineId("poly"),
//          color: Colors.red,
//          visible: true,
//          points: polylineCoordinates);
//
//      // add the constructed polyline as a set of points
//      // to the polyline set, which will eventually
//      // end up showing up on the map
//      _polylines.add(polyline);
//    });
//  }
//}
//
//class Utils {
//  static String mapStyles = '''[
//  {
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#f5f5f5"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.icon",
//    "stylers": [
//      {
//        "visibility": "off"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#616161"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.text.stroke",
//    "stylers": [
//      {
//        "color": "#f5f5f5"
//      }
//    ]
//  },
//  {
//    "featureType": "administrative.land_parcel",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#bdbdbd"
//      }
//    ]
//  },
//  {
//    "featureType": "poi",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#eeeeee"
//      }
//    ]
//  },
//  {
//    "featureType": "poi",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#757575"
//      }
//    ]
//  },
//  {
//    "featureType": "poi.park",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#e5e5e5"
//      }
//    ]
//  },
//  {
//    "featureType": "poi.park",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  },
//  {
//    "featureType": "road",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#ffffff"
//      }
//    ]
//  },
//  {
//    "featureType": "road.arterial",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#757575"
//      }
//    ]
//  },
//  {
//    "featureType": "road.highway",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#dadada"
//      }
//    ]
//  },
//  {
//    "featureType": "road.highway",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#616161"
//      }
//    ]
//  },
//  {
//    "featureType": "road.local",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  },
//  {
//    "featureType": "transit.line",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#e5e5e5"
//      }
//    ]
//  },
//  {
//    "featureType": "transit.station",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#eeeeee"
//      }
//    ]
//  },
//  {
//    "featureType": "water",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#c9c9c9"
//      }
//    ]
//  },
//  {
//    "featureType": "water",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  }
//]''';
//}

import 'dart:io';

import 'package:angadi/classes/cart.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderPlaced extends StatefulWidget {
  Widget bills;
  String docID;
  String status;
  var date;

  OrderPlaced(this.bills, this.docID, this.status,this.date);
  @override
  _OrderPlacedState createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced> {
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
    print(widget.status);
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
                    phone: '7060222315', message: 'Check out this awesome app');
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              widget.status == 'Awaiting Confirmation'
                  ? Center(
                      child: Text(
                        'Your Order has been placed !',
                        style: Styles.customTitleTextStyle(
                          color: AppColors.accentText,
                          fontWeight: FontWeight.w300,
                          fontSize: 17,
                        ),
                      ),
                    )
                  : Container(),
              widget.status == 'Awaiting Confirmation'
                  ? Center(
                      child: RichText(
                        text: TextSpan(
                            text: 'Awaiting',
                            style: Styles.customTitleTextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' for Angadi Confirmation',
                                style: Styles.customTitleTextStyle(
                                  color: AppColors.accentText,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 17,
                                ),
                              )
                            ]),
                      ),
                    )
                  : widget.status == 'Preparing Order'
                      ? Center(
                          child: RichText(
                            text: TextSpan(
                                text: 'Preparing',
                                style: Styles.customTitleTextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' your Order',
                                    style: Styles.customTitleTextStyle(
                                      color: AppColors.accentText,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 17,
                                    ),
                                  )
                                ]),
                          ),
                        )
                      : Center(
                          child: RichText(
                            text: TextSpan(
                                text: 'Order',
                                style: Styles.customTitleTextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' has been delivered',
                                    style: Styles.customTitleTextStyle(
                                      color: AppColors.accentText,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 17,
                                    ),
                                  )
                                ]),
                          ),
                        ),
              SizedBox(
                height: 10,
              ),
              Container(
                  child: Column(
                children: [
                  widget.status == 'Awaiting Confirmation'
                      ? Example10Horizontal()
                      : widget.status == 'Preparing Order'
                          ? Example20Horizontal()
                          : Example30Horizontal(),
                  widget.status == 'Awaiting Confirmation'
                      ? Image.asset('assets/images/awaiting.jpg',
                          height: 150, width: 150)
                      : widget.status == 'Preparing Order'
                          ? Image.asset('assets/images/gettingReady.jpg',
                              height: 150, width: 150)
                          : Image.asset('assets/images/Delivered.jpg',
                              height: 150, width: 150),
                ],
              )),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 0, top: 20),
                child: HeadingRow(
                  title: 'Order Summary',
                  number: '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Order ID : ${widget.docID}',
                            style: Styles.customTitleTextStyle(
                              color: AppColors.headingText,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Color(0xFF6b3600))),
                          child: Center(
                            child: Text(
                              'Expected delivery in : ${widget.date.difference(DateTime.now()).inHours} hours',
                              style: Styles.customNormalTextStyle(
                                color: AppColors.headingText,
                                // fontWeight: FontWeight.w400,
                                fontSize: Sizes.TEXT_SIZE_20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              widget.bills,
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 0, top: 20),
                child: HeadingRow(
                  title: 'Contact Details',
                  number: '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 60,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  launch('tel:06 746 7406');
                                },
                                child: Text('Call Us : 06 746 7406',style:TextStyle(decoration: TextDecoration.underline,fontSize: MediaQuery.of(context).size.height*0.022))),
                            InkWell(onTap:(){ launchWhatsApp(
                                phone: '+971 50 7175405',message:'Check out this awesome app');},child: Text('Whatsapp : +971 50 7175405',style:TextStyle(decoration: TextDecoration.underline,fontSize: MediaQuery.of(context).size.height*0.022))),
                            InkWell(onTap:(){launch('mailto:info@misteridli.com?subject=Complaint/Feedback&body=Type your views here');},child: Text('Email : info@misteridli.com',style:TextStyle(decoration: TextDecoration.underline,fontSize: MediaQuery.of(context).size.height*0.022))),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: () {
                          launch(
                              'https://play.google.com/store/apps/details?id=com.chimps.misteridli');
                        },
                        child: Text(
                          'Liked the service? Or annoyed by something? Write a feedback and let us now.',
                          style: TextStyle(color: Colors.blue, fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Cart> cartItems = [];
  final dbHelper = DatabaseHelper.instance;
  void getAllItems() async {
    final allRows = await dbHelper.queryAllRows();

    cartItems.clear();
    allRows.forEach((row) => cartItems.add(Cart.fromMap(row)));
    setState(() {
//      print(cartItems[1]);
    });
  }

  void removeAll() async {
    // Assuming that the number of rows is the id for the last row.
    for (var v in cartItems) {
      final rowsDeleted = await dbHelper.delete(v.productName, v.qtyTag);
    }

    getAllItems();
  }
}

class Example30Horizontal extends StatefulWidget {
  const Example30Horizontal({Key key}) : super(key: key);
  @override
  _Example30HorizontalState createState() => _Example30HorizontalState();
}

class _Example30HorizontalState extends State<Example30Horizontal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 25),
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isFirst: true,
            indicatorStyle: IndicatorStyle(
              height: 20,
              color: AppColors.secondaryElement,
            ),
            beforeLineStyle: LineStyle(
              color: AppColors.secondaryElement,
              thickness: 6,
            ),
          ),
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            beforeLineStyle: const LineStyle(
              color: AppColors.secondaryElement,
              thickness: 6,
            ),
            afterLineStyle: const LineStyle(
              color: AppColors.secondaryElement,
              thickness: 6,
            ),
            indicatorStyle: const IndicatorStyle(
              height: 20,
              color: AppColors.secondaryElement,
            ),
          ),
//          const TimelineDivider(
//            axis: TimelineAxis.vertical,
//            begin: 0.1,
//            end: 0.9,
//            thickness: 6,
//            color: Colors.deepOrange,
//          ),
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isLast: true,
            beforeLineStyle: const LineStyle(
              color: AppColors.secondaryElement,
              thickness: 6,
            ),
            indicatorStyle: const IndicatorStyle(
              height: 20,
              color: AppColors.secondaryElement,
            ),
          ),
        ],
      ),
    );
  }
}

class Example20Horizontal extends StatefulWidget {
  const Example20Horizontal({Key key}) : super(key: key);
  @override
  _Example20HorizontalState createState() => _Example20HorizontalState();
}

class _Example20HorizontalState extends State<Example20Horizontal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 25),
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isFirst: true,
            indicatorStyle: IndicatorStyle(
              height: 20,
              color: AppColors.secondaryElement,
            ),
            beforeLineStyle: LineStyle(
              color: AppColors.secondaryElement,
              thickness: 6,
            ),
          ),
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            beforeLineStyle: const LineStyle(
              color: AppColors.secondaryElement,
              thickness: 6,
            ),
            afterLineStyle: const LineStyle(
              color: Colors.grey,
              thickness: 6,
            ),
            indicatorStyle: const IndicatorStyle(
              height: 20,
              color: AppColors.secondaryElement,
            ),
          ),
//          const TimelineDivider(
//            axis: TimelineAxis.vertical,
//            begin: 0.1,
//            end: 0.9,
//            thickness: 6,
//            color: Colors.deepOrange,
//          ),
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isLast: true,
            beforeLineStyle: const LineStyle(
              color: Colors.grey,
              thickness: 6,
            ),
            indicatorStyle: const IndicatorStyle(
              height: 20,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class Example10Horizontal extends StatefulWidget {
  const Example10Horizontal({Key key}) : super(key: key);

  @override
  _Example10HorizontalState createState() => _Example10HorizontalState();
}

class _Example10HorizontalState extends State<Example10Horizontal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 25),
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isFirst: true,
            indicatorStyle: IndicatorStyle(
              height: 20,
              color: AppColors.secondaryElement,
            ),
            beforeLineStyle: LineStyle(
              color: Colors.grey,
              thickness: 6,
            ),
          ),
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            beforeLineStyle: const LineStyle(
              color: Colors.grey,
              thickness: 6,
            ),
            afterLineStyle: const LineStyle(
              color: Colors.grey,
              thickness: 6,
            ),
            indicatorStyle: const IndicatorStyle(
              height: 20,
              color: Colors.grey,
            ),
          ),
//          const TimelineDivider(
//            axis: TimelineAxis.vertical,
//            begin: 0.1,
//            end: 0.9,
//            thickness: 6,
//            color: Colors.deepOrange,
//          ),
          TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isLast: true,
            beforeLineStyle: const LineStyle(
              color: Colors.grey,
              thickness: 6,
            ),
            indicatorStyle: const IndicatorStyle(
              height: 20,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

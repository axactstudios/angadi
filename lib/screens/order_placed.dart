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

import 'package:angadi/classes/cart.dart';
import 'package:angadi/services/database_helper.dart';
import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/heading_row.dart';
import 'package:flutter/material.dart';
import 'package:angadi/routes/router.gr.dart' as R;
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderPlaced extends StatefulWidget {
  Widget bills;
  String docID;
  OrderPlaced(this.bills, this.docID);
  @override
  _OrderPlacedState createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              removeAll();
              R.Router.navigator.pushNamedAndRemoveUntil(
                R.Router.rootScreen,
                (Route<dynamic> route) => false,
              );
            },
            child: Icon(Icons.arrow_back_ios)),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Order Placed',
          style: Styles.customTitleTextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
            fontSize: Sizes.TEXT_SIZE_22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Your Order has been placed !',
                  style: Styles.customTitleTextStyle(
                    color: AppColors.accentText,
                    fontWeight: FontWeight.w300,
                    fontSize: Sizes.TEXT_SIZE_20,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Awaiting Restaurant Confirmation.',
                  style: Styles.customTitleTextStyle(
                    color: AppColors.accentText,
                    fontWeight: FontWeight.w300,
                    fontSize: Sizes.TEXT_SIZE_20,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  child: Column(
                children: [
                  Example10Horizontal(),
                  Lottie.asset('assets/animations/placed.json',
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
              widget.bills,
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
                              fontSize: Sizes.TEXT_SIZE_20,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            'Expected Delivery in 40 mins.',
                            style: Styles.customTitleTextStyle(
                              color: AppColors.headingText,
                              fontWeight: FontWeight.w400,
                              fontSize: Sizes.TEXT_SIZE_20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 0, top: 20),
                child: HeadingRow(
                  title: 'Delivery Boy Details',
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
                        Row(
                          children: [
                            Text('Name'),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.094,
                            ),
                            Text(':'),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Confirmation Awaited')
                          ],
                        ),
                        Row(
                          children: [
                            Text('Phone No.'),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02,
                            ),
                            Text(':'),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap: () {
                                launch('tel:+919027553376');
                              },
                              child: Text(
                                'Confirmation Awaited',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Vehicle'),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.083,
                            ),
                            Text(':'),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Confirmation Awaited'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
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
                          style: TextStyle(color: Colors.blue, fontSize: 20),
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
      final rowsDeleted = await dbHelper.delete(v.productName);
    }

    getAllItems();
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

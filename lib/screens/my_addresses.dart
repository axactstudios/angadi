import 'package:angadi/values/values.dart';
import 'package:angadi/widgets/potbelly_button.dart';
import 'package:flutter/material.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAddresses extends StatefulWidget {
  @override
  _MyAddressesState createState() => _MyAddressesState();
}

class _MyAddressesState extends State<MyAddresses> {
  var location = 'Dubai';

  LocationResult result;

  void showPlacePicker() async {
    print('called');
    result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw")));
    setState(() {
      location = result.formattedAddress;
    });
    // Handle the result in your way
    print(location);
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: angadiButton(
                '+ Add new address',
                buttonWidth: double.infinity,
                onTap: () {
                  showPlacePicker();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPang extends StatefulWidget {
  const MapPang({Key? key}) : super(key: key);

  @override
  State<MapPang> createState() => _MapPangState();
}

class _MapPangState extends State<MapPang> {
  GoogleMapController? myController;

  // ignore: deprecated_member_use
  late final dref = FirebaseDatabase.instance.reference();
  late double lat;
  late double long;
  late DatabaseReference databaseReference;
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  // void initMarker(specify, specifyId) async {
  //   var makerIdVal = specifyId;
  //   final MarkerId markerId = MarkerId(makerIdVal);
  //   final Marker marker = Marker(
  //     markerId: markerId,
  //     position: LatLng(specify[lat].latilude, specify[long].longtitude),
  //     infoWindow: InfoWindow(title: 'location', snippet: specify['address']),
  //   );
  //   setState(() {
  //     markers[markerId] = marker;
  //   });
  // }

  showdata() async {
    // DatabaseReference databaseReference =
    //     // ignore: deprecated_member_use
    //     FirebaseDatabase.instance.reference().child("Notifications");
    // await databaseReference.once().then((DataSnapshot) {
    //   var datadlet = DataSnapshot.snapshot.value;
    //   print(datadlet);
    // });

    DatabaseReference databaseReference_lat =
        // ignore: deprecated_member_use
        FirebaseDatabase.instance.ref("Gps/lat");
    DatabaseReference databaseReference_long =
        // ignore: deprecated_member_use
        FirebaseDatabase.instance.ref("Gps/long");
    DatabaseEvent event_lat = await databaseReference_lat.once();
    DatabaseEvent event_long = await databaseReference_long.once();
    lat = event_lat.snapshot.value;
    long = event_long.snapshot.value;

    // dref.child('Gps/lat').onValue.listen((event) {
    //   final lat = event.snapshot.value;
    //   print(lat);
    // });
    // dref.once().then((DataSnapshot) {
    //   print('Data : ${DataSnapshot.snapshot.value}');
    //   var s = DataSnapshot.snapshot.value;

    //   print(s);
    // });
  }

  // getMarkData() async {
  //   FirebaseFirestore.instance.collection('location').get().then((myMockDoc) {
  //     if (myMockDoc.docs.isNotEmpty) {
  //       for (int i = 0; i < myMockDoc.docChanges.length; i++) {
  //         initMarker(myMockDoc.docs[i].data(), myMockDoc.docs[i].id);
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // getMarkData();
    showdata();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> getMarker() {
      return <Marker>[
        Marker(
            markerId: MarkerId('Grocery store'),
            position: LatLng(lat, long),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: 'Ltioestn'))
      ].toSet();
    }

    return Scaffold(
      body: GoogleMap(
        markers: getMarker(),
        mapType: MapType.normal,
        initialCameraPosition:
            CameraPosition(target: LatLng(lat, long), zoom: 14.0),
        onMapCreated: (GoogleMapController controller) async {
          setState(() {
            myController = controller;
          });
        },
      ),
    );
  }
}

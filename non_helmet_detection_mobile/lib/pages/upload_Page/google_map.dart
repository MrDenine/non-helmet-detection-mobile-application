import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowMap extends StatefulWidget {
  List<double> value;
  ShowMap(this.value, {Key? key}) : super(key: key);

  @override
  _ShowMapState createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text(
          '${widget.value[0].toStringAsFixed(3)} ${widget.value[1].toStringAsFixed(3)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
          child: GoogleMap(
        myLocationEnabled: true,
        mapType: MapType.normal,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.value[0], widget.value[1]),
          zoom: 16,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          setState(() {
            _markers.add(Marker(
                markerId: MarkerId('1'),
                position: LatLng(widget.value[0], widget.value[1]),
                onTap: () {
                  googleMapOnWeb(widget.value[0], widget.value[1]);
                }));
          });
        },
      )),
    );
  }

  googleMapOnWeb(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {}
  }
}

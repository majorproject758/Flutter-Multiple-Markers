import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestMaps extends StatefulWidget {
  @override
  _TestMapsState createState() => _TestMapsState();
}

class _TestMapsState extends State<TestMaps> {

  GoogleMapController _controller;
  Position position;
  Widget _child;
  String _address;
  List <Placemark> placemark;
  double _lat;
  double _lng;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void getAddress(double latitude, double longitude) async {
    placemark = await Geolocator().placemarkFromCoordinates(latitude, longitude);
    _address = placemark[0].name.toString() + 
    ',' + 
    placemark[0].locality.toString() + 
    ', Postal Code:' +
    placemark[0].postalCode.toString();
    setState(() {
      _child = mapWidget();
    });
  }

  @override
  void initState() {
    _child = CircularProgressIndicator();
    getCurrentLocation();
    populateClients();
    super.initState();
  }

  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      _lat = position.latitude;
      _lng = position.longitude;
    });
    await getAddress(_lat, _lng);
  }

  populateClients() {
    Firestore.instance
    .collection('SteeringMarkers')
    .getDocuments()
    .then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; ++i) {
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }

  void initMarker(request, requestId) {
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker (
      markerId: markerId,
      position: LatLng(request['latitude'], request['longitude']),
      infoWindow: InfoWindow(title: 'Steering', snippet: _address),
    );
    setState(() {
      markers[markerId] = marker;
      print(markerId);
    });
  }





  // Set<Marker> _createMarker() {
  //   return <Marker>[
  //     Marker(
  //       markerId: MarkerId('Home'),
  //       position: LatLng(position.latitude, position.longitude),
  //       icon: BitmapDescriptor.defaultMarker,
  //       infoWindow: InfoWindow(title: 'Home', snippet: _address),
  //     )
  //   ].toSet();
  // }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing'),
        backgroundColor: Colors.black,
      ),
      body: _child,
    );
  }

  Widget mapWidget() {
    return GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(markers.values),
        // markers: _createMarker(),
        initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key?key}):super(key:key);
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(36.3066420,127.3426130 ); // 초기 중심 좌표
  final Set<Marker> _markers = {}; // 마커 집합

  // 지도가 준비되면 호출되는 콜백 함수
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      // 초기화시 마커 추가
      _markers.add(
        Marker(
          markerId: MarkerId("marker_1"),
          position: _center,
          infoWindow: InfoWindow(
            title: 'Konyang University Hospital',
            snippet: 'This is Konyang University Hospital!',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sake Store Map'),
        backgroundColor: Colors.lightBlueAccent[100],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0, // 초기 줌 레벨
        ),
        markers: _markers,
      ),
    );
  }
}
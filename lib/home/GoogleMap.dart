import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:sakesage/DatabaseHelper.dart';
import 'Product_list.dart';  // Product_list.dart 파일 임포트

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  LatLng _center = LatLng(37.5665, 126.9780); // 서울의 중심 좌표로 초기 설정
  final Set<Marker> _markers = {};
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  loc.LocationData? _currentLocation;
  String? _selectedStoreName;
  String? _selectedStoreAddress;

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
    _getCurrentLocation();
  }

  Future<void> _connectToDatabase() async {
    await _dbHelper.connect();
    _loadStoreLocations();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _getCurrentLocation() async {
    loc.Location location = loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    try {
      _currentLocation = await location.getLocation();
      setState(() {
        _center = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
        _markers.add(
          Marker(
            markerId: MarkerId("current_location"),
            position: _center,
            infoWindow: InfoWindow(
              title: 'Current Location',
            ),
          ),
        );
        mapController.animateCamera(
          CameraUpdate.newLatLng(_center),
        );
      });
    } catch (e) {
      print("Error getting current location: $e");
      // 현재 위치를 가져오지 못할 경우 예외 처리
    }
  }

  void _loadStoreLocations() async {
    try {
      List<Map<String, dynamic>> storeLocations = await _dbHelper.getStoreLocations();
      for (var store in storeLocations) {
        print('Store: ${store['store_name']}, Address: ${store['address']}'); // 디버깅 출력
        await _addMarker(store['store_name'], store['address'], store['phone'], store['business_hours']);
      }
    } catch (e) {
      print("Error loading store locations: $e");
    }
  }

  Future<void> _addMarker(String storeName, String address, String phone, String businessHours) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        print('Adding marker for $storeName at ${location.latitude}, ${location.longitude}'); // 디버깅 출력
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(storeName),
              position: LatLng(location.latitude, location.longitude),
              infoWindow: InfoWindow(
                title: storeName,
                snippet: '주소: $address\n전화: $phone\n영업 시간: $businessHours',
                onTap: () {
                  _showStoreInfoDialog(storeName, address, phone, businessHours);
                },
              ),
            ),
          );
        });
      } else {
        print('No locations found for address: $address'); // 디버깅 출력
      }
    } catch (e) {
      print("Error adding marker for $storeName: $e");
    }
  }

  Future<void> _searchLocation(String query) async {
    // 검색 결과 위치로 카메라 이동
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude),
            15.0,
          ),
        );
      } else {
        print('No locations found for query: $query');
      }
    } catch (e) {
      print("Error searching location for $query: $e");
    }
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      final currentLatLng = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 15.0),
      );
    }
  }

  void _showStoreInfoDialog(String storeName, String address, String phone, String businessHours) {
    setState(() {
      _selectedStoreName = storeName;
      _selectedStoreAddress = address;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(storeName),
          content: Text('주소: $address\n전화: $phone\n영업 시간: $businessHours'),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("사케 보러가기"),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToProductList();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToProductList() {
    if (_selectedStoreName != null && _selectedStoreAddress != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductListScreen(
            storeName: _selectedStoreName!,
            storeAddress: _selectedStoreAddress!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가게를 선택해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '오프라인 매장을 검색해보세요.',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _searchLocation(_searchController.text);
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _searchLocation(value);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _moveToCurrentLocation,
              tooltip: '현재 위치로 이동',
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
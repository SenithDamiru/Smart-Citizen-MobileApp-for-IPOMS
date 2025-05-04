import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'current_location.dart';
import 'fetch_police_stations.dart';

class PoliceStationsMapScreen extends StatefulWidget {
  const PoliceStationsMapScreen({super.key});

  @override
  _PoliceStationsMapScreenState createState() => _PoliceStationsMapScreenState();
}

class _PoliceStationsMapScreenState extends State<PoliceStationsMapScreen> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  void _loadMapData() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });

      List<Map<String, dynamic>> policeStations =
      await getNearbyPoliceStations(position.latitude, position.longitude);

      List<Marker> markers = policeStations.map((station) {
        return Marker(
          markerId: MarkerId(station['name']),
          position: LatLng(station['lat'], station['lng']),
          infoWindow: InfoWindow(title: station['name']),
        );
      }).toList();

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      print("Error fetching police stations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Police Stations")),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 14,
        ),
        markers: Set<Marker>.of(_markers),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

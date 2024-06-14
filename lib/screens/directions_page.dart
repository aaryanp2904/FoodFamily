// directions_page.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DirectionsPage extends StatefulWidget {
  final LatLng destination;

  const DirectionsPage({Key? key, required this.destination}) : super(key: key);

  @override
  _DirectionsPageState createState() => _DirectionsPageState();
}

class _DirectionsPageState extends State<DirectionsPage> {
  late GoogleMapController _mapController;
  LocationData? _currentLocation;
  final Location _locationService = Location();
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    _currentLocation = await _locationService.getLocation();
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: widget.destination,
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );

      // Create a polyline between the current location and the destination
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            widget.destination,
          ],
          color: Colors.blue,
          width: 5,
        ),
      );

      setState(() {});

      // Move the camera to show both current location and destination
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _currentLocation!.latitude! < widget.destination.latitude
                  ? _currentLocation!.latitude!
                  : widget.destination.latitude,
              _currentLocation!.longitude! < widget.destination.longitude
                  ? _currentLocation!.longitude!
                  : widget.destination.longitude,
            ),
            northeast: LatLng(
              _currentLocation!.latitude! > widget.destination.latitude
                  ? _currentLocation!.latitude!
                  : widget.destination.latitude,
              _currentLocation!.longitude! > widget.destination.longitude
                  ? _currentLocation!.longitude!
                  : widget.destination.longitude,
            ),
          ),
          50,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Directions')),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
            ),
    );
  }
}

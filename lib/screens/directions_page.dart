import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

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
  final String _googleApiKey = 'AIzaSyBKbHYROaOhDpf45YXHGk6weVRCyDNV4G0'; 

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
          markerId: const MarkerId('currentLocation'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destination,
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );

      await _getDirections();

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

  Future<void> _getDirections() async {
    final origin = '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    final destination = '${widget.destination.latitude},${widget.destination.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=walking&key=$_googleApiKey';

    print('Requesting directions from: $url');
    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Directions data: $data');

      if (data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        final polylinePoints = _decodePolyline(points);

        print('Decoded polyline points: $polylinePoints');

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylinePoints,
              color: Colors.red, // Ensure the polyline color is visible
              width: 5,
            ),
          );
        });
      } else {
        print('No routes found in the directions response.');
      }
    } else {
      // Handle the error by showing a message to the user or logging it
      print('Failed to fetch directions');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
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

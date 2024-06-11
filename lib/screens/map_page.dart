import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Define LatLng for each location
  final Map<String, LatLng> locations = {
    'Beit Quad': LatLng(51.4984, -0.1779),
    'Gabor Hall': LatLng(51.5001, -0.1759),
    'Linstead Hall': LatLng(51.5004, -0.1761),
    'Wilkinson Hall': LatLng(51.5003, -0.1768),
    'Kemp Porter Buildings': LatLng(51.5099, -0.2699),
    'Falmouth Hall': LatLng(51.4978, -0.1770),
    'Keogh Hall': LatLng(51.4975, -0.1757),
    'Selkirk Hall': LatLng(51.4974, -0.1756),
    'Tizard Hall': LatLng(51.4971, -0.1753),
    'Wilson House': LatLng(51.5143, -0.1704),
    'Woodward Buildings': LatLng(51.5131, -0.2704),
  };

  // Initial camera position
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(51.4984, -0.1779),
    zoom: 14,
  );

  // Google Maps Controller
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: locations.keys
            .map((location) => Marker(
                  markerId: MarkerId(location),
                  position: locations[location]!,
                  infoWindow: InfoWindow(
                    title: location,
                  ),
                ))
            .toSet(),
      ),
    );
  }
}

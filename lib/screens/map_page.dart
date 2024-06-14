// map_page.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'other_marketplace.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Map<String, LatLng> locations = {
    'Beit Quad': const LatLng(51.4999578, -0.1786947),
    'Gabor Hall': const LatLng(51.4994998, -0.1722478),
    'Linstead Hall': const LatLng(51.499768, -0.1720874),
    'Wilkinson Hall': const LatLng(51.499629, -0.1720501),
    'Kemp Porter Buildings': const LatLng(51.5099, -0.2699),
    'Falmouth Hall': const LatLng(51.4986411, -0.172552),
    'Keogh Hall': const LatLng(51.4985492, -0.1730125),
    'Selkirk Hall': const LatLng(51.4985999, -0.1725462),
    'Tizard Hall': const LatLng(51.4986622, -0.1724472),
    'Wilson House': const LatLng(51.5169551, -0.1700866),
    'Woodward Buildings': const LatLng(51.5131, -0.2704),
  };
  

  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(51.4984, -0.1779),
    zoom: 14,
  );

  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: locations.entries
            .map((entry) => Marker(
                  markerId: MarkerId(entry.key),
                  position: entry.value,
                  infoWindow: InfoWindow(
                    title: entry.key,
                    snippet: 'Click to view marketplace',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherMarketplace(
                            isDarkMode: ValueNotifier(false), // Provide your ValueNotifier instance for dark mode
                            accommodation: entry.key,
                          ),
                        ),
                      );
                    },
                  ),
                ))
            .toSet(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(12.9716,77.5946), zoom: 12),
            markers: _markers,
            onMapCreated: (c){ _controller = c; },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: fs.eventsWithLocationStream(),
            builder: (context, snapshot){
              if(!snapshot.hasData) return SizedBox();
              final docs = snapshot.data!.docs;
              final markers = docs.map((doc){
                final d = doc.data() as Map<String,dynamic>;
                final lat = d['lat'];
                final lng = d['lng'];
                final id = doc.id;
                return Marker(
                  markerId: MarkerId(id),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(title: d['type'] ?? 'event', snippet: d['source']),
                );
              }).toSet();
              if(mounted) setState(()=>_markers = markers);
              return SizedBox();
            },
          )
        ],
      ),
    );
  }
}

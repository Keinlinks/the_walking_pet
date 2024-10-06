import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:the_walking_pet/entities/User.dart';

class MainMap extends StatefulWidget {
  final List<User> userPets;
  const MainMap({Key? key, required this.userPets}) : super(key: key);

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  LatLng myLocation = const LatLng(51.509364, -0.128928);
  List<Marker> markers = [];
  MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
  
  void _moveCamera(LatLng position) {
    _mapController.move(position, _mapController.camera.zoom);
  }

  void _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("Location Services Enabled: $serviceEnabled");
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      print("Location Services Disabled");
      return;
    }
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position myPosition) {
      setState(() {
          myLocation = LatLng(myPosition.latitude, myPosition.longitude);
      });
    });
  }
  Future<Position> determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        print("Location Permission Denied Forever");
        return Future.error('Location Permission Denied');
      }
      else{
        return await Geolocator.getCurrentPosition();
      }
    }
    else{
      return await Geolocator.getCurrentPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Iquique"),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: myLocation, initialZoom: 9.2,),
          children: [TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: markers,),
          GestureDetector(
            onTap: (){

            },
            child: MarkerLayer(markers: [
              markerPet(myLocation, widget.userPets[0] )
              ],),
          )
        ],
          ),
        Positioned(
          bottom: 50,
          right: 25,
          child: GestureDetector(onTap: (){
            _moveCamera(myLocation);
          }, child: Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 30,),),)
          )
          ]
      ),
    );
  }
}

Marker markerPet(LatLng location, User user) {
  return Marker(
      point: location,
      height: 45,
      width: 45,
      child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Image(
            image: AssetImage(user.race.image),
            fit: BoxFit.cover,
          )));
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:the_walking_pet/entities/ApiCalls.dart';
import 'package:the_walking_pet/entities/User.dart';
import 'package:the_walking_pet/services/socketService.dart';

class MainMap extends StatefulWidget {
  final List<User> userPets;
  const MainMap({Key? key, required this.userPets}) : super(key: key);

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late SocketService socketService;
  String id = "";
  List<Marker> other_users_markers = [];
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    socketService = SocketService();
    socketService.identify(widget.userPets[0]);

    socketService.socket.on("selfId",(data){
      id = data.id;
    });
    
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
  
  void _moveCamera(LatLng position) {
    _mapController.move(position, _mapController.camera.zoom);
  }



  void _openFilterDialog(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Filtros"),
        content: SizedBox(
          width: double.maxFinite,
          child: Text("Filtros"),
          )
      );
    });
  }

  Stream<Position> stream_position() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).doOnData((myPosition) {
      // enviar a la api 
      ApiUpdateUserLocation payload = ApiUpdateUserLocation(id:id,latitude: myPosition.latitude,longitude: myPosition.longitude);
      socketService.socket.emit("update_user", payload);
    });
    
  }

   Stream<ApiUpdateUserLocation> stream_updateUserLocation() async*{
     socketService.socket.on("update_user",(message){
       ApiUpdateUserLocation payload = ApiUpdateUserLocation(id:message.id,latitude: message.latitude,longitude: message.longitude);
       setState(() {
         
       });
     });
   }

  // void _startLocationUpdates() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   print("Location Services Enabled: $serviceEnabled");
  //   if (!serviceEnabled) {
  //     Navigator.pop(context);
  //     print("Location Services Disabled");
  //     return;
  //   }
  //   _positionStream = Geolocator.getPositionStream(
  //     locationSettings: const LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       distanceFilter: 10,
  //     ),
  //   ).listen((Position myPosition) {
  //     setState(() {
  //         myLocation = Future.value(LatLng(myPosition.latitude, myPosition.longitude));
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Iquique"),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<Position>(
        stream: stream_position(),
        builder:(BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Cargando
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Error
        }
          if(snapshot.data != null){
          LatLng myPosition = LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
          return Stack(
          children: [FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: myPosition, initialZoom: 9.2,),
            children: [TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(markers: other_users_markers,),
            MarkerLayer(markers: [
              markerPet(myPosition, widget.userPets[0],context, true )
              ],
            ),
          ],
            ),
            Positioned(
              top: 20,
              right: 25,
              child: ElevatedButton(onPressed: (){
              _openFilterDialog();
            },
            child: const Text("Filtros"),
            )
            
            ),
          Positioned(
            bottom: 50,
            right: 25,
            child: GestureDetector(onTap: (){
              _moveCamera(myPosition);
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
        );
      }
      else{
        return const Center(child: Text("No hay posicion"));
      }
  }
  )
    
);
  }
}


Marker markerPet(LatLng location, User user,BuildContext context, bool isUser) {
  BoxBorder border_color(dangerousness){
    if (isUser){
      return Border.all(color: Colors.blue.withOpacity(0.7),width: 3);
    }
    if (dangerousness >= 0 && dangerousness <= 4){
      return Border.all(color: Colors.green.withOpacity(0.7),width: 3);
    }
    else if (dangerousness > 4 && dangerousness < 7){
      return Border.all(color: Colors.orange.withOpacity(0.7),width: 3);
    }
    else{
      return Border.all(color: Colors.red.withOpacity(0.7),width: 3);
    }
  }
void _openPetDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          user.race.name,
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: 300,
          height: double.maxFinite,
          child: DefaultTabController(
            initialIndex: 0,
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: <Widget>[
                    Tab(child: Text("Mascotas",style: TextStyle(fontSize: 12,color: Colors.black),),),
                    Tab(child: Text("Raza",style: TextStyle(fontSize: 12,color: Colors.black),),),
                  ],
                ),
                Expanded( // Usar Expanded para ocupar el espacio disponible
                  child: TabBarView(
                    children: <Widget>[
                      ListView(
                        children: [
                            const SizedBox(height: 10,),
                            const Text("Mascota 1"),
                            const SizedBox(height: 10,),
                            Text("Raza: ${user.race.name}"),
                            const SizedBox(height: 10,),
                            Text("Genero: ${user.gender}"),
                            const SizedBox(height: 10,),
                            Text("Años: ${user.age}"),
                            const SizedBox(height: 10,),
                            Text("Meses: ${user.month}"),
                            const SizedBox(height: 10,),
                            Text("Dias: ${user.day}"),
                          ],
                      ),
                      Column(
                        children: [
                          Center(child:Image(image: AssetImage(user.race.image),fit: BoxFit.cover,),),
                          const SizedBox(height: 10,),
                          Text(user.race.description),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Center(child: Text("Cerrar")),
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
          ),
        ],
      );
    },
  );
}
  return Marker(
      point: location,
      rotate: true,
      height: 100,
      width: 100,
      child: GestureDetector(
        onTap: (){
          _openPetDialog();
        },
        child: Column(
          children: [Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: border_color(user.dangerousness),
              
              ),
              child: Image(
                image: AssetImage(user.race.image),
                fit: BoxFit.cover,
              )),
              const SizedBox(height: 2,),
              Text(
                user.race.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              )
              ]
        ),
      ));
}

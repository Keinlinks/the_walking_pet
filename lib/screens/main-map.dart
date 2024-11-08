import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:the_walking_pet/entities/ApiCalls.dart';
import 'package:the_walking_pet/entities/Pet.dart';
import 'package:the_walking_pet/entities/Race.dart';
import 'package:the_walking_pet/entities/User.dart';
import 'package:the_walking_pet/entities/filters.dart';
import 'package:the_walking_pet/services/socketService.dart';
import 'package:the_walking_pet/shared/constants.dart';


class LatLngAndMarker {
  LatLng position;
  Marker marker;
  User user;

  LatLngAndMarker(this.position, this.marker,this.user);
}

class GlobalState {
  Map<String,LatLngAndMarker> other_users_markers = {};
  late Position myPosition;
  GlobalState();

  setMyPosition(Position myPosition){
    this.myPosition = myPosition;
  }
  setOtherUsersMarkers(Map<String,LatLngAndMarker> other_users_markers){
    this.other_users_markers = other_users_markers;
  }

  updateOtherUser(UserDataExtended otherUserData,BuildContext context){
    if (other_users_markers.containsKey(otherUserData.id)){
      other_users_markers[otherUserData.id]?.marker = markerPet(other_users_markers[otherUserData.id]!.position, other_users_markers[otherUserData.id]!.user, false,context);
      }
  }
}

class MainMap extends StatefulWidget {
  final User userPets;
  const MainMap({Key? key, required this.userPets}) : super(key: key);

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late SocketService socketService;
  Filters filters = Filters();
  String id = "";
  Map<String,LatLngAndMarker> other_users_markers = {};
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;

  GlobalState globalState = GlobalState();

  @override
  void initState() {
    super.initState();
    socketService = SocketService();
    print(widget.userPets.toJson());
    socketService.identify(widget.userPets.toJson());

    socketService.socket.on("selfId",(data){
      print(data);
      id = data.id;
      print("selfId: $id");
    });
  }

  void addUser(){

  }

  @override
  void dispose() {
    _positionStream?.cancel();
    socketService.socket.disconnect();
    super.dispose();
  }
  
  void _moveCamera(LatLng position) {
    _mapController.move(position, _mapController.camera.zoom);
  }

  String getGenderText(bool gender){
    return gender ? "Macho" : "Hembra";
  }



  void _openFilterDialog(){
    showDialog(context: context, builder: (context){
      DropdownButton getDropdownFromMap(Map<String, String> filter, void Function(String?)? onChangeFunc,String value){
        List<DropdownMenuItem<String>> keys = filter.entries.map((e) => DropdownMenuItem<String>(child:  Text(e.key), value: e.value,)).toList();
        return DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: keys,
          onChanged: onChangeFunc
        );
      };
      DropdownButton getDropdownFromList(List<String> filter, void Function(String?)? onChangeFunc,String value){
        List<DropdownMenuItem<String>> keys = filter.map((e) => DropdownMenuItem<String>(child:  Text(e), value: e,)).toList();
        return DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: keys,
          onChanged: onChangeFunc,
        );
      };

      return StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter builder){
          return AlertDialog(
          title: const Text("Filtros"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(children: [
              const Text("Peligrosidad"),
              getDropdownFromMap(filters.getDangerousness(), (p0) { 
                builder(() {
                filters.selectedDangerousness = p0!;

                });
              }, filters.selectedDangerousness),
              const Divider(thickness: 2,color: Color.fromARGB(20, 0, 0, 0),),
              const Text("Genero"),
              getDropdownFromList(filters.getGender(), (p0) {
                builder(() {
                filters.selectedGender = p0!;
                }); 
              }, filters.selectedGender),
              const Divider(thickness: 2,color: Color.fromARGB(20, 0, 0, 0),),
              const Text("Edad"),
              getDropdownFromList(filters.getAge(), (p0) {
                builder(() {
                filters.selectedAge = p0!;
                }); 
              },filters.selectedAge),
              const Divider(thickness: 2,color: Color.fromARGB(20, 0, 0, 0),),
              const Text("Raza"),
              getDropdownFromList(filters.getRaces().map((e) => e.name).toList(), (p0) { 
                builder(() {
                filters.selectedRace = p0!;
                });
              },filters.selectedRace),
            ]
            ),
          ),
          actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Aplicar'),
                onPressed: () {
                  setState(() {
                    
                  });
                  Navigator.pop(context);
                },
              ),
            ],
        );
        }
      );
    });
  }

  Stream<GlobalState> stream_myPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).doOnData((myPosition) {
      // enviar a la api 
      ApiUpdateUserLocation payload = ApiUpdateUserLocation(id:id,latitude: myPosition.latitude,longitude: myPosition.longitude,city: widget.userPets.city);
      socketService.socket.emit("update_user_location", payload);
    }).transform(StreamTransformer<Position, GlobalState>.fromHandlers(handleData: (myPosition, sink) {
        globalState.setMyPosition(myPosition);
        sink.add(globalState);
    }));
  }

  Stream<GlobalState> stream_getNewUser() async*{
    final controller = StreamController<GlobalState>();
      socketService.socket.on("receive_userData",(newUserData){
      
      UserDataExtended(id: newUserData.id,latitude: newUserData.latitude,longitude: newUserData.longitude,
      city: newUserData.city,pet_1: newUserData.pet_1,pet_2: newUserData.pet_2);
      if (other_users_markers.containsKey(newUserData.id)){
        
      }
      else{
        Marker newMarker = markerPet(LatLng(newUserData.latitude, newUserData.longitude), newUserData, false,context);
        other_users_markers[newUserData.id] = LatLngAndMarker(LatLng(newUserData.latitude, newUserData.longitude),newMarker,newUserData);
      }
      controller.add(globalState);
     });
     yield* controller.stream;
  }

   Stream<GlobalState> stream_updateOtherUserLocation() async*{
      final controller = StreamController<GlobalState>();
      socketService.socket.on("receive_user_location",(otherUserData){
      ApiUpdateUserLocation(id:otherUserData.id,latitude: otherUserData.latitude,longitude: otherUserData.longitude,city: otherUserData.city);
      if (other_users_markers.containsKey(otherUserData.id)){
      other_users_markers[otherUserData.id]?.marker = markerPet(other_users_markers[otherUserData.id]!.position, other_users_markers[otherUserData.id]!.user, false,context);
      }
      controller.add(globalState);
     });
     yield* controller.stream;
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
      body: StreamBuilder<GlobalState>(
        stream: MergeStream([stream_myPosition(),stream_updateOtherUserLocation()]),
        builder:(BuildContext context, AsyncSnapshot<GlobalState> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Cargando
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Error
        }
          if(snapshot.data != null){
          LatLng myPosition = LatLng(snapshot.data!.myPosition.latitude, snapshot.data!.myPosition.longitude);
          return Stack(
          children: [FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: myPosition, initialZoom: 18,),
            children: [TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(markers: snapshot.data?.other_users_markers.values.toList().map((e) => e.marker).toList() ?? []),
            MarkerLayer(markers: [
              markerPet(myPosition, widget.userPets, true,context )
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


Marker markerPet(LatLng location, User user, bool isUser,BuildContext context) {
  List<Race>raceList = Constants.raceList;
  Race race_1 = raceList.firstWhere((element) => element.id == user.pet_1.raceId);
  Race race_2 = raceList.firstWhere((element) => element.id == user.pet_2.raceId);
  
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
  
void _openPetDialog(BuildContext context) {
  double dangerousness_mean = (user.pet_1.dangerousness + user.pet_2.dangerousness) / 2;
  String getGenderText(bool gender){
    return gender ? "Macho" : "Hembra";
  };
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Peligrosidad media: ${dangerousness_mean.toStringAsFixed(2)}",
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
                            Text("Nombre: ${user.pet_1.name}"),
                            const SizedBox(height: 10,),
                            Text("Raza: ${race_1.name}"),
                            const SizedBox(height: 10,),
                            Text("Genero: ${getGenderText(user.pet_1.gender)}"),
                            const SizedBox(height: 10,),
                            Text("Años: ${user.pet_1.age}"),
                            const SizedBox(height: 10,),
                            Text("Meses: ${user.pet_1.month}"),
                            const SizedBox(height: 10,),
                            Text("Dias: ${user.pet_1.day}"),
                            const SizedBox(height: 50,),
                            const Divider(thickness: 2,color: Color.fromARGB(20, 0, 0, 0),),
                            if (race_2.id != 0) ...[
                            Text("Mascota 2: ${user.pet_2.name}"),
                            const SizedBox(height: 10,),
                            Text("Raza: ${race_2.name}"),
                            const SizedBox(height: 10,),
                            Text("Genero: ${getGenderText(user.pet_1.gender)}"),
                            const SizedBox(height: 10,),
                            Text("Años: ${user.pet_2.age}"),
                            const SizedBox(height: 10,),
                            Text("Meses: ${user.pet_2.month}"),
                            const SizedBox(height: 10,),
                            Text("Dias: ${user.pet_2.day}"),
                            ],
                            
                          ],
                      ),
                      Column(
                        children: [
                          Center(child:Image(image: AssetImage(race_1.image),fit: BoxFit.cover,),),
                          const SizedBox(height: 10,),
                          Text(race_1.description),
                          const Divider(thickness: 2,color: Color.fromARGB(20, 0, 0, 0),),
                          if (race_2.id != 0) ...[
                            Center(
                              child: Image(
                                image: AssetImage(race_1.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(race_1.description),
                          ],
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
          _openPetDialog(context);
        },
        child: Column(
          children: [Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: border_color(user.pet_1.dangerousness),
              
              ),
              child: Image(
                image: AssetImage(race_1.image),
                fit: BoxFit.cover,
              )),
              const SizedBox(height: 2,),
              Text(
                user.pet_1.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              )
              ]
        ),
      ));
}

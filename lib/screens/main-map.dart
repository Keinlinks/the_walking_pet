import 'dart:async';
import 'dart:convert';
import 'package:deepcopy/deepcopy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:the_walking_pet/entities/ApiCalls.dart';
import 'package:the_walking_pet/entities/Race.dart';
import 'package:the_walking_pet/entities/User.dart';
import 'package:the_walking_pet/entities/filters.dart';
import 'package:the_walking_pet/services/socketService.dart';
import 'package:the_walking_pet/shared/constants.dart';


class LatLngAndMarker {
  late LatLng position;
  Marker marker;
  User user;

  LatLngAndMarker(this.position, this.marker,this.user);
}

class GlobalState {
  Map<String,LatLngAndMarker> other_users_markers = {};
  Position? myPosition;
  String? id;
  Map<String,LatLngAndMarker> other_users_markersFiltered = {};
  Filters filters = Filters();

  GlobalState();

  setMyPosition(Position myPosition){
    this.myPosition = myPosition;
  }
  setId(String id){
    this.id = id;
  }
  setOtherUsersMarkers(Map<String,LatLngAndMarker> other_users_markers){
    this.other_users_markers = other_users_markers;
    updateFilters();
  }

  updateOtherUser(String id, latitude,longitude,BuildContext context){
    if (other_users_markers.containsKey(id)){
      LatLngAndMarker m = other_users_markers[id]!;
      m.position = LatLng(latitude,longitude);
      m.marker = markerPet(m.position, m.user, false,context);
      }
    updateFilters();
  }

  removeOtherUser(String id){
    if (other_users_markers.containsKey(id)){
      print("se elimino el usuario ${id}");
      other_users_markers.remove(id);
    }
    updateFilters();
  }

  updateFilters(){
    other_users_markersFiltered = (other_users_markers.deepcopy()).cast<String,LatLngAndMarker>();
    if (filters.selectedDangerousness == "") filters.selectedDangerousness = "No filtro";
    if (filters.selectedGender == "") filters.selectedGender = "No filtro";
    print(filters.selectedDangerousness);
    print(filters.selectedGender);
    if (filters.selectedDangerousness != "No filtro") {
      other_users_markersFiltered = Map.fromEntries(other_users_markers.entries.where((element) => element.value.user.pet_1.dangerousness == filters.selectedDangerousness || element.value.user.pet_2.dangerousness == filters.selectedDangerousness));
    }
    if (filters.selectedGender != "No filtro") {
      other_users_markersFiltered = Map.fromEntries(other_users_markersFiltered.entries.where((element) => element.value.user.pet_1.gender == filters.selectedGender || element.value.user.pet_2.gender == filters.selectedGender));
    }
    print("se filtro: ${other_users_markersFiltered.length}");
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
  bool isIdentify = false;
  late StreamController<GlobalState> controllerFilters;
  late Future<bool> idLoaded;
  Map<String,LatLngAndMarker> other_users_markers = {};
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  bool isloaded = false;

  GlobalState globalState = GlobalState();

  @override
  void initState() {
    super.initState();
    controllerFilters = StreamController<GlobalState>();
    if(!widget.userPets.completedForm) Navigator.pop(context);
    socketService = SocketService();
    socketService.socket.onDisconnect((data) {
      print("Disconnected");
    });
    socketService.socket.onError((data) {
       print("Error conectando: $data");
       if (mounted) Navigator.pop(context);
       });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    controllerFilters.close();
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
      DropdownButton getDropdownFromList(List<String> filter, void Function(String?)? onChangeFunc,String value){
        List<DropdownMenuItem<String>> keys = filter.map((e) => DropdownMenuItem<String>(value: e,child:  Text(e),)).toList();
        return DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: keys,
          onChanged: onChangeFunc,
        );
      }
      Filters filtersCopy = globalState.filters.copy();

      return StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter builder){
          return AlertDialog(
          title: const Text("Filtros"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(children: [
              const Text("Peligrosidad"),
              getDropdownFromList(globalState.filters.getDangerousness(), (p0) { 
                builder(() {
                filtersCopy.selectedDangerousness = p0!;

                });
              }, filtersCopy.selectedDangerousness),
              const Divider(thickness: 2,color: Color.fromARGB(20, 0, 0, 0),),
              const Text("Genero"),
              getDropdownFromList(globalState.filters.getGender(), (p0) {
                builder(() {
                filtersCopy.selectedGender = p0!;
                }); 
              }, filtersCopy.selectedGender),
              // const Divider(thickness: 2,color: Color.fromARGB(20, 0, 0, 0),),
              // const Text("Edad"),
              // getDropdownFromList(filters.getAge(), (p0) {
              //   builder(() {
              //   filtersCopy.selectedAge = p0!;
              //   }); 
              // },filtersCopy.selectedAge),
              // const Divider(thickness: 2,color: Color.fromARGB(20, 0, 0, 0),),
              // const Text("Raza"),
              // getDropdownFromList(filters.getRaces().map((e) => e.name).toList(), (p0) { 
              //   builder(() {
              //   filtersCopy.selectedRace = p0!;
              //   });
              // },filtersCopy.selectedRace),
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
                  globalState.filters = filtersCopy.copy();
                  globalState.updateFilters();
                  controllerFilters.add(globalState);
                  Navigator.pop(context);
                },
              ),
            ],
        );
        }
      );
    });
  }

  Future<void> futureGetId() async {
  final completer = Completer<void>();
  socketService.socket.on("selfId", (data) {
    if (completer.isCompleted) return;
    globalState.setId(data["token"]);
    widget.userPets.setId(data["token"]);
    completer.complete();
  });
  socketService.socket.emit("selfId");

  return completer.future;
}
  
  Stream<GlobalState> stream_myPosition() {
    
    if (widget.userPets.id == "") return Stream.empty();
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).doOnData((myPosition) {
      if (widget.userPets.pet_1.raceId == 22) return;
      ApiUpdateUserLocation payload = ApiUpdateUserLocation(id:widget.userPets.id,latitude: myPosition.latitude,longitude: myPosition.longitude,city: widget.userPets.city);

      print("combio mi posicion: ${myPosition.latitude} ${myPosition.longitude}");
      if (!isIdentify){
      socketService.socket.emit("identify", [widget.userPets.toJson(),payload.toJson()]);
      isIdentify = true;
      return;
      }
      // enviar a la api 

      socketService.socket.emit("update_user_location", payload.toJson());
    }).transform(StreamTransformer<Position, GlobalState>.fromHandlers(handleData: (myPosition, sink) {
        globalState.setMyPosition(myPosition);
        sink.add(globalState);
    }));
  }

  Stream<GlobalState> stream_getNewUser() async*{
    final controller = StreamController<GlobalState>();
      socketService.socket.on("receive_userData",(newUserData){
      print("recibiendo nuevo usuario: ${newUserData['id']}");
      
      if (other_users_markers.containsKey(newUserData['id'])){
        
      }
      else if (mounted){
        User user = User.fromJson(newUserData);
        Marker newMarker = markerPet(LatLng(newUserData['latitude'], newUserData['longitude']), user, false,context);
        other_users_markers[newUserData['id']] = LatLngAndMarker(LatLng(newUserData['latitude'], newUserData['longitude']),newMarker,user);
        globalState.setOtherUsersMarkers( other_users_markers);
        ApiUpdateUserLocation payload = ApiUpdateUserLocation.withReceiver(widget.userPets.id,globalState.myPosition!.latitude,globalState.myPosition!.longitude,widget.userPets.city,newUserData['id']);
        
        String myUser = widget.userPets.toJson();
        print("emitiendo datos a :${newUserData['id']}");
        socketService.socket.emit("update_userdata_to_user", [myUser,payload.toJson(),]);
      }
      controller.add(globalState);
     });
     yield* controller.stream;
  }

   Stream<GlobalState> stream_updateOtherUserLocation() async*{
      final controller = StreamController<GlobalState>();
      socketService.socket.on("receive_user_location",(otherUserData){
        print("recibido user_location ${otherUserData}");
      ApiUpdateUserLocation(id:otherUserData['id'],latitude: otherUserData['latitude'],longitude: otherUserData['longitude'],city: otherUserData['city']);
      if (other_users_markers.containsKey(otherUserData['id']) && mounted){
      globalState.updateOtherUser(otherUserData['id'], otherUserData["latitude"], otherUserData["longitude"], context);
      }
      controller.add(globalState);
     });
     yield* controller.stream;
   }

   Stream<GlobalState> stream_remove() async*{
      final controller = StreamController<GlobalState>();
      socketService.socket.on("remove_user",(otherUserData){
      globalState.removeOtherUser(otherUserData['id']);
      controller.add(globalState);
     });
     yield* controller.stream;
   }
  


  @override
  Widget build(BuildContext context) {
    if(!widget.userPets.completedForm) Navigator.pop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Iquique"),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: futureGetId(),
        builder:(context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Cargando
          }
          return StreamBuilder<GlobalState>(
          stream: MergeStream([stream_myPosition(),stream_updateOtherUserLocation(),stream_getNewUser(),stream_remove(),controllerFilters.stream]),
          builder:(BuildContext contextStream, AsyncSnapshot<GlobalState> snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Cargando
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error
          }
            if(snapshot.data != null && mounted && snapshot.data!.id != "" && snapshot.data!.myPosition != null){
              if(snapshot.data!.other_users_markers.isNotEmpty){
            
      
              }
            
            LatLng myPosition = LatLng(snapshot.data!.myPosition!.latitude, snapshot.data!.myPosition!.longitude);
            return Stack(
            children: [FlutterMap(
              
              mapController: _mapController,
              options: MapOptions(initialCenter: myPosition, initialZoom: 18,),
              children: [TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.thewalkingpet.app',
              errorTileCallback: (tile, error, stackTrace) => const Icon(Icons.error),
              tileProvider: NetworkTileProvider(),
              
              ),
              MarkerLayer(markers: snapshot.data?.other_users_markersFiltered.values.toList().map((e) => e.marker).toList() ?? []),
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
          return const Center(child: CircularProgressIndicator());
        }
        }
        );
        }
      )
    
);
  }
}

Marker markerPet(LatLng location, User user, bool isUser,BuildContext context) {
  List<Race>raceList = Constants.raceList;
  Race race_1 = raceList.firstWhere((element) => element.id == user.pet_1.raceId);
  Race race_2 = raceList.firstWhere((element) => element.id == user.pet_2.raceId);
  
  BoxBorder border_color(String dangerousness){
    if (isUser){
      return Border.all(color: Colors.blue.withOpacity(0.7),width: 3);
    }
    if (dangerousness == "Amigable"){
      return Border.all(color: Colors.green.withOpacity(0.7),width: 3);
    }
    else if (dangerousness== "No amigable"){
      return Border.all(color: Colors.orange.withOpacity(0.7),width: 3);
    }
    else{
      return Border.all(color: Colors.red.withOpacity(0.7),width: 3);
    }
  }
  
void _openPetDialog(BuildContext context) {
  String getGenderText(bool gender){
    return gender ? "Macho" : "Hembra";
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(user.pet_1.dangerousness,
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
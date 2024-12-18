import 'dart:async';
import 'package:deepcopy/deepcopy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:the_walking_pet/shared/components/settingsComponent.dart';
import 'package:the_walking_pet/shared/constants.dart';
import 'package:geodesy/geodesy.dart';

class LatLngAndMarker {
  late LatLng position;
  bool adviced = false;
  Marker marker;
  User user;

  LatLngAndMarker(this.position, this.marker,this.user);
}

class GlobalState {
  Map<String,LatLngAndMarker> other_users_markers = {};
  Position? myPosition;
  bool adviceJustDAngerous = false;
  String? id;
  Map<String,LatLngAndMarker> other_users_markersFiltered = {};
  Filters filters = Filters();
  num adviceDistanceInMeter = 150;
  bool vibrator = true;
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
      other_users_markers.remove(id);
    }
    updateFilters();
  }

  updateFilters(){
    other_users_markersFiltered = (other_users_markers.deepcopy()).cast<String,LatLngAndMarker>();
    if (filters.selectedDangerousness == "") filters.selectedDangerousness = "No filtro";
    if (filters.selectedGender == "") filters.selectedGender = "No filtro";
    if (filters.selectedDangerousness != "No filtro") {
      other_users_markersFiltered = Map.fromEntries(other_users_markersFiltered.entries.where((element) => element.value.user.pet_1.dangerousness == filters.selectedDangerousness || element.value.user.pet_2.dangerousness == filters.selectedDangerousness));
    }
    if (filters.selectedGender != "No filtro") {
      other_users_markersFiltered = Map.fromEntries(other_users_markersFiltered.entries.where((element) => element.value.user.pet_1.gender == (filters.selectedGender == "Macho") || element.value.user.pet_2.gender == (filters.selectedGender == "Macho")));
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
  bool isIdentify = false;
  Geodesy geodesy = Geodesy();
  late StreamController<GlobalState> controllerFilters;
  late Future<bool> idLoaded;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  bool isloaded = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<String> dangersId = [];


  GlobalState globalState = GlobalState();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    controllerFilters = StreamController<GlobalState>();
    if(!widget.userPets.completedForm) Navigator.pop(context);
    socketService = SocketService();
    socketService.socket.onDisconnect((data) {
      print("Disconnected");
    });
    socketService.socket.onError((data) {
       print("Error conectando: $data");
       if (mounted) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Error conectando con el servidor, intenta de nuevo en unos minutos"),
            actions: [
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
       }
      });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    controllerFilters.close();
    socketService.socket.disconnect();
    super.dispose();
  }


  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }
  void _onNotificationResponse(NotificationResponse response) {
    openDangersDialog(context);
  }

  Future<void> _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'Alerta de mascota cerca',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Alerta The Walking Pet',
      'Hay mascotas cerca',
      notificationDetails,
    );
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
                child: const Text('Quitar todo'),
                onPressed: () {
                  builder(() {
                    filtersCopy = Filters();

                });
                },
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
    
    if (widget.userPets.id == "") return const Stream.empty();
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).doOnData((myPosition) {
      evaluate_dangersWithAll();
      if (widget.userPets.pet_1.raceId == 22) return;
      ApiUpdateUserLocation payload = ApiUpdateUserLocation(id:widget.userPets.id,latitude: myPosition.latitude,longitude: myPosition.longitude,city: widget.userPets.city);

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
      
      if (globalState.other_users_markers.containsKey(newUserData['id'])){
        
      }
      else if (mounted){
        User user = User.fromJson(newUserData);
        Marker newMarker = markerPet(LatLng(newUserData['latitude'], newUserData['longitude']), user, false,context);
        globalState.other_users_markers[newUserData['id']] = LatLngAndMarker(LatLng(newUserData['latitude'], newUserData['longitude']),newMarker,user);
        globalState.setOtherUsersMarkers( globalState.other_users_markers);
        ApiUpdateUserLocation payload = ApiUpdateUserLocation.withReceiver(widget.userPets.id,globalState.myPosition!.latitude,globalState.myPosition!.longitude,widget.userPets.city,newUserData['id']);
        
        String myUser = widget.userPets.toJson();
        print("emitiendo datos a :${newUserData['id']}");
        socketService.socket.emit("update_userdata_to_user", [myUser,payload.toJson(),]);
        evaluate_dangers(globalState.other_users_markers[newUserData['id']]!);
      }
      controller.add(globalState);
     });
     yield* controller.stream;
  }

   Stream<GlobalState> stream_updateOtherUserLocation() async*{
      final controller = StreamController<GlobalState>();
      socketService.socket.on("receive_user_location",(otherUserData){
      ApiUpdateUserLocation(id:otherUserData['id'],latitude: otherUserData['latitude'],longitude: otherUserData['longitude'],city: otherUserData['city']);
      if (globalState.other_users_markers.containsKey(otherUserData['id']) && mounted){
      globalState.updateOtherUser(otherUserData['id'], otherUserData["latitude"], otherUserData["longitude"], context);
      }
      evaluate_dangers(globalState.other_users_markers[otherUserData['id']]!);
      controller.add(globalState);
     });
     yield* controller.stream;
   }

   Stream<GlobalState> stream_remove() async*{
      final controller = StreamController<GlobalState>();
      socketService.socket.on("remove_user",(otherUserData){
      globalState.removeOtherUser(otherUserData['id']);
      dangersId.remove(otherUserData['id']);
      controller.add(globalState);
     });
     yield* controller.stream;
   }
  
  void evaluate_dangers(LatLngAndMarker latLngAndMarker) async {

    LatLng l1 = LatLng(latLngAndMarker.position.latitude, latLngAndMarker.position.longitude);
    LatLng l2 = LatLng(globalState.myPosition!.latitude, globalState.myPosition!.longitude);
    if (globalState.adviceJustDAngerous && latLngAndMarker.user.pet_1.dangerousness == "Amigable") return;
    num distanceInMeters = geodesy.distanceBetweenTwoGeoPoints(l1, l2);
    if (distanceInMeters > globalState.adviceDistanceInMeter) {
      latLngAndMarker.adviced = false;
      dangersId.remove(latLngAndMarker.user.id);
      return;
    };
    if (latLngAndMarker.adviced) return;

    latLngAndMarker.adviced = true;
    if (!dangersId.contains(latLngAndMarker.user.id)) {
      dangersId.add(latLngAndMarker.user.id);
    }
    if (globalState.vibrator) HapticFeedback.vibrate();

    _showNotification();
  }
  void evaluate_dangersWithAll(){
      for (var key in globalState.other_users_markers.keys){
        evaluate_dangers(globalState.other_users_markers[key]!);
      }
  }
  

  openDangersDialog(BuildContext context){
    List<Race>raceList = Constants.raceList;
    
    if (dangersId.isEmpty){
      showDialog(
      context: context,
      builder: (BuildContext modalContext) {
        return AlertDialog(
          title: const Text("Alertas"),
          content: SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                const Text("No hay peligros cercanos",style: TextStyle(fontSize: 25,color: Colors.greenAccent),),
                const SizedBox(height: 10,),
                Text("Hay ${dangersId.length} mascotas que pueden ser peligrosas"),
              ],
              ),
            ),
          ),
           actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.pop(modalContext),
            ),
          ],
        );
      },
    );
      
      return;
    }
    showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: const Text("Alertas"),
      content: SizedBox(
        width: double.maxFinite,
        height: 300, // Establece una altura para el contenido
        child: Column(
          children: [
            const Text("¡Atención!", style: TextStyle(fontSize: 25, color: Colors.redAccent)),
            const SizedBox(height: 10),
            Text("¡Hay ${dangersId.length} mascota(s) que puede(n) ser peligrosa(s)!"),
            const SizedBox(height: 10),
            Expanded(  // Usamos Expanded para darle espacio adecuado al GridView
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.7,
                ),
                itemCount: dangersId.length,
                itemBuilder: (context, index) {
                  final LatLngAndMarker latLngAndMarker = globalState.other_users_markers[dangersId[index]]!;
                  Race race_1 = raceList.firstWhere((element) => element.id == latLngAndMarker.user.pet_1.raceId);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _moveCamera(latLngAndMarker.position);
                    },
                    onLongPress: () {
                      
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image(
                            image: AssetImage(race_1.image),
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          race_1.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  },
);
  }

openSettingsDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajustes"),
          content: SettingsWidget(globalState: globalState,),
          actions: [
            TextButton(
              child: const Text('Guardar'),
              onPressed: () => Navigator.pop(context),
            ),
            ]
          );
    }
  );
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
              ),
              Positioned(
              top: 20,
              left: 25,
              child: GestureDetector(onTap: (){
                openDangersDialog(context);
              }, child: Container(
                width: 50,
                height: 50,
                clipBehavior: Clip.antiAlias,

                decoration: BoxDecoration(
                  color: dangersId.isNotEmpty ? const Color.fromARGB(255, 194, 34, 34) : const Color.fromARGB(255, 128, 180, 123),
                  borderRadius: BorderRadius.circular(50),

                ),
                child: const Icon(Icons.warning, color: Colors.white, size: 25,),),)
              ),
              Positioned(
              top: 20,
              left: 95,
              child: GestureDetector(onTap: (){
                openSettingsDialog(context);
              }, child: Container(
                width: 50,
                height: 50,
                clipBehavior: Clip.antiAlias,

                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(50),

                ),
                child: const Icon(Icons.settings, color: Colors.white, size: 25,),),)
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
  
  return Marker(
      point: location,
      rotate: true,
      height: 100,
      width: 100,
      child: GestureDetector(
        onTap: (){
          _openPetDialog(context,user);
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

void _openPetDialog(BuildContext context, User user) {
  List<Race>raceList = Constants.raceList;
  Race race_1 = raceList.firstWhere((element) => element.id == user.pet_1.raceId);
  Race race_2 = raceList.firstWhere((element) => element.id == user.pet_2.raceId);
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
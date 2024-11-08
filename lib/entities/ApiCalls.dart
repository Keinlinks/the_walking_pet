import 'dart:convert';

import 'package:the_walking_pet/entities/Pet.dart';

class ApiUpdateUserLocation{
  String id = "";
  double latitude = 0.0;
  double longitude = 0.0;
  String city = "";

  ApiUpdateUserLocation({
    id,
    latitude,
    longitude,
    city,
  }){
    this.id = id;
    this.latitude = latitude;
    this.longitude = longitude;
    this.city = city;
  }

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
    };
  }

  // Método para obtener JSON
  String toJson() {
    return jsonEncode(toMap());
  }
  
}


class UserDataExtended extends ApiUpdateUserLocation{
    Pet pet_1 = Pet();
    Pet pet_2 = Pet();

    UserDataExtended({
        id,
        latitude,
        longitude,
        city,
        required this.pet_1,
        required this.pet_2,
    }){
        super.id = id;
        super.latitude = latitude;
        super.longitude = longitude;
        super.city = city;
    }

    Map<String, dynamic> toMap() {
      Map<String, dynamic> userMap = super.toMap();
      Map<String, dynamic> pet_1_map = pet_1.toMap();
      Map<String, dynamic> pet_2_map = pet_2.toMap();

      return {...userMap, ...pet_1_map, ...pet_2_map };
    }

  // Método para obtener JSON
  String toJson() {
    return jsonEncode(toMap());
  }


}
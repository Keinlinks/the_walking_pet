import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

import 'package:the_walking_pet/entities/Pet.dart';
@JsonSerializable()
class User {
  String id = "";
  Pet pet_1 = Pet().withRaceId(1);
  Pet pet_2 = Pet();
  List<String> personality = [];
  String city = "";
  String zone = "";

  setId(String id){
    this.id = id;
  }

  Map<String, dynamic> toMap() {
      Map<String, dynamic> userMap = {"id": id, "city": city, "zone": zone};
      Map<String, dynamic> pet_1_map = pet_1.toMap();
      Map<String, dynamic> pet_2_map = pet_2.toMap();

      return {...userMap, ...pet_1_map, ...pet_2_map };
    }
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

User _$UserFromJson(Map<String, dynamic> json) => User();

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.pet_1.name
    };
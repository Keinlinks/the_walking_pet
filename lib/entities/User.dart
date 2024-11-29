import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

import 'package:the_walking_pet/entities/Pet.dart';
@JsonSerializable()
class User {
  String id = "";
  Pet pet_1 = Pet().withRaceId(1);
  Pet pet_2 = Pet();
  String city = "iquique";
  bool completedForm = false;

  setId(String id){
    this.id = id;
  }

  User(){}
  static User withParams({id, pet_1, pet_2, city, zone}){
    User user = User();
    user.id = id;
    user.pet_1 = pet_1;
    user.pet_2 = pet_2;
    user.city = "iquique";
    user.completedForm = true;
    return user;
  }


  Map<String, dynamic> toMap() {
      Map<String, dynamic> pet_1_map = pet_1.toMap();
      Map<String, dynamic> pet_2_map = pet_2.toMap();

      return { "pet_1": pet_1_map, "pet_2": pet_2_map, id: id, city: city,};
    }
    
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  String toJson() => _$UserToJson(this);



String _$UserToJson(User instance) => jsonEncode(<String, dynamic>{
      'id': instance.id,
      'city': instance.city,
      'pet_1': instance.pet_1.toJson(),
      'pet_2': instance.pet_2.toJson(),
    });
}

  User _$UserFromJson(Map<String, dynamic> json) => User.withParams(
  id: json['id'],
  pet_1: Pet.fromStringJson(json['pet_1']),
  pet_2: Pet.fromStringJson(json['pet_2']),
  city: json['city'],
);
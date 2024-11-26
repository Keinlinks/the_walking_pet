import 'dart:convert';

class Pet{
  int raceId = 0;
  String name= "";
  int age = 0;
  int month =0;
  int day = 0;
  int dangerousness = 0;
  bool gender = false;
  String _description = "";

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  Pet withRaceId(int raceId){
    this.raceId = raceId;
    return this;
  }

  

  Map<String, dynamic> toMap() {
    return {
      'raceId': raceId,
      'name': name,
      'age': age,
      'month': month,
      'day': day,
      'dangerousness': dangerousness,
      'gender': gender,
      'description': description,
    };
  }

  static Pet fromStringJson(Map<String, dynamic> json){
    Pet pet = Pet();
    pet.description = json['description'];
    pet.dangerousness = json['dangerousness'];
    pet.day = json['day'];
    pet.gender = json['gender'];
    pet.name = json['name'];
    pet.age = json['age'];
    pet.month = json['month'];
    pet.raceId = json['raceId'];
    
    return pet;
  }

  String toJson() {
    return jsonEncode(toMap());
  }

}
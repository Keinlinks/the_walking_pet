import 'dart:convert';

class Pet{
  int raceId = 0;
  String name= "";
  int age = 0;
  int month =0;
  int day = 0;
  int dangerousness = 0;
  bool gender = false;
  String description = "";

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

  String toJson() {
    return jsonEncode(toMap());
  }

}
import 'package:the_walking_pet/models/race.dart';

class User {
  Race race = Race(name: "", description: "", image: "");
  int age = 0;
  int month = 0;
  int day = 0;
  String gender = "";

  User({
    required this.race,
    required this.age,
    required this.month,
    required this.day,
    required this.gender,
  });
}
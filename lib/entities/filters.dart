import 'package:the_walking_pet/entities/Race.dart';
import 'package:the_walking_pet/shared/constants.dart';

class Filters {

  final Map<String, String> dangerousness = {
    "No filtro": "No filtro",
    "0-4": "No peligroso",
    "5-7": "Peligroso",
    "8-10": "Muy peligroso",
  };
  String selectedDangerousness = "No filtro";


  final List<String> gender = [
    "No filtro",
    "macho",
    "hembra",
  ];

  String selectedGender = "No filtro";

  final List<Race> races = Constants.raceList;

  String selectedRace = "Labrador Retriever";

  final List<String> age = ["No filtro","0-2","3-5","6-8","9-11","12-14","14+" ];

  String selectedAge = "No filtro";

  Filters();

  Map<String, String> getDangerousness(){
    return dangerousness;
  }

  List<String> getGender(){
    return gender;
  }

  List<Race> getRaces(){
    return races;
  }

  List<String> getAge(){
    return age;
  }


}
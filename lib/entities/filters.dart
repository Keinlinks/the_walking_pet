import 'package:the_walking_pet/entities/Race.dart';
import 'package:the_walking_pet/shared/constants.dart';

class Filters {

  final List<String> dangerousness = ["No filtro", "Amigable", "No amigable", "Extremadamente peligroso"];
  
  String selectedDangerousness = "No filtro";


  final List<String> gender = [
    "No filtro",
    "Macho",
    "Hembra",
  ];

  String selectedGender = "No filtro";

  final List<Race> races = Constants.raceList;

  String selectedRace = "";

  final List<String> age = ["No filtro","0-2","3-5","6-8","9-11","12-14","14+" ];

  String selectedAge = "No filtro";

  Filters();

  List<String> getDangerousness(){
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

  Filters copy(){
    Filters copy = Filters();
    copy.selectedDangerousness = selectedDangerousness;
    copy.selectedGender = selectedGender;
    copy.selectedRace = selectedRace;
    copy.selectedAge = selectedAge;
    return copy;
  }
}
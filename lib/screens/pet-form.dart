import 'package:flutter/material.dart';
import 'package:the_walking_pet/models/User.dart';
import 'package:the_walking_pet/screens/main-map.dart';

class PetForm extends StatefulWidget {
  const PetForm({super.key});

  @override
  State<PetForm> createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  String _genderController = "hembra";

  void _submitForm(context){
    User userData = User(
      race: "humano",
      age: int.parse(_ageController.text),
      month: 0,
      day: 0,
      gender: _genderController,
    );
    print(userData.gender);
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainMap(userData: userData)));
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            width: 150,
            height: 150,
            decoration: const BoxDecoration(shape: BoxShape.circle,
              color: Colors.grey
            ),
          ),
        ),
        Form(
            key: _formKey,
            child: Column(
            children: [
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: "Edad",
                ),
                onChanged: (value){
                  print(value);
                },
              ),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Sexo",
                ),
                onChanged: (value){
                  _genderController = value!;
                },
                value: "hembra",
                items: const <DropdownMenuItem>[
                  DropdownMenuItem(
                    child: Text("Hembra"),
                    value: "hembra",
                  ),
                  DropdownMenuItem(
                    child: Text("Macho"),
                    value: "macho",
                  ),
                  ]
              ),
              ElevatedButton(onPressed: (){_submitForm(context);},child: const Text("Submit"))
              ]
        )),
      ]
    );
  }
}
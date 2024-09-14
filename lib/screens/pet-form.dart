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
    return SafeArea(
      child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: Container(
          width: 394,
          height: 200,
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional(0, -0.5),
                child: Container(
                  width: 150,
                  height: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1503256207526-0d5d80fa2f47?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwzfHxkb2d8ZW58MHx8fHwxNzI1OTEwMjM2fDA&ixlib=rb-4.0.3&q=80&w=1080',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
        ),
        Divider(
          thickness: 2,
          color: Color.fromARGB(20, 0, 0, 0),
        ),
        Align(
          alignment: AlignmentDirectional(0.83, -0.13),
          child: TextFormField(
            maxLength: 250,
            maxLines: null,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              labelText: "Descripcion",
              hintText: "Escribe una descripcion",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(20, 0, 0, 0),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(child: 
        Align(alignment: AlignmentDirectional(0, 1),

        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          ElevatedButton(onPressed: (){}, child: Text("Cancelar")),
          ElevatedButton(onPressed: (){}, child: Text("Guardar")),
        ]),
        )
        )
      ]
    ));
  }
}
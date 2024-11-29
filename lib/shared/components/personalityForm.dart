
import 'package:flutter/material.dart';
import 'package:the_walking_pet/shared/constants.dart';

class PersonalityForm extends StatefulWidget {
  final List<dynamic> personality;
  final Function(List<dynamic>) onSubmit;

  const PersonalityForm({super.key, required this.personality, required this.onSubmit});

  @override
  State<PersonalityForm> createState() => _PersonalityFormState();
}

class _PersonalityFormState extends State<PersonalityForm> {
  int opacity = 130;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

      Wrap(
        spacing: 10,
        direction: Axis.horizontal,
        runAlignment: WrapAlignment.spaceEvenly,

        children: [
        for (var personality in Constants.personalityList.entries)
          ActionChip(
            backgroundColor: personality.value ? Color.fromARGB(widget.personality.contains(personality.key) ? 255:opacity, 12, 140, 13) : Color.fromARGB(widget.personality.contains(personality.key) ? 255:opacity, 150, 13, 13),
            label: Text(personality.key, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
            onPressed: (){
              setState(() {
                if(widget.personality.contains(personality.key)){
                  widget.personality.remove(personality.key);
                }
                else {
                  widget.personality.add(personality.key);
                }
              });
            },
            )
      ],),
      ElevatedButton(child: const Text("Guardar"),onPressed: (){
        widget.onSubmit(widget.personality);
        
      },)
    ],);
  }
}
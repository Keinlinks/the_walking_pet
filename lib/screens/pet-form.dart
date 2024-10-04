import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_walking_pet/models/User.dart';
import 'package:the_walking_pet/models/race.dart';
import 'package:the_walking_pet/screens/main-map.dart';

class PetForm extends StatefulWidget {
  const PetForm({super.key});

  @override
  State<PetForm> createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  TextEditingController _controller = TextEditingController();

  List<User> petList = [User (race: Race(description: "", image: "", name: ""), age: 0, month: 0, day: 0, gender: "hembra"),
    User (race: Race(description: "", image: "", name: ""), age: 0, month: 0, day: 0, gender: "hembra"),
   ];

  int petSelectedIndex = 0;

  final min_lines_description = 8;
  final max_length_description = 250;


  void _submitForm(context){
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainMap(userData: petList[petSelectedIndex])));
  }

  void _openDescriptionDialog() {
    TextEditingController _dialogController = TextEditingController();
    _dialogController.text = _controller.text;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ingresar descripcion'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Descripción',
              alignLabelWithHint: true
            ),
            minLines: min_lines_description,
            maxLines: null,
            maxLength: max_length_description,
            controller: _dialogController,
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                setState(() {
                  _controller.text = _dialogController.text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  void openAgeDialog(String label, int value){
    TextEditingController dialogController = TextEditingController();
    dialogController.text = value.toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ingresar $label'),
          content: TextField(
            inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              alignLabelWithHint: true
            ),
            controller: dialogController,
            readOnly: false,
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                setState(() {
                  if (label == "Años"){
                    petList[petSelectedIndex].age = int.parse(dialogController.text);
                  }
                  if (label == "Meses"){
                    petList[petSelectedIndex].month = int.parse(dialogController.text);
                  }
                  if (label == "Dias"){
                    petList[petSelectedIndex].day = int.parse(dialogController.text);
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  // void openRaceDialog(String label, int value){
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Seleccionar raza de la mascota'),
  //         content: GridView.builder(gridDelegate: gridDelegate, itemBuilder: itemBuilder),
  //         actions: [
  //           TextButton(
  //             child: const Text('Cancelar'),
  //             onPressed: () => Navigator.pop(context),
  //           ),
  //           TextButton(
  //             child: const Text('Guardar'),
  //             onPressed: () {
  //               setState(() {
                  
  //               });
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
      const SizedBox(height: 10,),
      Flexible(
        flex: 4,
        child: SizedBox(
          width: 394,
          child: Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed:(){
                        openAgeDialog("Años", petList[petSelectedIndex].age);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, 
                        shadowColor: Colors.transparent,
                      ), child: CounterButton(label:"Años",value: petList[petSelectedIndex].age,index: 1,),),
                      ElevatedButton(onPressed: (){
                        openAgeDialog("Meses", petList[petSelectedIndex].month);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, 
                        shadowColor: Colors.transparent,
                      ), child: CounterButton(label:"Meses", value:petList[petSelectedIndex].month,index: 2,),),
                      ElevatedButton(onPressed: (){
                        openAgeDialog("Dias", petList[petSelectedIndex].day);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, 
                        shadowColor: Colors.transparent,
                      ), child: CounterButton(label:"Dias", value:petList[petSelectedIndex].day),)
                    ]
                  ),
                )
              ),
              Column(
                children: [
                ElevatedButton(onPressed: () {
                  
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, 
                  shadowColor: Colors.transparent,
                ),
                child: 
                const PetImage(),
                ),
                const SizedBox(height: 10,),
                Text(petList[petSelectedIndex].race.name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  ElevatedButton.icon(
                    onPressed: (){
                      setState(() {
                          petList[petSelectedIndex].gender = "macho";
                      });
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: petList[petSelectedIndex].gender == "macho" ? Colors.blue : Colors.blue.withOpacity(0.2),
                    shadowColor: Colors.transparent,
                  ),
                  label: const Text("Macho"),
                  icon: const Icon(Icons.male),
                  ),
                  const SizedBox(width: 10,),
                  ElevatedButton.icon(
                    label: const Text("hembra"),
                    icon: const Icon(Icons.female),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: petList[petSelectedIndex].gender == "hembra" ? Colors.pinkAccent : Colors.pinkAccent.withOpacity(0.2),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: (){
                      setState(() {
                        petList[petSelectedIndex].gender = "hembra";
                      });
                    }),
                ],)
                ]
              ),
              Flexible(child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                
                children: [
                  const SizedBox(height: 10,),
                  ElevatedButton(onPressed: (){
                    setState(() {
                      petSelectedIndex = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, 
                    shadowColor: Colors.transparent,
                  ),
                  child: PetSelector(isSelected: (petSelectedIndex == 0), image: petList[petSelectedIndex].race.image,)),
                  const SizedBox(height: 15,),
                  ElevatedButton(onPressed: (){
                    setState(() {
                      petSelectedIndex = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, 
                    shadowColor: Colors.transparent,
                  ),
                  child:  PetSelector(isSelected:(petSelectedIndex == 1), image: petList[petSelectedIndex].race.image,)),
                ],
              )),
            ],
          ),
        ),
      ),
      const Divider(
        thickness: 2,
        color: Color.fromARGB(20, 0, 0, 0),
      ),
      Expanded(
        flex: 7,
        child: TextFormField(
          controller: _controller,
          maxLength: max_length_description,
          readOnly: true,
          minLines: min_lines_description,
          onTap: _openDescriptionDialog,
          maxLines: null,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            labelText: "Descripción",
            hintText: "Escribe una descripcion",
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromARGB(20, 0, 0, 0),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      Flexible(
          child: Align(
        alignment: const AlignmentDirectional(0, 1),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text("Siguiente")),
              const SizedBox(height: 10,),
              
            ]),
      ))
    ]));
  }
}

class PetImage extends StatelessWidget {
  const PetImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.network(
        'https://images.unsplash.com/photo-1503256207526-0d5d80fa2f47?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwzfHxkb2d8ZW58MHx8fHwxNzI1OTEwMjM2fDA&ixlib=rb-4.0.3&q=80&w=1080',
        fit: BoxFit.cover,
      ),
    );
  }
}

class PetSelector extends StatelessWidget {
  final bool isSelected;
  final String image;
  const PetSelector({
    super.key,
    this.isSelected = false,
    this.image = "",
  });

  final double selectedSize = 70.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.blue,
          width: 3,
          style: BorderStyle.solid
        ),
      ),
      child: image == "" ? const Icon(
      Icons.add,
      color: Colors.blue,
      size: 24.0,
      shadows: [Shadow(color: Colors.blue, blurRadius: 10.0)],
    ) : Image.network(image,
        fit: BoxFit.cover,
        opacity: const AlwaysStoppedAnimation(.3),
      ),
    );
  }
}

class CounterButton extends StatelessWidget {

  final String label;
  final int value;
  final int index;
  CounterButton({
    super.key,required this.label, required this.value, this.index = 0
  });

  final colorList = [Colors.blue, Colors.red, Colors.green];

  @override
  Widget build(BuildContext context) {
    return Align(
  alignment: const AlignmentDirectional(-0.82, -0.86),
  child: Column(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      ),
      SizedBox(height: 5,),
      Container(
        height: 30,
        width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorList[index],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(value.toString()),
      ),
    ],
  ),
);
    
}
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:the_walking_pet/entities/Pet.dart';
import 'package:the_walking_pet/entities/User.dart';
import 'package:the_walking_pet/entities/Race.dart';
import 'package:the_walking_pet/screens/main-map.dart';
import 'package:the_walking_pet/shared/constants.dart';
class PetForm extends StatefulWidget {
  const PetForm({super.key});

  @override
  State<PetForm> createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  late List<Race> raceList;

  User user = User();

  int petSelectedIndex = 0;

  final min_lines_description = 8;
  final max_length_description = 250;

  @override
  void initState() {
    super.initState();
    raceList = Constants.raceList;
  }
  void _submitForm(context) async {
    LocationPermission permission = await Geolocator.checkPermission();
     if (permission == LocationPermission.denied){
       permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.deniedForever) {
          return;
       }
       if (permission == LocationPermission.denied){
          return;
       }
     }
    Navigator.push(context, MaterialPageRoute(builder: (context) => MainMap(userPets: user)));
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
void _openChangeNameDialog(Pet actualPet) {
    TextEditingController _dialogController = TextEditingController();
    _dialogController.text = _nameController.text;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ingresar Nombre'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Nombre',
              alignLabelWithHint: true
            ),
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
                  _nameController.text = _dialogController.text;
                  actualPet.name = _dialogController.text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  void _openAgeDialog(String label, int value,Pet actualPet){
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
                    actualPet.age = int.parse(dialogController.text);
                  }
                  if (label == "Meses"){
                    actualPet.month = int.parse(dialogController.text);
                  }
                  if (label == "Dias"){
                    actualPet.day = int.parse(dialogController.text);
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
  void _openRaceDialog(int raceId,Pet actualPet) {
  Race currectRace = raceList.firstWhere((element) => element.id == raceId, orElse:() => raceList.firstWhere((element) => element.id == 0));
  Race dialogRace = currectRace;
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter builder) {
          return AlertDialog(
          title: const Text('Seleccionar raza de la mascota'),
          content: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 4, // Espaciado entre columnas
                mainAxisSpacing: 4, // Espaciado entre filas
                childAspectRatio: 0.7, // Relación de aspecto del grid
              ),
              itemCount: raceList.length - 1,
              itemBuilder: (context, index) {
                index = index + 1;
                final Race race = raceList[index];
                return GestureDetector(
                  onTap: () {
                    builder(() {
                      dialogRace = race;
      
                    });
                  },
                  onLongPress: () {
                    _showRaceDescription(race);
                  },
                  
                  child: Container(
                    decoration: BoxDecoration(border: race.name == dialogRace.name ? Border.all(color: Colors.blue.withOpacity(0.7)) : Border.all(color: Colors.transparent),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            
                          ),
                          child: Image(
                            image: AssetImage(race.image),
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Text(
                          race.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
                  actualPet.raceId = dialogRace.id;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );}
      );
    },
  );
}

  void _showPetDescription(Pet pet){
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(pet.name),
        content: Text(pet.description == "" ? "No hay descripción" : pet.description),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
  void _showRaceDescription(Race race){
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(race.name),
        content: Text(race.description == "" ? "No hay descripción" : race.description),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    Pet actualPet;
    if (petSelectedIndex == 0){
      actualPet = user.pet_1;
      
    }
    else {
      actualPet = user.pet_2;
    }
    List<Race>raceList = Constants.raceList;
    _nameController.text = actualPet.name;
    _controller.text = actualPet.description;
    Race firstRace = raceList.firstWhere((element) => element.id == user.pet_1.raceId, orElse:() => raceList.firstWhere((element) => element.id == 1));
    Race secondRace = raceList.firstWhere((element) => element.id == user.pet_2.raceId, orElse:() => raceList.firstWhere((element) => element.id == 0));
    Race actualRace = raceList.firstWhere((element) => element.id == actualPet.raceId, orElse:() => raceList.firstWhere((element) => element.id == 0));
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
                        _openAgeDialog("Años", actualPet.age,actualPet);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, 
                        shadowColor: Colors.transparent,
                      ), child: CounterButton(label:"Años",value: actualPet.age,index: 1,),),
                      ElevatedButton(onPressed: (){
                        _openAgeDialog("Meses", actualPet.month,actualPet);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, 
                        shadowColor: Colors.transparent,
                      ), child: CounterButton(label:"Meses", value:actualPet.month,index: 2,),),
                      ElevatedButton(onPressed: (){
                        _openAgeDialog("Dias", actualPet.day,actualPet);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, 
                        shadowColor: Colors.transparent,
                      ), child: CounterButton(label:"Dias", value:actualPet.day),)
                    ]
                  ),
                )
              ),
              Column(
                children: [
                GestureDetector(
                  onTap: () {
                  _openRaceDialog(actualPet.raceId,actualPet);
                }, 
                onLongPress: (){
                  if (actualPet.raceId == 0) return; 
                  _showPetDescription(actualPet);
                },
                child: 
                PetImage(raceId: actualPet.raceId),
                ),
                const SizedBox(height: 10,),
                Text(actualRace.name == "" ? "Selecciona una raza" : actualRace.name, 
                style: const TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  ElevatedButton.icon(
                    onPressed: (){
                      setState(() {
                          actualPet.gender = true;
                      });
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actualPet.gender ? Colors.blue : Colors.blue.withOpacity(0.2),
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
                      backgroundColor: !actualPet.gender ? Colors.pinkAccent : Colors.pinkAccent.withOpacity(0.2),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: (){
                      setState(() {
                        actualPet.gender = false;
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
                  child: PetSelector(isSelected: (petSelectedIndex == 0), image: firstRace.image,)),
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
                  child:  PetSelector(isSelected:(petSelectedIndex == 1), image: secondRace.image,)),
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
        flex: 5,
        child: Column(
          children: [
            const SizedBox(height: 10,),
            TextField(
              decoration: const InputDecoration(
                labelText: "Nombre",
                alignLabelWithHint: true,
                isDense: true,
                
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(20, 0, 0, 0),
                    width: 2,
                    style: BorderStyle.solid,
                    
                  ),
                ),
    
              ),
              controller: _nameController,
              readOnly: true,
              onTap: () => _openChangeNameDialog(actualPet),
              
            ),
            const SizedBox(height: 10,),
            TextFormField(
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
                alignLabelWithHint: true,
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
          ],
        ),
      ),
      Flexible(
        flex: 2,
        child: Column(
          children: [
            
            const Text("Peligrosidad"),
            const SizedBox(height: 10,),
            DropdownButton(
              value: actualPet.dangerousness.toString(),
              style: const TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.bold,),
              
              items: const [DropdownMenuItem<String>(child: Text("0",),value: "0",),DropdownMenuItem<String>(child: Text("1",),value: "1",), DropdownMenuItem<String>(child: Text("2",),value: "2",), DropdownMenuItem<String>(child: Text("3",),value: "3",), DropdownMenuItem<String>(child: Text("4",),value: "4",), DropdownMenuItem<String>(child: Text("5",),value: "5",), DropdownMenuItem<String>(child: Text("6",),value: "6",), DropdownMenuItem<String>(child: Text("7",),value: "7",), DropdownMenuItem<String>(child: Text("8",),value: "8",), DropdownMenuItem<String>(child: Text("9",),value: "9",), DropdownMenuItem<String>(child: Text("10",),value: "10",),],
              onChanged: (value) {
                setState(() {
                  int dangerousness = int.parse(value!);
                  actualPet.dangerousness = dangerousness;
                });
              },
              
            ),
          ],
        ),
      ),
      Flexible(
          child: Align(
        alignment: const AlignmentDirectional(0, 1),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _submitForm(context);
                }, 
                style: ElevatedButton.styleFrom(minimumSize: const Size(150, 40)), 
                child: const Text("Siguiente"),),
              if (petSelectedIndex == 1) ElevatedButton(onPressed: () {
                setState(() {
                  user.pet_2 = Pet();
                  petSelectedIndex = 0;
                });
              },style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shadowColor: Colors.transparent, minimumSize: const Size(75, 40)),
              child: const Text("Borrar"),),
              
            ]),
      ))
    ]));
  }
}

class PetImage extends StatelessWidget {
  final int raceId;
  const PetImage({
    super.key,
    required this.raceId
  });

  @override
  Widget build(BuildContext context) {
    List<Race> raceList = Constants.raceList;
    Race race = raceList.firstWhere((element) => element.id == raceId, orElse:() => raceList.firstWhere((element) => element.id == 0));
    return Container(
      width: 150,
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: race.image == "" ? Border.all(color: Colors.blue.withOpacity(0.7)) : Border.all(color: Colors.transparent),
      ),
      child: race.image != "" ? Image(
        image: AssetImage(race.image),
        fit: BoxFit.cover,
      ) : const Icon(Icons.pets),
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
          color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.2),
          width: 3,
          style: BorderStyle.solid
        ),
      ),
      child: image == "" ? Icon(
      Icons.add,
      color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.2),
      size: isSelected ? 30.0 : 24.0,
      
    ) : Image(image: AssetImage(image),
        fit: BoxFit.cover,
        opacity: !isSelected ? const AlwaysStoppedAnimation(.3) : null,
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
      const SizedBox(height: 5,),
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
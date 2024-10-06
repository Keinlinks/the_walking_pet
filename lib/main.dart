import 'package:flutter/material.dart';
import 'package:the_walking_pet/screens/pet-form.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        
        resizeToAvoidBottomInset: false, 
        appBar: AppBar(title: const Text("The Walking Pet")),
        body: 
              const PetForm()
      ),
    );
  }
}

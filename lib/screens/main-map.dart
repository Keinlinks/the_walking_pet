import 'package:flutter/material.dart';
import 'package:the_walking_pet/models/User.dart';

class MainMap extends StatefulWidget {
  final User userData;
  const MainMap({Key? key, required this.userData}) : super(key: key);

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Text("Hello ${widget.userData.age}"),
    );
  }
}
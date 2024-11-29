import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_walking_pet/screens/main-map.dart';

class SettingsWidget extends StatefulWidget {
  final GlobalState globalState;
  const SettingsWidget({super.key, required this.globalState});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _controller.text = widget.globalState.adviceDistanceInMeter.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Ajustes"),
        const SizedBox(height: 10,),
        TextField(
            inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Distancia máxima de peligrosidad",
              alignLabelWithHint: true
            ),
            onChanged: (value) => widget.globalState.adviceDistanceInMeter = int.parse(value),
            controller: _controller,
            readOnly: false,
          ),
          const SizedBox(height: 20,),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [const Text("Vibrar"),Checkbox(value: widget.globalState.vibrator, onChanged: (value) => widget.globalState.vibrator = value!,)],)
          ,
    ],);
  }
}
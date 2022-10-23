import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

// class Notification extends StatelessWidget {
//   const Notification({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

class NotificationScreen extends StatefulWidget {
    const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool status = false;
  bool _lights = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: Text("알림 설정"),
      ),
      body: SwitchListTile(
        title: const Text('알림 허용'),
        value: _lights,
        onChanged: (bool value) {
          setState(() {
            _lights = value;
          });
        },
        secondary: const Icon(Icons.notifications_active_outlined),
      ),

    );
  }
}
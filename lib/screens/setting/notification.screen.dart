import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/user.service.dart';
import '../../widgets/app_appbar_common.widget.dart';

class NotificationScreen extends StatefulWidget {
    const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  bool _lights = false;

  @override
  void initState() {
    // TODO: implement initState
    FirebaseService.getUserPrivacyProfile(userEmail!).then((value) {
      // print("value[0]['alramlocalPermission'] : ${value[0]['alramlocalPermission']}");
      setState(() {
        _lights = value[0]['alramlocalPermission'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: fnCommnAppbarWidget(title: '알림설정',appBar: AppBar()),
      // body: SwitchListTile(
      //   title: const Text('알림 허용'),
      //   value: _lights,
      //   onChanged: (bool value) {
      //     FirebaseService.savePrivacyProfile(userEmail!,[value],'alramlocalPermission');
      //     setState(() {
      //       _lights = value;
      //     });
      //   },
      //   secondary: const Icon(Icons.notifications_active_outlined),
      // ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("앱 푸시 메시지 설정", style: TextStyle(fontSize: 16),),
                  TextButton(
                      onPressed: (){
                        openAppSettings();
                      },
                      child: Text("알림 변경", style: TextStyle(fontWeight: FontWeight.bold),)
                  ),
                ],
              ),
        ),
        )
    );
  }
}
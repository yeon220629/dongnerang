import 'package:dongnerang/screens/mainScreenBar.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/common.constants.dart';

class mypageLocalSetting extends StatefulWidget {
  const mypageLocalSetting({Key? key}) : super(key: key);

  @override
  State<mypageLocalSetting> createState() => _mypageLocalSettingState();
}

class _mypageLocalSettingState extends State<mypageLocalSetting> {
  var selected_tags = [];
  var select_tags = [];
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  List currentLocal = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // currentLocal.add(FirebaseService.getUserLocalData(userEmail!));
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value){
      value.forEach((element) {
        setState(() {
          currentLocal.add(element);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: fnCommnAppbar(
            appBar: AppBar(),title: "지역 설정",
            center: false, ListData:selected_tags,
            email: userEmail!, keyName: 'local'
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("현재 나의 지역", style: TextStyle(fontWeight: FontWeight.bold, ),),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap( spacing: 8.0, runSpacing: 4.0, children: <Widget>[...generate_tags(currentLocal)], ),
            ),
            SizedBox(height: 20,),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("전체 지역", style: TextStyle(fontWeight: FontWeight.bold, ),),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap( spacing: 8.0, runSpacing: 4.0, children: <Widget>[...generate_tags(CustomData)], ),
            ),
          ],
        )
    );
  }

  generate_tags(value) {
    return value.map((tag) => get_chip(tag)).toList();
  }
  get_chip(name) {
    if(currentLocal.contains(name)){
      CustomData.remove(name);
    }
    return FilterChip(
      selected: selected_tags.contains(name),
      selectedColor: Colors.blue.shade800,
      disabledColor: Colors.blue.shade400,
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      label: Text("${name}"), onSelected: (value) {
        select_tags.add(name);
        if(select_tags.length > 3){
          return;
        }
        setState(() {
          selected_tags = select_tags;
        });
      },
    );
  }
}

import 'package:dongnerang/constants/colors.constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/common.constants.dart';
import '../../services/firebase.service.dart';

class mypageKeywordSetting extends StatefulWidget {
  const mypageKeywordSetting({Key? key}) : super(key: key);

  @override
  State<mypageKeywordSetting> createState() => _mypageKeywordSettingState();
}

class _mypageKeywordSettingState extends State<mypageKeywordSetting> {
  var selected_tags = [];
  var select_tags = [];
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  List currentKeyword = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // currentLocal.add(FirebaseService.getUserLocalData(userEmail!));
    FirebaseService.getUserLocalData(userEmail!, 'keyword').then((value){
      value.forEach((element) {
        setState(() {
          currentKeyword.add(element);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: fnCommnAppbar(appBar: AppBar(), title: '관심 키워드 수정', center: false, email: userEmail!, ListData: selected_tags, keyName: 'keyword'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: AppColors.black)),
              margin: EdgeInsets.all(30),
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '  원하는 키워드를 검색해 보세요!',
                    suffixIcon : IconButton(icon: Icon(Icons.search), onPressed: (){},)
                ),
                // controller: SearcheditingController,
                onChanged: (value){
                  print("value");
                },
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("나의 키워드", style: TextStyle(fontWeight: FontWeight.bold, ),),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap( spacing: 8.0, runSpacing: 4.0, children: <Widget>[...generate_tags(currentKeyword)], ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("인기 키워드", style: TextStyle(fontWeight: FontWeight.bold, ),),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap( spacing: 8.0, runSpacing: 4.0, children: <Widget>[...generate_tags(mostPopularKeyword)], ),
            ),
          ],
        )
    );
  }

  generate_tags(value) {
    return value.map((tag) => get_chip(tag)).toList();
  }
  get_chip(name) {
    if(currentKeyword.contains(name)){
      CustomData.remove(name);
    }
    return FilterChip(
    selected: selected_tags.contains(name),
    selectedColor: Colors.blue.shade800,
    disabledColor: Colors.blue.shade400,
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    label: Text("${name}"), onSelected: (value) {
      if(value == true){
        select_tags.add(name);
      }
      if(value == false){
        select_tags.remove(name);
      }

      setState(() {
        selected_tags = select_tags;
      });
    },);
  }
}

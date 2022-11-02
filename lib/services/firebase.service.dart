import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/app_user.model.dart';
import 'package:http/http.dart' as http;

import '../screens/mainScreenBar.dart';

class FirebaseService {
  final String url ='https://us-central1-dbcurd-67641.cloudfunctions.net/createCustomToken';

  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final customTokenResponse = await http.post(Uri.parse(url), body: user);
    return customTokenResponse.body;
  }


  static Future<AppUser?> findUserByEmail(String email) async {
    final doc =
    await FirebaseFirestore.instance.collection("users").doc(email).get();
    if (!doc.exists) {
      return null;
    }
    final currentUser = AppUser.fromMap(doc.data() as Map<String, dynamic>);
    UserService.to.currentUser.value = currentUser;
    return currentUser;
  }


  static Future<AppUser?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return findUserByEmail(user.email!);
  }

  static Future<List> getUserLocalData(String email, String param) async {
    List getDt = [];
    final doc = await FirebaseFirestore.instance.collection("users").doc(email).get();
    doc.data()?.forEach((key, value) {
      if(key == param){
        for(int i = 0; i < value.toString().split(",").length; i++){
          getDt.add(value[i]);
        }
      }
    });
    return getDt;
  }

  static Future<bool> getUserSaveToggleData(String email, String title) async {
    bool toggleValue = false;

    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
    checkDuplicate.data()?.forEach((key, value) {
      if(key.contains("userSaveData")){
        if(value[3] == title){
          // print("key number : $key");
          // print("value Data : ${value[4]}");
          toggleValue = value[4];
        }
      }
    });
    print("toggleValue : $toggleValue");
    return toggleValue;
  }
  
  //중복 데이터 제거 필요
  static Future<void> saveUserPrivacyData(String email, List param)async {
    List keyTemp = [];
    List valueTemp = [];
    List lastNumber = [];
    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();

    checkDuplicate.data()?.forEach((key, value) {
      if(key.contains("userSaveData")){
        keyTemp.add(key);
        valueTemp.add(value);
      }
    });

    if(keyTemp.isEmpty){
      // print("항목이 비었음..");
      await FirebaseFirestore.instance.collection("users").doc(email).update(({
        'userSaveData0': param,
      }));
    }

    for(var keyCompare in keyTemp){
      int compareNumber = int.parse(keyCompare.replaceRange(0, 12, ''));
      if('userSaveData${compareNumber}'.contains(compareNumber.toString())){
        compareNumber ++;
      }
      lastNumber.add(compareNumber);
    }
    lastNumber.sort();
    // lastNumber.reversed;

    for(var valueCompare in valueTemp){
      if(valueCompare[3] == param[3]){
        break;
      }

      if(valueCompare[3] != param[3]){
        await FirebaseFirestore.instance.collection("users").doc(email).update(({
          'userSaveData${lastNumber.reversed.first}': param,
        }));
        // EasyLoading.showSuccess("저장 완료");
      }

    }
  }
  static Future<void> deleteUserPrivacyData(String email, String title) async {
    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
    checkDuplicate.data()?.forEach((key, value) async {
      if(key.contains("userSaveData")){
        if(value[3] == title){
          // print("key number : $key");
          var data = <String, dynamic>{
            key: FieldValue.delete(),
          };
          checkDuplicate.reference.update(data);
          // print(data);
        }
      }
    });
  }

  static Future<void> deleteMypageUserPrivacyData(String email, String title, BuildContext context) async {
    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
    checkDuplicate.data()?.forEach((key, value) async {
      if(key.contains("userSaveData")){
        if(value[3] == title){
          // print("key number : $key");
          var data = <String, dynamic>{
            key: FieldValue.delete(),
          };
          checkDuplicate.reference.update(data);
          // print(data);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (BuildContext context) =>
                  mainScreen()), (route) => false);
        }
      }
    });
  }

  static Future<List> getUserPrivacyProfile(String email) async {
    List getUserData = [];
    List getUserSaveData = [];
    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
    checkDuplicate.data()?.forEach((key, value) async {
      if(key.contains("name")){
        // print("name value : $value");
        getUserData.add(value);
      }
      if(key.contains("profileImage")){
        // print("profileImage value : $value");
        getUserData.add(value);
      }
      if(key.contains("userSaveData")){
        // print("userSaveData value : $value");
        getUserSaveData.add(value);
      }
    });
    // print("getUserData : $getUserData");
    return [getUserData, getUserSaveData];
  }

  static Future<void> savePrivacyProfile(String email, List value, String key) async{
    // print("email : $email");
    // print("value : $value");
    // final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
      if(key.contains("keyword")){
        await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
          key: value,
        }));
      }
      if(key.contains("local")){
        await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
          key: value,
        }));
      }
  }

  static Future<void> savePrivacyProfileSetting(String email, List value, List key) async{
    print("value : ${value}");
    for(int i = 0; i < key.length; i++){
      print("key : ${key[i]}");
      if(key[i] == 'name'){
          await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
            key[i]: value[0],
          }));
      }
    }
    // if(key.contains("name")){
    //   print(value);
    //   await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
    //     key: value,
    //   }));
    // }
  }
}
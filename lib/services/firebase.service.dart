import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../models/app_user.model.dart';
import 'package:http/http.dart' as http;

import '../screens/mainScreenBar.dart';
import '../screens/mypage/mypage.screen.dart';

class FirebaseService {
  final String url ='https://us-central1-dbcurd-67641.cloudfunctions.net/createCustomToken';

  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final customTokenResponse = await http.post(Uri.parse(url), body: user);
    return customTokenResponse.body;
  }

  static Future<bool> findUserlocal(String? email) async {
    bool localCheck = false;
    final doc = await FirebaseFirestore.instance.collection("users").doc(email).get();
    doc.data()?.forEach((key, value) {
      if(key == 'local'){
        print("local true");
        localCheck = true;
      }
    });
    return localCheck;
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

  static Future<void> deleteUser(String? email, provider) async {
    final checkUser =  await FirebaseFirestore.instance.collection("users").doc(email);
    if(provider == 'kakao'){
      // await UserApi.instance.logout();
      await UserApi.instance.unlink();
    }
    print("1 delete");
    checkUser.delete();
    print("2 delete");
    await FirebaseAuth.instance.signOut();
    try {
      print("3 delete");
      await FirebaseAuth.instance.currentUser?.delete();
      print("4 delete");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('The user must reauthenticate before this operation can be executed.');
      }
    }
  }

  static Future<void> deleteUserPrivacyData(String email, String title) async {
    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
    if(title == 'recentSearch'){
      checkDuplicate.data()?.forEach((key, value) async {
        if(key == "recentSearch"){
          var data = <String, dynamic>{
            key: FieldValue.delete(),
          };
          checkDuplicate.reference.update(data);
        }
      });
    }
    checkDuplicate.data()?.forEach((key, value) async {
      if(key.contains("userSaveData")){
        if(value[3] == title){
          var data = <String, dynamic>{
            key: FieldValue.delete(),
          };
          checkDuplicate.reference.update(data);
        }
      }
    });
  }

  static Future<void> deleteMypageUserPrivacyData(String email, String title, getPostsData) async {
    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
    checkDuplicate.data()?.forEach((key, value) async {
      if(key.contains("userSaveData")){
        if(value[3] == title){
          // print("key number : $key");
          var data = <String, dynamic>{
            key: FieldValue.delete(),
          };
          checkDuplicate.reference.update(data);
        }
      }
    });
    getUserPrivacyProfile(email).then((value) {
      getPostsData(value[2],value[3]);
    });
  }

  static Future<List> getUserPrivacyProfile(String email) async {
    List getUserData = [];
    List getUserSaveData = [];
    List getUserSaveKeyData = [];
    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
    checkDuplicate.data()?.forEach((key, value) async {
      if(key.contains("name")){
        getUserData.add(value);
      }
      if(key.contains("profileImage")){
        getUserData.add(value);
      }
      if(key.contains("userSaveData")){
        getUserSaveData.add(value);
        getUserSaveKeyData.add(key);
      }
    });
    return [getUserData, getUserSaveData, checkDuplicate.data(), getUserSaveKeyData];
  }

  static Future<void> savePrivacyProfile(String email, List value, String key) async{
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
    if(key.contains("recentSearch")){
      await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
        key: value,
      }));
    }
  }

  static Future<void> savePrivacyProfileSetting(String email, List value, List key) async{
    for(int i = 0; i < key.length; i++){
      if(key[i] == 'name'){
          await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
            key[i]: value[0],
          }));
      }
    }
  }

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String strToday = formatter.format(now);
    return strToday;
  }

  static Future<List> findBanner() async {
    List sendBannerdata = [];
    final doc = await FirebaseFirestore.instance.collection("banner").doc('banner1').get();
    doc.data()?.forEach((key, value) {
      sendBannerdata.add(value);
    });
    return sendBannerdata;
  }

  static Future<String> findVersion() async {
    String versionCode= '';
    final doc = await FirebaseFirestore.instance.collection("banner").doc('version').get();
    doc.data()?.forEach((key, value) {
      versionCode = value;
    });

    return versionCode;
  }


}
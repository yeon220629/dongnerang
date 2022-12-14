import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../models/app_user.model.dart';
import 'package:http/http.dart' as http;

import '../models/notification.model.dart';

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
  
  //?????? ????????? ?????? ??????
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
      await FirebaseFirestore.instance.collection("users").doc(email).update(({
        'userSaveData0': param,
      }));
    }

    for(var keyCompare in keyTemp){
      int compareNumber = int.parse(keyCompare.replaceRange(0, 12, ''));
      if('userSaveData${compareNumber}'.contains(compareNumber.toString())){ compareNumber ++; }
      lastNumber.add(compareNumber);
    }
    lastNumber.sort();
    // lastNumber.reversed;
    for(var valueCompare in valueTemp){
      if(valueCompare[3] == param[3]){ break; }

      if(valueCompare[3] != param[3]){
        await FirebaseFirestore.instance.collection("users").doc(email).update(({
          'userSaveData${lastNumber.reversed.first}': param,
        }));
      }
    }
  }

  static Future<void> deleteUser(String? email, provider) async {
    final checkUser =  await FirebaseFirestore.instance.collection("users").doc(email);
    if(provider == 'kakao'){
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
    var addValue = await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email);
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
    if(key.contains("userSearchWord")){
      addValue.get().then((addValueList) {
        addValueList.data()?.forEach((key, value2) {
          if(key == 'userSearchWord'){
            for(int i = 0; i < value2.length; i++){
              for(int j = 0; j < value.length; j++){
                if(value2[i] != value[j]){
                  addValue.update(
                    {'userSearchWord' : FieldValue.arrayUnion([value[j]])}
                  );
                }
              }
            }
          }
        });
      });
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

  static Future<List> findBanner() async {
    List sendBannerdata = [];
    final doc = await FirebaseFirestore.instance.collection("banner").doc('banner1').get();
    doc.data()?.forEach((key, value) {
      sendBannerdata.add(value);
    });
    return sendBannerdata;
  }
  // notification Alram
  static Future<void> saveUserNotificationData(String email,CustomNotification param)async {
    List lastNumber = [];
    var addNumber = '';
    var updateObject = {
      "title" : param.title,
      "link" : param.link,
      "center_name" : param.center_name,
    };

    // ?????? ??????..
    final checkDoc =  await FirebaseFirestore.instance.collection("keywordnotification").doc(email);
    var checking=await checkDoc.get();
    if(checking.exists){
      final checkNotiDuplicate =  await FirebaseFirestore.instance.collection("keywordnotification").doc(email).get();
      checkNotiDuplicate.data()?.forEach((key, value) async {
        // if(key.contains('notification')){
        //   addNumber = key.split('_')[1];
          // if('notification_${addNumber}'.contains(addNumber)){
          //   int compareNumber = int.parse(addNumber);
          //   compareNumber++;
          // }
          // lastNumber.add(compareNumber);

        //   print("lastNumber : $lastNumber");
        //
        //   await FirebaseFirestore.instance.collection("keywordnotification").doc(email).update(
        //       {"notification_${lastNumber.reversed.first}": updateObject}
        //   );
        // }
      });
    }else{
      await FirebaseFirestore.instance.collection("keywordnotification").doc(email).set(
          {"notification_0": updateObject}
      );
    }
  }
}
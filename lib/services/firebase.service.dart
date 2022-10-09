import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_user.model.dart';
import 'package:http/http.dart' as http;

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

  static Future<List> getUserLocalData(String email) async {
    List getDt = [];
    final doc = await FirebaseFirestore.instance.collection("users").doc(email).get();
    doc.data()?.forEach((key, value) {
      if(key == 'local'){
        for(int i = 0; i < value.toString().split(",").length; i++){
          getDt.add(value[i]);
        }
      }
    });
    return getDt;
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
      // print(keyCompare);
      int compareNumber = int.parse(keyCompare.replaceRange(0, 12, ''));
      if('userSaveData${compareNumber}'.contains(compareNumber.toString())){
        compareNumber += 1;
      }
      lastNumber.add(compareNumber);
    }

    for(var valueCompare in valueTemp){
      if(valueCompare[3] == param[3]){
        print("데이터가 있음.");
        EasyLoading.showError("이미 저장되어있는 데이터가 있습니다.");
        break;
      }else{
        // print("데이터가 없음");
        // print(lastNumber);
        await FirebaseFirestore.instance.collection("users").doc(email).update(({
          'userSaveData${lastNumber.first}': param,
        }));
        EasyLoading.showSuccess("저장 완료");
      }
    }
  }
}
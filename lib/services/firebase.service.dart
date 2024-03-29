import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../models/app_user.model.dart';
import 'package:http/http.dart' as http;

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

  // 개인 설정 지역
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
    final keywordDeleteUser = await FirebaseFirestore.instance.collection("keywordnotification").doc(email);

    if(provider == 'kakao'){
      await UserApi.instance.unlink();
    }
    print("1 delete");
    checkUser.delete();
    keywordDeleteUser.delete();
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
          var data = <String, dynamic>{ key: FieldValue.delete(), };
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
    List getUserSaveData = []; List getUserSaveKeyData = [];
    var name =''; var profileImage = ''; var gender = ''; var age; bool alramlocalPermission = false;
    final checkDuplicate =  await FirebaseFirestore.instance.collection("users").doc(email).get();
    checkDuplicate.data()?.forEach((key, value) async {
      if(key.contains("name")){ name = value; }
      if(key.contains("profileImage")){ profileImage = value; }
      if(key.contains('gender')){ gender = value; }
      if(key == 'age'){ age = value; }
      if(key.contains("userSaveData")){
        getUserSaveData.add(value);
        getUserSaveKeyData.add(key);
      }
      if(key == "alramlocalPermission"){
        alramlocalPermission = value[0];
      }
    });
    var getUserData = {
      'name': name,
      'profileImage': profileImage,
      'gender': gender,
      'age' : age,
      'alramlocalPermission' : alramlocalPermission
    };
    return [getUserData, getUserSaveData, checkDuplicate.data(), getUserSaveKeyData];
  }

  //user key exist check
  static Future<bool?> getUserKeyExist(String email,String param) async {
    bool? ch = false;
    var checkKey = FirebaseFirestore.instance.collection("users").doc(email).get();
    await checkKey.then((value){
      // ch = value.data()?.keys.contains('alramlocal');
      value.data()?.keys.forEach((element) {
        if(element == param){
          ch = true;
        }
      });
    });
    return ch;
  }

  static Future<void> savePrivacyProfile(String email, List value, String key) async{
    var addValue = await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email);
    if(key == "keyword"){
        await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
          key: value,
        }));
      }
      if(key == "local"){
        await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
          key: value,
        }));
      }
    if(key == "recentSearch"){
      await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
        key: value,
      }));
    }
    if(key == 'alramlocal'){
      await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
        key: value,
      }));
    }
    if(key == 'alramlocalPermission'){
      await FirebaseFirestore.instance.collection("users").doc(UserService.to.currentUser.value!.email).update(({
        key: value,
      }));
    }
    if(key == "userSearchWord"){
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
  // notification Alarm
  // static Future<void> saveUserNotificationData(String email,List tempArray)async {
  //   final checkDuplicate =  await FirebaseFirestore.instance.collection("keywordnotification").doc(email).get();
  //   if(checkDuplicate.exists){
  //     var userList = [];
  //     var existUser = await FirebaseFirestore.instance.collection("keywordnotification").doc(email).get();
  //     existUser.data()?.forEach((key, value) {
  //       userList.add(int.parse(key.split("_")[1]));
  //     });
  //     userList.sort((a,b) {
  //       var adate = a; //before -> var adate = a.expiry;
  //       var bdate = b; //before -> var bdate = b.expiry;
  //       return bdate.compareTo(adate); //to get the order other way just switch `adate & bdate`
  //     });
  //
  //     for(int i = 0; i < tempArray.length; i++){
  //       var updateObject = {
  //         "title" : tempArray[i].title,
  //         "link" : tempArray[i].link,
  //         "center_name" : tempArray[i].center_name,
  //         "body" : tempArray[i].body,
  //         "registrationdate" : tempArray[i].registrationdate,
  //
  //       };
  //       await FirebaseFirestore.instance.collection("keywordnotification").doc(email).update(({
  //         'notification_${userList.first + i + 1}': updateObject,
  //       }));
  //     }
  //   }else{
  //     // 사용자가 존재하지 않을 경우
  //     for(int i = 0; i < tempArray.length; i++){
  //       var updateObject = {
  //         "title" : tempArray[i].title,
  //         "link" : tempArray[i].link,
  //         "center_name" : tempArray[i].center_name,
  //         "body" : tempArray[i].body,
  //         "registrationdate" : tempArray[i].registrationdate,
  //       };
  //       if(i == 0){
  //         await FirebaseFirestore.instance.collection("keywordnotification").doc(email).set(({
  //           'notification_$i': updateObject,
  //         }));
  //       }else{
  //         await FirebaseFirestore.instance.collection("keywordnotification").doc(email).update(({
  //           'notification_$i': updateObject,
  //         }));
  //       }
  //     }
  //   }
  // }

  // 자치구에 따라 url 가져오기
  static Future<Map<String, dynamic>> getUrlsByGu(String gu) async {
    final doc = await FirebaseFirestore.instance.collection("banner").doc("urls").get();
    // print(doc.data()?[gu]);

    return doc.data()?[gu];
  }

  // 크롤링 데이터 조회수 업데이트
  static Future<void> setCrawlingViewr(String document, String fieldName) async {
    final doc  = await FirebaseFirestore.instance.collection("crawlingData").doc(document).get();
    doc.data()?.forEach((key, value) {
      if(value['title'] == fieldName){
        // print("key : $key");
        // print("value['viewCount'] : ${value['viewCount']}");
        var viewCount = value['viewCount'] == null ? 1 : value['viewCount'] += 1;

        var changeData = <String, dynamic>{
          key : {
            "apperiod" : value['apperiod'],
            "center_name " : value['center_name '],
            "link" : value['link'],
            "number " : value['number'],
            "registrationdate" : value['registrationdate'],
            "result" : value['result'],
            "title" : value['title'],
            "viewCount": viewCount
          }
        };

        var removeData = <String, dynamic>{ key: FieldValue.delete(),};

        doc.reference.update(removeData);

        doc.reference.update(changeData);
      }
    });
  }

  static Future<int> saveCommunity(String category) async {
      final doc  = await FirebaseFirestore.instance.collection("community").doc(category).get();
      return doc.data()!.length;
  }

  static Future<void> welcomeMessage(userEmail) async {
    final exCheck = await FirebaseFirestore.instance.collection("keywordnotification").doc(userEmail).get();
    if(!exCheck.exists){
      return await FirebaseFirestore.instance.collection("keywordnotification").doc(userEmail).set(({
        'notification_0': {
          'body' : '키워드 사용법을 소개 합니다',
          'center_name' : '동네랑',
          'link' : 'https://bit.ly/dongnerangkeyword',
          'registrationdate' : '2023-01-01',
          'title' : '키워드 사용법을 소개 합니다',
        },
      }));
    }
  }

  }

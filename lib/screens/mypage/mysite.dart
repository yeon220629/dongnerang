import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../controller/private.setting.controller.dart';
import '../../services/firebase.service.dart';
import '../../services/user.service.dart';
import '../../util/logger.service.dart';
import '../mainScreenBar.dart';

class mysite extends GetView<PrivateSettingController> {
  List profilelocal = [];

  @override
  Widget build(BuildContext context) {
    Get.put(PrivateSettingController());
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('나의 지역', style: TextStyle( color: AppColors.black),),
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text('나의 지역', style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 18.5,
              //     color: Colors.black)),
              // SizedBox(width: 100,),
              TextButton(
                  onPressed: () async {
                    print("PrivateLocalData : $PrivateLocalData");
                    print("profilelocal : $profilelocal");
                    if (controller.formKey.currentState!.validate()) {
                      try {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(UserService.to.currentUser.value!.email)
                            .update(({
                          "local": profilelocal.isEmpty
                              ? PrivateLocalData
                              : profilelocal[0]
                        }));
                        await FirebaseService.getUserKeyExist(UserService.to.currentUser.value!.email).then((value) {
                          if(value == true){
                            // String email, List value, String key
                            profilelocal.isEmpty
                                ? FirebaseService.savePrivacyProfile(UserService.to.currentUser.value!.email,PrivateLocalData,'alramlocal')
                                : FirebaseService.savePrivacyProfile(UserService.to.currentUser.value!.email,profilelocal[0],'alramlocal');
                          }else{
                            profilelocal.isEmpty
                                ? FirebaseService.savePrivacyProfile(UserService.to.currentUser.value!.email,PrivateLocalData,'alramlocal')
                                : FirebaseService.savePrivacyProfile(UserService.to.currentUser.value!.email,profilelocal[0],'alramlocal');
                          }
                        });

                        profilelocal = [];
                        EasyLoading.showSuccess("프로필 수정 완료");
                        await FirebaseService.getCurrentUser();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                            builder: (BuildContext context) =>
                                mainScreen()), (route) => false);
                      } catch (e) {
                        logger.e(e);
                        EasyLoading.showSuccess("프로필 수정 실패");
                      }
                    }
                  }, child: Text("완료", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),)),
            ],
          )
        ],
        leading:  IconButton(
            onPressed: () {
              Navigator.pop(context); //뒤로가기
            },
            color: Colors.black,
            icon: Icon(Icons.arrow_back)),
      ),
      body: SizedBox(
        child: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          return KeyboardDismissOnTap(
            child: Form(
              key: controller.formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                children: [
                  Stack(
                    children: [
                      TagKeywordStateful(callback: (value) {
                        profilelocal.add(value);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TagKeywordStateful extends StatefulWidget {
  late final Function callback;
  TagKeywordStateful({required this.callback});

  @override
  State<TagKeywordStateful> createState() => _TagKeywordStatefulState();
}

class _TagKeywordStatefulState extends State<TagKeywordStateful> {

  final List tags = [];
  final List select_tags = [];
  List selected_tags = [];
  bool selectCheck = false;

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(height: size.height / 30,),
        Row(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text("지역선택", style: TextStyle(fontWeight: FontWeight.bold),),
            )
          ],
        ),
        SizedBox(height: 5,),
        Container(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: size.width / 20, runSpacing: 2.0, children: <Widget>[...generate_tags(CustomData)], ),
        ),
        Text("   * 지역 선택은 최대 3개까지 가능 합니다.", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey),),
      ],
    );
  }

  generate_tags(value) {
    return value.map((tag) => get_chip(tag)).toList();
  }
  get_chip(name) {
    for(int i =0; i < PrivateLocalData.length; i++){
      if(PrivateLocalData.length == 3){
        if(name == PrivateLocalData[0] || name == PrivateLocalData[1] || name == PrivateLocalData[2]){
          selectCheck = false;
        }else{
          selectCheck = true;
        }
      }else if(PrivateLocalData.length == 2){
        if(name == PrivateLocalData[0] || name == PrivateLocalData[1]){
          selectCheck = false;
        }else{
          selectCheck = true;
        }
      }else{
        if(name == PrivateLocalData[0]){
          selectCheck = false;
        }else{
          selectCheck = true;
        }
      }
    }
    return FilterChip(
      selected: selected_tags.contains(name),
      selectedColor: AppColors.primary,
      // disabledColor: Colors.blue.shade400,
      avatar: (name == "강남") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/GANGNAM.PNG')) :
      (name == "강동") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/GANGDONG.PNG')) :
      (name == "강북") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/GANGBUK.PNG')) :
      (name == "강서") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/GANGSEO.PNG')) :
      (name == "관악") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/GWANAK.PNG')) :
      (name == "광진") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/GWANGZIN.PNG')) :
      (name == "구로") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/GOORO.PNG')) :
      (name == "금천") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/GEUAMCHEOUN.PNG')) :
      (name == "노원") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/NOWON.PNG')) :
      (name == "도봉") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/DOBONG.PNG')) :
      (name == "중구") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/JUNGGU.PNG')) :
      (name == "동작") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/DONGJAK.PNG')) :
      (name == "마포") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/MAPO.PNG')) :
      (name == "서초") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/SEOCHO.PNG')) :
      (name == "중랑") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/JUNGNANG.PNG')) :
      (name == "종로") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/JONGRO.PNG')) :
      (name == "성동") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/SEONGDONG.PNG')) :
      (name == "성북") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/SEONGBUK.PNG')) :
      (name == "송파") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/SONGPA.PNG')) :
      (name == "양천") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/YANGCHEON.PNG')) :
      (name == "용산") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/YONGSAN.PNG')) :
      (name == "은평") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/EUNPYENG.PNG')) :
      (name == "동대문") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/DONGDAEMUN.PNG')) :
      (name == "영등포") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/YEONGDEUNGPO.PNG')) :
      (name == "서대문") ?
      CircleAvatar(backgroundImage: AssetImage('assets/images/SEODAEMUN.PNG')) :
      SizedBox(),
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: selected_tags.contains(name)? BorderSide(color: AppColors.white) : BorderSide(color: AppColors.grey)),
      label: selectCheck == false
          ? name == "중구"
          ? Text("${name}", style: TextStyle(color:AppColors.primary, fontWeight: FontWeight.bold))
          : Text("${name}구", style: TextStyle(color:AppColors.primary, fontWeight: FontWeight.bold)
      )
          : name == "중구"
          ? Text("${name}")
          : Text("${name}구"
      ),
      labelStyle: TextStyle(
        color: selected_tags.contains(name)? Colors.white : Colors.black,
      ),
      onSelected: (value) {
        if (select_tags.length > 2) {
          value = false;
        }
        if (value == true) {
          select_tags.add(name);
        }
        if (value == false) {
          select_tags.remove(name);
        }
        setState(() {
          selected_tags = select_tags;
          widget.callback(selected_tags);
        });
      },
    );
  }
}

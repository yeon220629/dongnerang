import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/setting/private.setting.keyword.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../controller/private.setting.controller.dart';
import '../../services/firebase.service.dart';
import '../../services/user.service.dart';
import '../../util/logger.service.dart';
import '../mainScreenBar.dart';

class privateSettingLocalScreen extends GetView<PrivateSettingController> {
  final formKey = GlobalKey<FormState>();

  List local = [];

  // 키워드 및 지역 변경 할 사항
  var selected_tags = [];
  var select_tags = [];
  get value => null;

  fnCheckValue(local) {
    if (local.isEmpty || local[0].length == 0) {
      EasyLoading.showInfo("지역을 선택해 주세요");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Get.put(PrivateSettingController());
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width,
                child: Center(
                  child: Text(
                    '개인설정',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.5,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            color: Colors.black,
            icon: Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          return KeyboardDismissOnTap(
            child: Form(
              key: formKey,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          TagKeywordStateful(callback: (value) {
                            local.add(value);
                          }),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          var checkValue = fnCheckValue(local);
                          if (checkValue) {
                            if (formKey.currentState!.validate()) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(
                                        UserService.to.currentUser.value?.email)
                                    .update(({
                                      "local": local[0],
                                    }));
                                // EasyLoading.showSuccess("개인설정 추가 완료");
                                await FirebaseService.getCurrentUser();
                                Get.to(privateSettingKeywordScreen());
                              } catch (e) {
                                logger.e(e);
                                EasyLoading.showSuccess("개인설정 추가 실패");
                              }
                            }
                          } else {
                            print("항목 선택 안 한 것 이 있 음...");
                          }
                        },
                        child: Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
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
  List tags = [];
  List selected_tags = [];
  List select_tags = [];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        // SizedBox(height: size.height / 30,),
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
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center(
            //   child:
        Container(
                width: size.width,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: size.width / 20, runSpacing: 2.0,
                  children: <Widget>[...generate_tags(CustomData),
                  Text("   * 지역 선택은 최대 3개까지 가능 합니다.", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey),),
                  ],
                ),
              ),
            // ),
          ],
        ));
  }

  generate_tags(value) {
    return value.map((tag) => get_chip(tag)).toList();
  }

  get_chip(name) {
    // String named = name;
    return ChoiceChip(
      selected: selected_tags.contains(name),
      selectedColor: AppColors.primary,
      avatar: (name == "강남")
          ? CircleAvatar(
              backgroundImage: AssetImage('assets/images/GANGNAM.PNG'))
          : (name == "강동")
              ? CircleAvatar(
                  backgroundImage: AssetImage('assets/images/GANGDONG.PNG'))
              : (name == "강북")
                  ? CircleAvatar(
                      backgroundImage: AssetImage('assets/images/GANGBUK.PNG'))
                  : (name == "강서")
                      ? CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/GANGSEO.PNG'))
                      : (name == "관악")
                          ? CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/GWANAK.PNG'))
                          : (name == "광진")
                              ? CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/images/GWANGZIN.PNG'))
                              : (name == "구로")
                                  ? CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/images/GOORO.PNG'))
                                  : (name == "금천")
                                      ? CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'assets/images/GEUAMCHEOUN.PNG'))
                                      : (name == "노원")
                                          ? CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  'assets/images/NOWON.PNG'))
                                          : (name == "도봉")
                                              ? CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/images/DOBONG.PNG'))
                                              : (name == "중구")
                                                  ? CircleAvatar(
                                                      backgroundImage: AssetImage(
                                                          'assets/images/JUNGGU.PNG'))
                                                  : (name == "동작")
                                                      ? CircleAvatar(
                                                          backgroundImage:
                                                              AssetImage(
                                                                  'assets/images/DONGJAK.PNG'))
                                                      : (name == "마포")
                                                          ? CircleAvatar(
                                                              backgroundImage:
                                                                  AssetImage(
                                                                      'assets/images/MAPO.PNG'))
                                                          : (name == "서초")
                                                              ? CircleAvatar(
                                                                  backgroundImage:
                                                                      AssetImage(
                                                                          'assets/images/SEOCHO.PNG'))
                                                              : (name == "중랑")
                                                                  ? CircleAvatar(
                                                                      backgroundImage:
                                                                          AssetImage(
                                                                              'assets/images/JUNGNANG.PNG'))
                                                                  : (name ==
                                                                          "종로")
                                                                      ? CircleAvatar(
                                                                          backgroundImage:
                                                                              AssetImage('assets/images/JONGRO.PNG'))
                                                                      : (name == "성동")
                                                                          ? CircleAvatar(backgroundImage: AssetImage('assets/images/SEONGDONG.PNG'))
                                                                          : (name == "성북")
                                                                              ? CircleAvatar(backgroundImage: AssetImage('assets/images/SEONGBUK.PNG'))
                                                                              : (name == "송파")
                                                                                  ? CircleAvatar(backgroundImage: AssetImage('assets/images/SONGPA.PNG'))
                                                                                  : (name == "양천")
                                                                                      ? CircleAvatar(backgroundImage: AssetImage('assets/images/YANGCHEON.PNG'))
                                                                                      : (name == "용산")
                                                                                          ? CircleAvatar(backgroundImage: AssetImage('assets/images/YONGSAN.PNG'))
                                                                                          : (name == "은평")
                                                                                              ? CircleAvatar(backgroundImage: AssetImage('assets/images/EUNPYENG.PNG'))
                                                                                              : (name == "동대문")
                                                                                                  ? CircleAvatar(backgroundImage: AssetImage('assets/images/DONGDAEMUN.PNG'))
                                                                                                  : (name == "영등포")
                                                                                                      ? CircleAvatar(backgroundImage: AssetImage('assets/images/YEONGDEUNGPO.PNG'))
                                                                                                      : (name == "서대문")
                                                                                                          ? CircleAvatar(backgroundImage: AssetImage('assets/images/SEODAEMUN.PNG'))
                                                                                                          : SizedBox(),
      // labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      backgroundColor: Colors.white,
      shape: StadiumBorder(
          side: selected_tags.contains(name)
              ? BorderSide(color: AppColors.white)
              : BorderSide(color: AppColors.grey)),
      // autofocus: true,
      // shape: OutlinedBorder(side: BorderSide(color: AppColors.grey,)),
      label: name == "중구" ? Text("${name}") : Text("${name}구"),
      labelStyle: TextStyle(
        color: selected_tags.contains(name) ? Colors.white : Colors.black,
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

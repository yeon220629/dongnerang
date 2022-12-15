import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/setting/private.setting.birth.gender.screen.dart';
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

class privateSettingLocalKeywordScreen
    extends GetView<PrivateSettingController> {
  final formKey = GlobalKey<FormState>();

  List keyword = [];
  List local = [];

  // 키워드 및 지역 변경 할 사항
  var selected_tags = [];
  var select_tags = [];
  get value => null;

  fnCheckValue(local) {
    if (local.isEmpty) {
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
              Text('개인설정',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.5,
                      color: Colors.black)),
              SizedBox(
                width: 100,
              ),
              TextButton(
                  onPressed: () async {
                    if (keyword.isEmpty) {
                      keyword.add('');
                    }
                    var checkValue = fnCheckValue(local);
                    if (checkValue) {
                      if (formKey.currentState!.validate()) {
                        try {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(UserService.to.currentUser.value?.email)
                              .update(({
                                "keyword": keyword[0],
                                "local": local[0],
                              }));
                          CustomKeyword = [];
                          keyword = [];
                          EasyLoading.showSuccess("개인설정 추가 완료");
                          await FirebaseService.getCurrentUser();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      mainScreen()),
                              (route) => false);
                        } catch (e) {
                          logger.e(e);
                          EasyLoading.showSuccess("개인설정 추가 실패");
                        }
                      }
                    } else {
                      print("항목 선택 안 한 것 이 있 음...");
                    }
                  },
                  child: Text("완료",
                      style: TextStyle(color: Colors.black, fontSize: 15))),
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
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 35),
                    child: Text(
                      "관심 키워드",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "선택하신 관심 키워드에 따라\n개인 맞춤형 푸시 알림을 보내드려요",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  KeywordStateful(callback: (value) {
                    keyword.add(value);
                  }),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                      "지역 선택",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "지역은 최대 3개 선택 가능하며,\n마이페이지-프로필 설정에서 변경 가능해요",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TagKeywordStateful(callback: (value) {
                    local.add(value);
                  }),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class KeywordStateful extends StatefulWidget {
  late final Function callback;
  KeywordStateful({required this.callback});

  @override
  State<KeywordStateful> createState() => _KeywordStatefulState();
}

class _KeywordStatefulState extends State<KeywordStateful> {
  final myController = TextEditingController();
  List tags = [];
  List selected_tags = [];
  List select_tags = [];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.30;

    return Container(
        margin: EdgeInsets.only(top: 35),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: FittedBox(
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(
                      width: size.width,
                      height: size.height / 13,
                      // height: 70,
                      child: TextFormField(
                        controller: myController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            color: AppColors.grey,
                            // color: select_tags.add(myController.text) ? AppColors.grey : AppColors.primary,
                            onPressed: () {
                              if (myController.text == '') {
                                EasyLoading.showInfo("공백은 등록 하실 수 없습니다.");
                                return;
                              }

                              if (CustomKeyword.length != 0) {
                                for (int i = 0; i < CustomKeyword.length; i++) {
                                  if (CustomKeyword[i] == myController.text) {
                                    EasyLoading.showInfo("중복값은 포함 될 수 없습니다..");
                                    return;
                                  }
                                }
                              }
                              setState(() {
                                select_tags.add(myController.text);
                                CustomKeyword.add(myController.text);
                                widget.callback(select_tags);
                              });
                              myController.clear();
                            },
                          ),
                          hintText: '관심 키워드를 등록해주세요! ex)예술, 공간 등',
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(13)),
                              borderSide: BorderSide(
                                width: 1,
                                color: AppColors.primary,
                              )),
                          focusColor: AppColors.primary,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(13)),
                            borderSide: BorderSide(
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: size.width,
                          // margin: const EdgeInsets.only(right: 5),
                          // height: categoryHeight - 180,
                          height: 50,
                          // child: Center(
                          child: ListView(
                            // reverse: true,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            // padding: EdgeInsets.all(5),
                            children: <Widget>[...generate_tags(CustomKeyword)],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  //키워드 삭제 하는 부분으로 일단 보류
  generate_tags(value) {
    return value.map((tag) => get_chip(tag)).toList();
  }

  get_chip(name) {
    return Padding(
        padding: EdgeInsets.all(2),
        child: Chip(
          backgroundColor: AppColors.primary,
          labelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          // deleteButtonTooltipMessage: '삭제하시겠습니까?',
          deleteIcon: Icon(
            Icons.close,
            size: 15,
          ),
          deleteIconColor: Colors.white,
          label: Text('$name'),
          onDeleted: () {
            setState(() {
              CustomKeyword.remove(name);
              select_tags.remove(name);
            });
          },
        ));
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

    return Container(
        margin: EdgeInsets.only(top: 35, bottom: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: size.width / 1.2,
                // alignment: C,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  // direction: Axis.horizontal,
                  spacing: size.width / 20,
                  runSpacing: 2.0,
                  children: <Widget>[...generate_tags(CustomData)],
                ),
              ),
            ),
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

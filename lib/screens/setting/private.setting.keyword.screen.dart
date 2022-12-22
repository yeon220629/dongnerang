import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class privateSettingKeywordScreen extends GetView<PrivateSettingController> {
  final formKey = GlobalKey<FormState>();

  // 키워드 및 지역 변경 할 사항
  var selected_tags = [];
  var select_tags = [];
  get value => null;

  @override
  Widget build(BuildContext context) {
    Get.put(PrivateSettingController());
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              "관심 키워드",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
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
                            Privatekeyword.add(value);
                          }),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          var resultList = [];
                          if (Privatekeyword.isEmpty) {
                            // Privatekeyword.add('');
                            resultList.add('');
                          }
                          else {
                            for (int i = 0; i < Privatekeyword.length; i ++) {
                              for (var i in Privatekeyword[i]) {
                                if (resultList.contains(i)) {
                                  print("값이 이미 있음..");
                                } else {
                                  resultList.add(i);
                                }
                              }
                            }
                          }
                          // print("After : $resultList");

                          if (formKey.currentState!.validate()) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(UserService.to.currentUser.value?.email)
                                  .update(({
                                    "keyword": resultList,
                                  }));
                              CustomKeyword = [];
                              Privatekeyword = [];
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
                          } else {
                            print("항목 선택 안 한 것 이 있 음...");
                          }
                        },
                        child: Text(
                          '완료',
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
        margin: EdgeInsets.only(top: 20),
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
                        onFieldSubmitted: (value) {
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
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20.0),
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
                          hintText: '관심 키워드를 등록해 주세요! ex)예술, 공간 등',
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
              Privatekeyword.remove(name);
              CustomKeyword.remove(name);
              select_tags.remove(name);
            });
          },
        ));
  }
}

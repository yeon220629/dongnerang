import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/setting/private.setting.local.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../controller/private.setting.controller.dart';
import '../../services/firebase.service.dart';
import '../../services/user.service.dart';
import '../../util/logger.service.dart';
import '../mainScreenBar.dart';

class privateSettingBirthGenderScreen
    extends GetView<PrivateSettingController> {
  final formKey = GlobalKey<FormState>();

  late birthDay ages;
  String gender = '';

  set ageValue(ageValue) {
    ages = ageValue;
  }

  fnCheckValue(age, gender) {
    print("age: $age");
    print("gender: $gender");

    if (gender == '') {
      EasyLoading.showInfo("성별을 선택해 주세요");
      return false;
    } else if (age['year'] == '' || age['month'] == '' || age['dat'] == '') {
      EasyLoading.showInfo("생년월일을 선택해 주세요");
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
          ),
        ],
        leading: IconButton(
            onPressed: () {
              exit(0);
              Navigator.pop(context); //뒤로가기
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
                              "생년월일",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "생년월일 입력 시, 내 연령대에 맞는\n유용한 공공소식을 전해드려요",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          AgeStatefulWidget(callback: (value) {
                            ageValue = value;
                          }),
                          Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              "성별",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          genderChoiceWidget(callback: (value) {
                            gender = value;
                          }),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          var checkValue = fnCheckValue(ages.toJson(), gender);
                          if (checkValue) {
                            if (formKey.currentState!.validate()) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(
                                        UserService.to.currentUser.value?.email)
                                    .update(({
                                      "age": ages.toJson(),
                                      "gender": gender,
                                    }));
                                // EasyLoading.showSuccess("개인설정 추가 완료");
                                await FirebaseService.getCurrentUser();
                                Get.to(privateSettingLocalScreen());
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

class AgeStatefulWidget extends StatefulWidget {
  final Function callback;
  AgeStatefulWidget({required this.callback});
  @override
  State<AgeStatefulWidget> createState() => _AgeStatefulWidgetWidgetState();
}

class _AgeStatefulWidgetWidgetState extends State<AgeStatefulWidget> {
  String? defaultYear = '2022';
  String? defaultMonth = '1';
  String? defaultDay = '1';
  birthDay birth = new birthDay(year: '', month: '', day: '');

  DateTime date = DateTime.utc(2000,1,1);

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 290,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: AppColors.red,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      date = DateTime.now();
                      birth.year = '';
                      birth.month = '';
                      birth.day = '';
                    });
                    Navigator.pop(context);
                  },
                ),
                CupertinoButton(
                  child: Text(
                    '완료',
                    style: TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Container(
              height: 220,
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: SafeArea(
                top: false,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    widget.callback(birth);
    print(size.width - 100);
    //생년월일 ui
    return Container(
        margin: EdgeInsets.only(top: 20),
        width: size.width,
        height: 55,
        child: _DatePickerItem(
          children: <Widget>[
            CupertinoButton(
                child: Container(
                    width: size.width - 130,
                    child: birth.year == ''
                        ? Text(
                            '생년월일을 입력해주세요',
                            style: const TextStyle(
                              color: AppColors.grey,
                            ),
                          )
                        : Text(
                            '${date.year}년 ${date.month}월 ${date.day}일',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          )),
                onPressed: () => _showDialog(CupertinoDatePicker(
                      initialDateTime: date,
                      minimumYear: 1900,
                      maximumDate: DateTime.now(),
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() => date = newDate);
                        setState(() {
                          birth.year = newDate.year.toString();
                          birth.month = newDate.month.toString();
                          birth.day = newDate.day.toString();
                        });
                      },
                    )))
          ],
        ));
  }
}

class _DatePickerItem extends StatelessWidget {
  const _DatePickerItem({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          width: 1,
          color: AppColors.grey,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}

class genderChoiceWidget extends StatefulWidget {
  final Function callback;
  genderChoiceWidget({required this.callback});
  @override
  State<genderChoiceWidget> createState() => _genderChoiceState();
}

class _genderChoiceState extends State<genderChoiceWidget> {
  late List<bool> isClick;
  bool man = false;
  bool girl = false;
  String gender = '';

  @override
  void initState() {
    // TODO: implement initState
    isClick = [man, girl];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.only(top: 20),
      child: SizedBox(
          width: size.width,
          height: 55,
          child: ToggleButtons(
            borderWidth: 1,
            borderRadius: BorderRadius.circular(13),
            borderColor: AppColors.grey,
            color: Colors.grey,
            fillColor: AppColors.primary,
            selectedColor: Colors.white,
            focusColor: AppColors.white,
            selectedBorderColor: AppColors.primary,
            children: [
              Container(
                child: SizedBox(
                  width: (size.width - 56) / 2,
                  // padding: EdgeInsets.symmetric(horizontal: size.width / 6),
                  child: Text(
                    '남성',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                child: SizedBox(
                  width: (size.width - 56) / 2,
                  // padding: EdgeInsets.symmetric(horizontal: 100),
                  child: Text(
                    '여성',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
            onPressed: toggleSelect,
            isSelected: isClick,
          )),
    );
  }

  void toggleSelect(value) {
    if (value == 0) {
      man = true;
      girl = false;
      gender = '남성';
      widget.callback(gender);
    }
    if (value == 1) {
      girl = true;
      man = false;
      gender = '여성';
      widget.callback(gender);
    }
    setState(() {
      isClick = [man, girl];
    });
  }
}

class birthDay {
  String year = '';
  String month = '';
  String day = '';
  birthDay({
    required this.year,
    required this.month,
    required this.day,
  });
  birthDay.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    month = json['month'];
    day = json['day'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['year'] = this.year;
    data['month'] = this.month;
    data['day'] = this.day;
    return data;
  }
}

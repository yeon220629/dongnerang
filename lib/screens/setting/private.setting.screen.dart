import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../controller/private.setting.controller.dart';
import '../../services/firebase.service.dart';
import '../../services/user.service.dart';
import '../../util/logger.service.dart';
import '../mainScreenBar.dart';

class privateSettingScreen extends GetView<PrivateSettingController> {
  late birthDay ages;
  List keyword = [];
  List local = [];
  String gender = '';

  // 키워드 및 지역 변경 할 사항
  var selected_tags = [];
  var select_tags = [];
  get value => null;

  set ageValue(ageValue) {
    ages = ageValue;
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
              Text('개인설정', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.5,
                  color: Colors.black)),
              SizedBox(width: 100,),
              TextButton(
                  onPressed: () async {
                    print("keyword : ${keyword}");
                    if (controller.formKey.currentState!.validate()) {
                      try {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(UserService.to.currentUser.value!.email)
                            .update(({
                          "age": ages.toJson(),
                          "keyword": keyword[0],
                          "local": local[0],
                          "gender" : gender,
                        }));
                        CustomKeyword = [];
                        EasyLoading.showSuccess("개인설정 추가 완료");
                        await FirebaseService.getCurrentUser();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                            builder: (BuildContext context) =>
                                mainScreen()), (route) => false);
                      } catch (e) {
                        logger.e(e);
                        EasyLoading.showSuccess("개인설정 추가 실패");
                      }
                    }
                  }, child: Text("완료", style: TextStyle(color: Colors.black, fontSize: 15))),
            ],
          )
        ],
        leading:  IconButton(
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
                key: controller.formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  children: [
                    Stack(
                        children: [
                          Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: size.height / 150),
                                  child : Container(
                                    alignment: Alignment.centerLeft,
                                    child:Text("생년월일", style: TextStyle(fontWeight: FontWeight.bold),),
                                  )
                              ),
                              SizedBox(height: 5,),
                              AgeStatefulWidget(callback: (value) {
                                ageValue = value;
                              }),
                              // SizedBox(height: 8,),
                              // Container(
                              //   alignment: Alignment.centerLeft,
                              //   child: Text("  * 연령대에 맞는 공공사업을 추천할때 사용됩니다.", style: TextStyle(color: Colors.black45),),
                              // )
                            ],
                          ),
                          genderChoiceWidget(callback: (value){
                            print(value);
                            gender = value;
                          }),
                          KeywordStateful(callback: (value) {
                            keyword.add(value);
                          }),
                          TagKeywordStateful(callback: (value) {
                            local.add(value);
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
      ),
      // ),
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

    return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height / 4),
        child: Column(
          children: [
            Row(
              children: [
                Text("키워드", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Container(
                        width: size.width,
                        child: TextFormField(
                          controller: myController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              color: AppColors.grey,
                              // color: select_tags.add(myController.text) ? AppColors.grey : AppColors.primary,
                              onPressed: () {
                                print("myController : ${myController.text}");
                                select_tags.add(myController.text);
                                setState(() {
                                  CustomKeyword.add(myController.text);
                                  widget.callback(select_tags);
                                });
                                myController.clear();
                              },
                            ),
                            hintText: '관심 키워드를 등록해주세요! ex)예술, 공간, 모집',
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(13)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: AppColors.primary,
                                )
                            ),
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
                            width: categoryHeight * 1.7,
                            // margin: const EdgeInsets.only(right: 5),
                            height: categoryHeight - 180,
                            // child: Center(
                            child: ListView(
                              // reverse: true,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              // padding: EdgeInsets.all(5),
                              children: <Widget>[...generate_tags(CustomKeyword)],
                            ),
                            // ),
                          ),
                        ],
                      ),
                    ],
                  )
              ),
            ),
          ],
        )
    );
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
        labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        // deleteButtonTooltipMessage: '삭제하시겠습니까?',
        deleteIcon: Icon(Icons.close, size: 15,),
        deleteIconColor: Colors.white,
        label: Text('$name'),
        onDeleted: (){
          setState(() {
            CustomKeyword.remove(name);
          });
        },
      )
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    widget.callback(birth);
    //생년월일 ui
    return Container(
        width: size.width,
        decoration: BoxDecoration(
            border: Border.all( color: AppColors.grey, width: 1),
            borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
            child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton(
                          // style: TextStyle(color: Colors.red,fontSize: 30),
                          menuMaxHeight: 580,
                          // dropdownColor: AppColors.primary,
                          underline: Container(),
                            // iconDisabledColor: AppColors.grey,
                            // iconEnabledColor: AppColors.primary,
                            isDense: true,
                            value: defaultYear,
                            items: dropdownYear.map( (value) {
                              return DropdownMenuItem (
                                value: value, child: Text(value),
                              );
                            },
                            ).toList(),
                            onChanged: (value){ setState(() {
                              defaultYear = value as String?;
                              birth.year = value!;
                            });
                            }
                        ),
                        DropdownButton(
                            menuMaxHeight: 580,
                            underline: Container(),
                            value: defaultMonth,
                            items: dropdownMonth.map( (value) {
                              return DropdownMenuItem (
                                value: value, child: Text(value),
                              );
                            },
                            ).toList(), onChanged: (value){ setState(() {
                              defaultMonth = value as String?;
                              birth.month = value!;
                            });
                            }
                        ),
                        DropdownButton(
                            menuMaxHeight: 580,
                            underline: Container(),
                            value: defaultDay,
                            items: dropdownDay.map( (value) {
                              return DropdownMenuItem (
                                value: value, child: Text(value),
                              );
                            },
                            ).toList(), onChanged: (value){
                              setState(() {
                                defaultDay = value as String?;
                                birth.day = value!;
                              });
                            }
                        )
                      ],
                    )
                  ],
                )
            )
        )
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
    return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height / 2.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              // padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Wrap( spacing: 4.0, runSpacing: 2.0, children: <Widget>[...generate_tags(CustomData)], ),
            ),
            Text("   * 지역 선택은 최대 3개까지 가능 합니다.", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey),),
          ],
        )
    );
  }

  generate_tags(value) {
    return value.map((tag) => get_chip(tag)).toList();
  }
  get_chip(name) {
    // String named = name;
    return ChoiceChip(
      // showCheckmark: false,
      selected: selected_tags.contains(name),
      selectedColor: AppColors.primary,
      // checkmarkColor: AppColors.primary,
      // sel
      // selectedColor: AppColors.primary,
      // disabledColor: AppColors.primary,
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
                SizedBox(),
      // labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: selected_tags.contains(name)? BorderSide(color: AppColors.white) : BorderSide(color: AppColors.grey)),
      // autofocus: true,
      // shape: OutlinedBorder(side: BorderSide(color: AppColors.grey,)),
      label: Text("${name}"),
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

    return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height / 7.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text("성별", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 5,),
            Container(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    borderWidth: 1,
                    borderRadius: BorderRadius.circular(10),
                    borderColor: AppColors.grey,
                    color: Colors.grey,
                    fillColor: AppColors.primary,
                    selectedColor: Colors.white,
                    focusColor: AppColors.white,
                    selectedBorderColor: AppColors.primary,
                    children: [
                      Container(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width / 6),
                            child: Text('남성', style: TextStyle(fontSize: 16))
                        ),
                      ),
                      Container(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width / 6),
                            child: Text('여성', style: TextStyle(fontSize: 16))),
                      )
                    ],
                    onPressed: toggleSelect,
                    isSelected: isClick,
                  )
                ],
              ),
            )
          ],
        )
    );
  }
  void toggleSelect(value) {
    print(value);
    if (value == 0) {
      man = true;
      girl = false;
      gender = '남성';
      widget.callback(gender);
    } if(value == 1) {
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
  birthDay(
      {required this.year,
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
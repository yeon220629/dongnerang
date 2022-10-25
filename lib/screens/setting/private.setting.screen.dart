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
                  }, child: Text("완료", style: TextStyle(color: Colors.black))),
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            children: [
              Center(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: size.height / 220),
                          child : Container(
                            alignment: Alignment.centerLeft,
                            child:Text("생년월일", style: TextStyle(fontWeight: FontWeight.bold),),
                          )
                        ),
                        SizedBox(height: 5,),
                        AgeStatefulWidget(callback: (value) {
                          ageValue = value;
                        }),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text("*연령대에 맞는 공공사업을 추천할때 사용됩니다.", style: TextStyle(fontWeight: FontWeight.normal),),
                        )
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
        padding: EdgeInsets.symmetric(vertical: size.height / 3.9),
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
                          labelText: '관심키워드를 등록해주세요! ex)청년, 예술',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: categoryHeight * 1.5,
                          margin: const EdgeInsets.only(right: 5),
                          height: categoryHeight - 170,
                          child: Center(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              padding: EdgeInsets.all(10),
                              children: <Widget>[...generate_tags(CustomKeyword)],
                            ),
                          ),
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
    return FilterChip(
      selected: selected_tags.contains(name),
      disabledColor: Colors.blue.shade400,
      backgroundColor: AppColors.blue,
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      label: Text("${name}"),
      onSelected: (value) {
        print("${value} : ${name}");
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
    widget.callback(birth);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0.5),
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
                  DropdownButton( value: defaultMonth,
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
                  DropdownButton( value: defaultDay,
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
        padding: EdgeInsets.symmetric(vertical: size.height / 2.4),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Text("지역 선택", style: TextStyle(fontWeight: FontWeight.bold),),
                )
              ],
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Wrap( spacing: 4.0, runSpacing: 2.0, children: <Widget>[...generate_tags(CustomData)], ),
            ),
            Text("지역 선택은 최대 3개까지 가능 합니다.", style: TextStyle(fontWeight: FontWeight.bold),),
          ],
        )
    );
  }

  generate_tags(value) {
    return value.map((tag) => get_chip(tag)).toList();
  }
  get_chip(name) {
    return FilterChip(
      selected: selected_tags.contains(name),
      selectedColor: Colors.blue.shade800,
      disabledColor: Colors.blue.shade400,
      avatar: Text(""),
      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      label: Text("${name}"),
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
      padding: EdgeInsets.symmetric(vertical: size.height / 6.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text("성별", style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                  fillColor: AppColors.blue,
                  selectedColor: AppColors.white,
                  focusColor: AppColors.white,
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width / 6.5),
                        child: Text('남성', style: TextStyle(fontSize: 18, color: AppColors.black))
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width / 6.5),
                        child: Text('여성', style: TextStyle(fontSize: 18,color: AppColors.black))),
                    )
                  ],
                onPressed: toggleSelect,
                isSelected: isClick,
              )
            ],
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
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../../constants/common.constants.dart';
import '../../controller/private.setting.controller.dart';
import '../../services/firebase.service.dart';
import '../../services/user.service.dart';
import '../../util/logger.service.dart';
import '../mainScreenBar.dart';

class privateSettingScreen extends GetView<PrivateSettingController> {
  double ages = 0;
  List keyword = [];
  List local = [];
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
                    // print("age : ${ages.round().toString()}");
                    // print("keyword : ${keyword[0]}");
                    // print("local : ${local[0]}");
                    if (controller.formKey.currentState!.validate()) {
                      try {
                        print("test");
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(UserService.to.currentUser.value!.email)
                            .update(({
                          "age": ages.round().toString(),
                          "keyword": keyword[0],
                          "local": local[0],
                        }));
                        EasyLoading.showSuccess("개인설정 추가 완료");
                        await FirebaseService.getCurrentUser();
                        Get.off(() => mainScreen());
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            children: [
              Center(
                child: Stack(
                  children: [
                    // AgeStatefulWidget(callback: (value) {
                    //   ageValue = value;
                    // }),
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

class KeywordStatefulWidget extends StatefulWidget {
  const KeywordStatefulWidget({Key? key}) : super(key: key);

  @override
  State<KeywordStatefulWidget> createState() => _KeywordStatefulWidgetState();
}

class _KeywordStatefulWidgetState extends State<KeywordStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
class KeywordStateful extends StatefulWidget {
  late final Function callback;
  KeywordStateful({required this.callback});

  @override
  State<KeywordStateful> createState() => _KeywordStatefulState();
}

class _KeywordStatefulState extends State<KeywordStateful> {
  List tags = [];
  List selected_tags = [];
  List select_tags = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          children: [
            Row(
              children: [
                Text("키워드", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Wrap( spacing: 4.0, runSpacing: 2.0, children: <Widget>[...generate_tags(CustomKeyword)], ),
            ),
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
      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onDeleted,
    required this.index,
  });
  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.only(left: 8.0),
      label: Text(label),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
      ),
      onDeleted: () {
        onDeleted(index);
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
  double _currentSliderValue = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text("연령대", style: TextStyle(fontWeight: FontWeight.bold),),
          //     Text("${_currentSliderValue.round().toString()}세"),
          //   ],
          // ),
          // Container(
          //   width: double.maxFinite,
          //   child: CupertinoSlider(
          //     min: 0,
          //     max: 100,
          //     value: _currentSliderValue,
          //     onChanged: (value) {
          //       setState(() {
          //         _currentSliderValue = value;
          //         widget.callback(_currentSliderValue);
          //       });
          //     },
          //   ),
          // )
        ],
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

    return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height / 5.5),
        child: Column(
          children: [
            Row(
              children: [
                Text("지역 선택", style: TextStyle(fontWeight: FontWeight.bold),),
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
        print(value);
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

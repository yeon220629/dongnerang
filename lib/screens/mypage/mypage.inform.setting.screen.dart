import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../controller/private.setting.controller.dart';

class mypageInformSettingScreen extends GetView<PrivateSettingController> {
  const mypageInformSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PrivateSettingController());
    List keyword = [];
    List local = [];
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
                      // print("keyword : ${keyword}");
                      // print("local : ${local[0]}");
                      // if (controller.formKey.currentState!.validate()) {
                      //   try {
                      //     print("test");
                      //     await FirebaseFirestore.instance
                      //         .collection("users")
                      //         .doc(UserService.to.currentUser.value!.email)
                      //         .update(({
                      //       "age": ages.toJson(),
                      //       "keyword": keyword[0],
                      //       "local": local[0],
                      //       "gender" : gender,
                      //     }));
                      //     mypageCustomKeyword = []
                      //     EasyLoading.showSuccess("개인설정 추가 완료");
                      //     await FirebaseService.getCurrentUser();
                      //     Get.off(() => mainScreen());
                      //   } catch (e) {
                      //     logger.e(e);
                      //     EasyLoading.showSuccess("개인설정 추가 실패");
                      //   }
                      // }
                    }, child: Text("완료", style: TextStyle(color: Colors.black))),
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
                          mypageKeywordStateful(callback: (value) {
                            // print(value);
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

class mypageKeywordStateful extends StatefulWidget {
  late final Function callback;
  mypageKeywordStateful({required this.callback});

  @override
  State<mypageKeywordStateful> createState() => _mypageKeywordStateful();
}
class _mypageKeywordStateful extends State<mypageKeywordStateful> {
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
                                select_tags.add(myController.text);
                                print("select_tags : $select_tags");
                                setState(() {
                                  mypageCustomKeyword.add(myController.text);
                                  // print(mypageCustomKeyword);
                                  widget.callback(mypageCustomKeyword);
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
                                children: <Widget>[...generate_tags(mypageCustomKeyword)],
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

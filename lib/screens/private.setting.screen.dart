import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:get/get.dart';
import 'package:material_tag_editor/tag_editor.dart';

import '../constants/common.constants.dart';
import '../controller/private.setting.controller.dart';
import '../services/firebase.service.dart';
import '../services/user.service.dart';
import '../util/logger.service.dart';
import 'mainScreen.dart';

class privateSettingScreen extends GetView<PrivateSettingController> {
  double ages = 0;
  List keyword = [];
  List local = [];
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
                        Get.offAll(() => mainScreen());
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
                    AgeStatefulWidget(callback: (value) {
                      ageValue = value;
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

class TagKeywordStateful extends StatefulWidget {
  late final Function callback;
  TagKeywordStateful({required this.callback});

  @override
  State<TagKeywordStateful> createState() => _TagKeywordStatefulState();
}

class _TagKeywordStatefulState extends State<TagKeywordStateful> {
  final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();
  List tags = [];
  List sendTags = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 220),
      child: Column(
        children: [
          Text("지역 선택", style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 35,),
          Tags(
              key: _globalKey,
              itemCount: CustomData.length,
              itemBuilder: (index){

                for (int i = 0; i < CustomData.length; i++) {
                  tags.add(Item(title:CustomData[i]));
                };
                final Item currentItem = tags[index];
                return ItemTags(
                  index: index,
                  title: currentItem.title,
                  customData: currentItem.customData,
                  textStyle: TextStyle(fontSize: 14),
                  combine: ItemTagsCombine.withTextBefore,
                  onPressed: (i){
                    sendTags.add(i.title);
                    print("sendTags ; $sendTags");
                    if(sendTags.length >= 4){
                      print("3을 초과하였습니다. -> 4개지역 선택댐 ㄷㄷ..");
                    }
                    widget.callback(sendTags);
                  },
                );
              },
            ),
          ],
        )
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("연령대", style: TextStyle(fontWeight: FontWeight.bold),),
              Text("${_currentSliderValue.round().toString()}세"),
            ],
          ),
          Container(
            width: double.maxFinite,
            child: CupertinoSlider(
              min: 0,
              max: 100,
              value: _currentSliderValue,
              onChanged: (value) {
                setState(() {
                  _currentSliderValue = value;
                  widget.callback(_currentSliderValue);
                });
              },
            ),
          )
        ],
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
  List<String> _values = [];
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  _onDelete(index) {
    setState(() {
      _values.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 105),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            TagEditor(
              length: _values.length,
              controller: _textEditingController,
              focusNode: _focusNode,
              delimiters: [',', ' '],
              hasAddButton: true,
              resetTextOnSubmitted: true,
              // This is set to grey just to illustrate the `textStyle` prop
              textStyle: const TextStyle(color: Colors.grey),
              inputDecoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '키워드 추가',
              ),
              onSubmitted: (outstandingValue) {
                setState(() {
                  _values.add(outstandingValue);
                  widget.callback(_values);
                });
              },
              onTagChanged: (newValue) {
                setState(() {
                  _values.add(newValue);
                  // widget.callback(_values);
                });
              },
              tagBuilder: (context, index) => _Chip(
                index: index,
                label: _values[index],
                onDeleted: _onDelete,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[/\\]'))
              ],
            ),
            const Divider(),
          ],
        ),
      ),
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

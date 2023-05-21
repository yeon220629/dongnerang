import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.constants.dart';
import '../../constants/common.constants2.dart' as commonValue;
import '../../controller/private.setting.controller.dart';
import '../../services/firebase.service.dart';
import '../../services/user.service.dart';
import '../../util/logger.service.dart';
import '../mainScreenBar.dart';

class mypageInformSettingScreen extends GetView<PrivateSettingController> {
  // sendDatabase
  var photo = ''; var nick = ''; var gender = ''; var age;

  @override
  Widget build(BuildContext context) {
    Get.put(PrivateSettingController());
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('내 정보 수정', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.5,
                  color: Colors.black)),
              SizedBox(width: size.width / 5,),
              TextButton(
                  onPressed: () async {
                    if (controller.formKey.currentState!.validate()) {
                      try {
                        await FirebaseFirestore.instance
                          .collection("users")
                          .doc(UserService.to.currentUser.value!.email)
                          .update(({
                            "profileImage": photo == '' ? commonValue.commonConstant2.mypageInformPhotoSetting : photo,
                            "name": nick == '' ? commonValue.commonConstant2.mypageInformNickSetting : nick,
                            "gender": gender =='' ? commonValue.commonConstant2.mypageInformGender : gender,
                            "age" : age == null ? commonValue.commonConstant2.mypageInformAgeValue : age
                          }));
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
                  }, child: Text("완료", style: TextStyle(color: Colors.black))),
            ],
          )
        ],
        leading:  IconButton(
            onPressed: () {
              // print(commonValue.commonConstant2.mypageInformPhotoSetting);
              // print(commonValue.commonConstant2.mypageInformNickSetting);
              // print(commonValue.commonConstant2.mypageInformGender);
              // print(commonValue.commonConstant2.mypageInformAgeValue);
              photo = commonValue.commonConstant2.mypageInformPhotoSetting;
              gender = commonValue.commonConstant2.mypageInformGender;
              nick = commonValue.commonConstant2.mypageInformNickSetting;
              age = commonValue.commonConstant2.mypageInformAgeValue;
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
                      Container(
                        child : mypagePhotoProfileSetting(callback: (value){
                          // print("commonValue.commonConstant2.mypageInformPhotoSetting : ${commonValue.commonConstant2.mypageInformPhotoSetting}");
                          // print("photo : $value");
                          // commonValue.commonConstant2.mypageInformPhotoSetting = value;
                          photo = value;
                        },),
                        height: size.height / 4,
                      ),
                      Container(
                        child: mypageNickNameProfileSetting(callback: (value){
                          // print("commonValue.commonConstant2.mypageInformNickSetting : ${commonValue.commonConstant2.mypageInformNickSetting}");
                          // print("NICK : $value");
                          // commonValue.commonConstant2.mypageInformNickSetting = value;
                          nick = value;
                        },),
                        margin: EdgeInsets.fromLTRB(0, size.height / 6, 0, 0),
                      ),
                      Positioned(
                        top: size.height / 3,
                        child: Container(
                          child: genderChoiceWidget(callback: (value) {
                            // print("commonValue.commonConstant2.mypageInformGender : ${commonValue.commonConstant2.mypageInformGender}");
                            // print("GENDER : $value");
                            // commonValue.commonConstant2.mypageInformGender = value;
                            gender = value;
                          }),
                        )
                      ),
                      Positioned(
                        top: size.height / 2,
                        child: Container(
                          child: AgeStatefulWidget(callback: (value){
                            // commonValue.commonConstant2.mypageInformAgeValue = value;
                            print("value : $value");
                            age = value;
                          }
                        ),
                      ))
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
    if(commonValue.commonConstant2.mypageInformGender == '남성'){
      setState(() {
        man = true;
      });
    }else{
      setState(() {
        girl = true;
      });
    }

    isClick = [man, girl];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text("성별", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: EdgeInsets.only(top: 5),
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
            )
          ),
        )
      ],
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
  DateTime date = DateTime.utc(int.parse(commonValue.commonConstant2.mypageInformAgeValue['year']),int.parse(commonValue.commonConstant2.mypageInformAgeValue['month']),int.parse(commonValue.commonConstant2.mypageInformAgeValue['day']));

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
                      var year = commonValue.commonConstant2.mypageInformAgeValue['year'];
                      var month = commonValue.commonConstant2.mypageInformAgeValue['month'];
                      var day = commonValue.commonConstant2.mypageInformAgeValue['day'];
                      date = DateTime.now();
                      date = new DateTime(int.parse(year), int.parse(month), int.parse(day), date.hour, date.minute);
                      // date = new DateFormat("$year-$month-$day").format(date);
                      print("date : $date");
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
    var tmpAge = {};

    //생년월일 ui
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text("생년월일", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: size.height / 100,),
        Container(
          padding: EdgeInsets.only(right: size.width / 7.5),
          width: size.width / 1,
          height: 55,
          child: _DatePickerItem(
            children: <Widget>[
              CupertinoButton(
                  child: Container(
                    child: commonValue.commonConstant2.mypageInformAgeValue['year'] == ''
                        ? Text(
                      // '생년월일을 입력해주세요',
                      '${commonValue.commonConstant2.mypageInformAgeValue['year']}년 ${commonValue.commonConstant2.mypageInformAgeValue['month']}월 ${commonValue.commonConstant2.mypageInformAgeValue['day']}일',
                      style: const TextStyle(
                        color: AppColors.grey,
                      ),
                    )
                        : Text(
                      '${date.year}년 ${date.month}월 ${date.day}일',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    )
                  ),
                  onPressed: () => _showDialog(CupertinoDatePicker(
                    initialDateTime: date,
                    minimumYear: 1900,
                    maximumDate: DateTime.now(),
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() => date = newDate);
                      setState(() {
                        tmpAge['year'] = newDate.year.toString();
                        tmpAge['month'] = newDate.month.toString();
                        tmpAge['day'] = newDate.day.toString();
                        widget.callback(tmpAge);
                      });
                    },
                  ))
              )
            ],
          ))
      ],
    );
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

class mypagePhotoProfileSetting extends StatefulWidget {
  late final Function callback;
  mypagePhotoProfileSetting({required this.callback});

  @override
  State<mypagePhotoProfileSetting> createState() => _mypagePhotoProfileSettingState();
}

class _mypagePhotoProfileSettingState extends State<mypagePhotoProfileSetting> {
  bool imageDeleteCheck = false;
  XFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  final ImagePicker _picker = ImagePicker(); // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  List BoxData = [];
  String? photo = '';

  bool imageDelete = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: ListView(
          children: <Widget>[
            imageProfile(),
          ],
        )
    );
  }

  Widget imageProfile() {
    final Size size = MediaQuery.of(context).size;
    bool profileimagetype = true;

    if(!commonValue.commonConstant2.mypageInformPhotoSetting!.contains("http")){
      profileimagetype = false;
    }
    if(commonValue.commonConstant2.mypageInformPhotoSetting == ''){
      commonValue.commonConstant2.mypageInformPhotoSetting = "assets/images/default-profile.png";
    }
    return Center(
      child: Stack(
        children: <Widget>[
          InkWell(
              onTap: () {
                // 클릭시 모달 팝업을 띄워준다.
                showModalBottomSheet(

                    context: context,
                    builder: ((builder) => bottomSheet())
                );
              },
              child: ClipOval(
                child: SizedBox.fromSize(
                  size: Size.fromRadius(55),
                  child : imageDeleteCheck == true
                    ? Image.asset( "assets/images/default-profile.png", width: size.width / 2.2, fit: BoxFit.fill,)
                    : _imageFile == null
                      ? profileimagetype
                      ? CachedNetworkImage(imageUrl: commonValue.commonConstant2.mypageInformPhotoSetting!, width: size.width / 2.2, fit: BoxFit.fill)
                      // : Image.file(File(profileImage!), width: size.width / 2.2, fit: BoxFit.fill,)
                      : commonValue.commonConstant2.mypageInformPhotoSetting!.contains('assets/images/default-profile.png')
                        ? Image.asset( "assets/images/default-profile.png", width: size.width / 2.2, fit: BoxFit.fill,)
                        : Image.file(File(commonValue.commonConstant2.mypageInformPhotoSetting!), width: size.width / 2.2, fit: BoxFit.fill,)
                      : Image.file(File(_imageFile!.path), width: size.width / 2.2, fit: BoxFit.fill,)
              )
            )
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child:CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.white,
                child:
                Icon(
                  Icons.camera_alt,
                  color: AppColors.grey,
                  size: 17,
                ),
              ))
        ],
      ),
    );
  }

  // 카메라 아이콘 클릭시 띄울 모달 팝업
  Widget bottomSheet() {
    final Size size = MediaQuery.of(context).size;
    return Container(
        height: size.height / 7,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20
        ),
        child: Column(
          children: <Widget>[
            Container(
              child: TextButton.icon(
                icon: Icon(null),
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                  ImageSource.values;
                  Navigator.pop(context);
                },
                label: Text('앨범에서 선택', style: TextStyle(fontSize: 20)),
              ),
            ),
            Container(
              width: size.width,
              height: 1,
              color: AppColors.grey,
            ),
            Container(
              child: TextButton(
                onPressed: () async {
                  // takePhoto("assets/images/default-profile.png");
                  // File file = File('assets/images/default-profile.png');
                  final XFile f = XFile('assets/images/default-profile.png');
                  setState(() {
                    _imageFile = null;
                    widget.callback(f.path);
                    imageDeleteCheck = true;
                    Navigator.pop(context);
                  });
                },
                  child: Text('프로필 사진 삭제', style: TextStyle(
                      fontSize: size.width / 20, color: AppColors.red
                  ),)
              )
            )
          ],
        )
    );
  }


  takePhoto(ImageSource source) async {
    final XFile? file = await ImagePicker().pickImage( source: source);
    setState(() {
      _imageFile = file;
      widget.callback(file!.path);
    });
  }
}

class mypageNickNameProfileSetting extends StatefulWidget {
  late final Function callback;
  mypageNickNameProfileSetting({required this.callback});

  @override
  State<mypageNickNameProfileSetting> createState() => _mypageNickNameProfileSettingState();
}

class _mypageNickNameProfileSettingState extends State<mypageNickNameProfileSetting> {
  String? nick = '';

  @override
  Widget build(BuildContext context) {
    return nameTextField();
  }

  Widget nameTextField() {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 5,),
        Container(
          width: size.width,
          height: size.height,
          child: TextFormField(
            maxLength: 20,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    // width: 1,
                    color: AppColors.grey,
                  ),
                ),
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
                // labelText: '${userName}',
                hintText: '${commonValue.commonConstant2.mypageInformNickSetting}'
            ),
            // onSaved: ,
            onChanged: (value){
              setState(() {
                widget.callback(value);
              });
            },
          ),
        )
      ],
    );
  }
}


// class TagKeywordStateful extends StatefulWidget {
//   late final Function callback;
//   TagKeywordStateful({required this.callback});
//
//   @override
//   State<TagKeywordStateful> createState() => _TagKeywordStatefulState();
// }
//
// class _TagKeywordStatefulState extends State<TagKeywordStateful> {
//
//   final List tags = [];
//   final List select_tags = [];
//   List selected_tags = [];
//   bool selectCheck = false;
//
//   @override
//   Widget build(BuildContext context) {
//
//     final Size size = MediaQuery.of(context).size;
//
//     return Padding(
//         padding: EdgeInsets.symmetric(
//             vertical: size.height / 12.5
//         ),
//         child: Column(
//           children: [
//             SizedBox(height: size.height / 2.85,),
//             Row(
//               children: [
//                 Container(
//                   alignment: Alignment.topLeft,
//                   child: Text("지역선택", style: TextStyle(fontWeight: FontWeight.bold),),
//                 )
//               ],
//             ),
//             SizedBox(height: 5,),
//             Container(
//               child: Wrap(
//                 alignment: WrapAlignment.spaceBetween,
//                 spacing: size.width / 20, runSpacing: 2.0, children: <Widget>[...generate_tags(CustomData)], ),
//             ),
//             Text("   * 지역 선택은 최대 3개까지 가능 합니다.", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey),),
//           ],
//         )
//     );
//   }
//
//   generate_tags(value) {
//     return value.map((tag) => get_chip(tag)).toList();
//   }
//   get_chip(name) {
//     for(int i =0; i < PrivateLocalData.length; i++){
//       if(PrivateLocalData.length == 3){
//         if(name == PrivateLocalData[0] || name == PrivateLocalData[1] || name == PrivateLocalData[2]){
//           selectCheck = false;
//         }else{
//           selectCheck = true;
//         }
//       }else if(PrivateLocalData.length == 2){
//         if(name == PrivateLocalData[0] || name == PrivateLocalData[1]){
//           selectCheck = false;
//         }else{
//           selectCheck = true;
//         }
//       }else{
//         if(name == PrivateLocalData[0]){
//           selectCheck = false;
//         }else{
//           selectCheck = true;
//         }
//       }
//     }
//     return FilterChip(
//       selected: selected_tags.contains(name),
//       selectedColor: AppColors.primary,
//       // disabledColor: Colors.blue.shade400,
//       avatar: (name == "강남") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/GANGNAM.PNG')) :
//       (name == "강동") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/GANGDONG.PNG')) :
//       (name == "강북") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/GANGBUK.PNG')) :
//       (name == "강서") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/GANGSEO.PNG')) :
//       (name == "관악") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/GWANAK.PNG')) :
//       (name == "광진") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/GWANGZIN.PNG')) :
//       (name == "구로") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/GOORO.PNG')) :
//       (name == "금천") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/GEUAMCHEOUN.PNG')) :
//       (name == "노원") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/NOWON.PNG')) :
//       (name == "도봉") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/DOBONG.PNG')) :
//       (name == "중구") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/JUNGGU.PNG')) :
//       (name == "동작") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/DONGJAK.PNG')) :
//       (name == "마포") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/MAPO.PNG')) :
//       (name == "서초") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/SEOCHO.PNG')) :
//       (name == "중랑") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/JUNGNANG.PNG')) :
//       (name == "종로") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/JONGRO.PNG')) :
//       (name == "성동") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/SEONGDONG.PNG')) :
//       (name == "성북") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/SEONGBUK.PNG')) :
//       (name == "송파") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/SONGPA.PNG')) :
//       (name == "양천") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/YANGCHEON.PNG')) :
//       (name == "용산") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/YONGSAN.PNG')) :
//       (name == "은평") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/EUNPYENG.PNG')) :
//       (name == "동대문") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/DONGDAEMUN.PNG')) :
//       (name == "영등포") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/YEONGDEUNGPO.PNG')) :
//       (name == "서대문") ?
//       CircleAvatar(backgroundImage: AssetImage('assets/images/SEODAEMUN.PNG')) :
//       SizedBox(),
//       backgroundColor: Colors.white,
//       shape: StadiumBorder(side: selected_tags.contains(name)? BorderSide(color: AppColors.white) : BorderSide(color: AppColors.grey)),
//       label: selectCheck == false
//           ? name == "중구"
//             ? Text("${name}", style: TextStyle(color:AppColors.primary, fontWeight: FontWeight.bold))
//             : Text("${name}구", style: TextStyle(color:AppColors.primary, fontWeight: FontWeight.bold)
//       )
//           : name == "중구"
//             ? Text("${name}")
//             : Text("${name}구"
//       ),
//       labelStyle: TextStyle(
//         color: selected_tags.contains(name)? Colors.white : Colors.black,
//       ),
//       onSelected: (value) {
//         if (select_tags.length > 2) {
//           value = false;
//         }
//         if (value == true) {
//           select_tags.add(name);
//         }
//         if (value == false) {
//           select_tags.remove(name);
//         }
//         setState(() {
//           selected_tags = select_tags;
//           widget.callback(selected_tags);
//         });
//       },
//     );
//   }
// }



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

import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../controller/private.setting.controller.dart';
import '../../services/firebase.service.dart';
import '../../services/user.service.dart';
import '../../util/logger.service.dart';
import '../mainScreenBar.dart';

class mypageInformSettingScreen extends GetView<PrivateSettingController> {
  String profilePhotoSetting = '';
  String profilenickSetting = '';
  List profileKeyword = [];
  List profilelocal = [];

  @override
  Widget build(BuildContext context) {
    Get.put(PrivateSettingController());
    print(PrivateLocalData);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('프로필 수정', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.5,
                    color: Colors.black)),
                SizedBox(width: 100,),
                TextButton(
                    onPressed: () async {
                      // print("profilePhotoSetting : $profilePhotoSetting");
                      // print("profilenickSetting : $profilenickSetting");
                      print("profileKeyword : $profileKeyword");
                      print("profilelocal : ${profilelocal}");
                      print("PrivateLocalData : $PrivateLocalData");
                      print("profilelocal[0] : ${profilelocal}");
                      if (controller.formKey.currentState!.validate()) {
                        try {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(UserService.to.currentUser.value!.email)
                              .update(({
                            "profileImage":profilePhotoSetting == ''
                                            ? profileImage!
                                            : profilePhotoSetting,
                            "name":profilenickSetting == ''
                                      ? userName
                                      : profilenickSetting,
                            "keyword": profileKeyword[0],
                            "local": profilelocal.isEmpty
                                        ? PrivateLocalData
                                        : profilelocal[0]
                          }));
                          profilePhotoSetting = '';
                          profilenickSetting = '';
                          profileKeyword = [];
                          profilelocal = [];
                          mypageCustomKeyword = [];
                          PrivateLocalData = [];

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
                          Container(
                            child : mypagePhotoProfileSetting(callback: (value){
                              profilePhotoSetting = value;
                              // print("mypageProfileSetting : $profilePhotoSetting");
                            },),
                            height: size.height / 4,
                          ),
                          Container(

                            child: mypageNickNameProfileSetting(callback: (value){
                              profilenickSetting = value;
                              // print("mypageNickNameProfileSetting : $profilenickSetting");
                            },),
                            margin: EdgeInsets.fromLTRB(0, size.height / 6, 0, 0),
                          ),
                          mypageKeywordStateful(callback: (value) {
                            // print("mypageKeywordStateful : $value");
                            profileKeyword.add(value);
                          }),
                          TagKeywordStateful(callback: (value) {
                            print("TagKeywordStateful : $value");
                            profilelocal.add(value);
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
  final List tags = [];
  final List selected_tags = [];
  final List select_tags = [];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.30;

    return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height / 3.5),
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
                              onPressed: () {
                                select_tags.add(myController.text);
                                // print("select_tags : $select_tags");
                                setState(() {
                                  mypageCustomKeyword.add(myController.text);
                                  // print(mypageCustomKeyword);
                                  widget.callback(mypageCustomKeyword);
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
                              ),
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
                          Container(
                            width: categoryHeight * 1.7,
                            // margin: const EdgeInsets.only(right: 5),
                            height: categoryHeight - 180,
                            child: Center(
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                // padding: EdgeInsets.all(10),
                                children: <Widget>[Wrap(children: [...generate_tags(mypageCustomKeyword)],spacing: 2.0,)],
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
    widget.callback(value);
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
            mypageCustomKeyword.remove(name);
          });
        },
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

  final List tags = [];
  final List select_tags = [];
  List selected_tags = [];
  bool selectCheck = false;

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height / 2.25),
        child: Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Wrap( spacing: 4.0, runSpacing: 2.0, children: <Widget>[...generate_tags(CustomData)], ),
            ),
            Text("   * 지역 선택은 최대 3개까지 가능 합니다.", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey),),
          ],
        )
    );
  }

  generate_tags(value) {
    // for(var v in value){
    //   for(var a in PrivateLocalData){
    //     if(v == a){
    //       selectCheck = false;
    //       print(selectCheck);
    //     }else{
    //       selectCheck = true;
    //     }
    //   }
    // }
    return value.map((tag) => get_chip(tag)).toList();
  }
  get_chip(name) {
    for(int i =0; i < PrivateLocalData.length; i++){
      if(PrivateLocalData.length == 3){
        if(name == PrivateLocalData[0] || name == PrivateLocalData[1] || name == PrivateLocalData[2]){
          selectCheck = false;
        }else{
          selectCheck = true;
        }
      }else if(PrivateLocalData.length == 2){
        if(name == PrivateLocalData[0] || name == PrivateLocalData[1]){
          selectCheck = false;
        }else{
          selectCheck = true;
        }
      }else{
        if(name == PrivateLocalData[0]){
          selectCheck = false;
        }else{
          selectCheck = true;
        }
      }
    }
    return FilterChip(
      selected: selected_tags.contains(name),
      selectedColor: AppColors.primary,
      // disabledColor: Colors.blue.shade400,
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
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: selected_tags.contains(name)? BorderSide(color: AppColors.white) : BorderSide(color: AppColors.grey)),
      label: selectCheck == false
              ? Text("${name}", style: TextStyle(
                  color:AppColors.primary, fontWeight: FontWeight.bold),
              )
              : Text("${name}"
      ),
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

class mypagePhotoProfileSetting extends StatefulWidget {
  late final Function callback;
  mypagePhotoProfileSetting({required this.callback});

  @override
  State<mypagePhotoProfileSetting> createState() => _mypagePhotoProfileSettingState();
}

class _mypagePhotoProfileSettingState extends State<mypagePhotoProfileSetting> {
  XFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  final ImagePicker _picker = ImagePicker(); // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  List BoxData = [];
  String? photo = '';

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

    if(!profileImage!.contains("http")){
      profileimagetype = false;
    }

    return Center(
      child: Stack(
        children: <Widget>[
          InkWell(
        onTap: () {
          // 클릭시 모달 팝업을 띄워준다.
          showModalBottomSheet(context: context, builder: ((builder) => bottomSheet()));
        },
            child: ClipOval(
            child: SizedBox.fromSize(
            size: Size.fromRadius(55),
                // borderRadius: BorderRadius.circular(125),
                // clipBehavior: Clip,
            child: _imageFile == null
                // ? Image.asset("assets/images/default-profile.png", fit: BoxFit.contain,)
                    ? profileimagetype
                    ? CachedNetworkImage(imageUrl: profileImage!, width: size.width / 2.2, fit: BoxFit.contain)
                    : Image.file(File(profileImage!), width: size.width / 2.2, fit: BoxFit.fill,)
                // : CachedNetworkImage(imageUrl: profileImage!)
                // : Image.network(_imageFile!.path)
                    :Image.file(File(_imageFile!.path), width: size.width / 2.2, fit: BoxFit.fill,))
            )
          ),
          // SizedBox(height: 660,),
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
        height: 100,
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
                },
                label: Text('앨범에서 선택', style: TextStyle(fontSize: 20),),
              ),
            ),
            Container(
              width: size.width,
              height: 1.5,
              color: AppColors.grey,
            ),
            Container(
              child: TextButton.icon(
                icon: Icon(null),
                onPressed: () async {
                  // takePhoto("assets/images/default-profile.png");
                  setState(() {
                    _imageFile = null;
                  });
                },
                label: Text('프로필 사진 삭제', style: TextStyle(
                    fontSize: 20, color: AppColors.red
                ),),
              ),
            )
          ],
        )
    );
  }


  takePhoto(ImageSource source) async {
    // Pick an image
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final XFile? file = await ImagePicker().pickImage( source: source);
    // print("file : ${file}");
    // print("filepath : ${file?.path.runtimeType}");
    // print("source : ${source}");
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
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 5,),
        TextFormField(
          maxLength: 8,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
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
              hintText: '${userName}'
          ),
          // onSaved: ,
          onChanged: (value){
            setState(() {
              widget.callback(value);
            });
          },
        )
      ],
    );
  }
}



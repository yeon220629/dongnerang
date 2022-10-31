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
import '../../widgets/user_profile_image.widget.dart';
import '../mainScreenBar.dart';

class mypageInformSettingScreen extends GetView<PrivateSettingController> {
  String profilePhotoSetting = '';
  String profilenickSetting = '';
  List profileKeyword = [];
  List profilelocal = [];

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
                Text('프로필 수정', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.5,
                    color: Colors.black)),
                SizedBox(width: 100,),
                TextButton(
                    onPressed: () async {
                      // print("profilePhotoSetting : $profilePhotoSetting");
                      // print("profilenickSetting : $profilenickSetting");
                      // print("profileKeyword : $profileKeyword");
                      // print("profilelocal : ${profilelocal}");
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
                            // print("TagKeywordStateful : $value");
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
  List tags = [];
  List selected_tags = [];
  List select_tags = [];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.30;

    return Padding(
        padding: EdgeInsets.symmetric(vertical: size.height / 3.7),
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
                                // print("select_tags : $select_tags");
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
    return Container(
      child: Chip(
        backgroundColor: AppColors.blue,
        labelStyle: TextStyle(color: AppColors.white),
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
            // Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold)),
            // SizedBox(height: 5),
            // nameTextField(),
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
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.black,
                  width: 2,
                ),
              ),

              labelText: '${userName}',
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

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/colors.constants.dart';
import '../../services/firebase.service.dart';
import '../../services/user.service.dart';
import '../../util/FileStorage.dart';
import '../../util/logger.service.dart';
import '../../widgets/app_button.widget.dart';
import '../mainScreenBar.dart';

class commnunityInsert extends StatefulWidget {
  const commnunityInsert({Key? key}) : super(key: key);

  @override
  State<commnunityInsert> createState() => _commnunityInsertState();
}

class _commnunityInsertState extends State<commnunityInsert> {
  static List<String> list = <String>['전체', '카테고리1', '카테고리2', '카테고리3'];
  FileStorage _fileStoarge = Get.put(FileStorage());

  XFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  List<Widget> _createChildren = [];
  List<String> communityPhoto = [];
  String dropdownValue = list.first;

  TextEditingController titleController = TextEditingController();
  TextEditingController mainTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.black,
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text('글쓰기', style: TextStyle(color: AppColors.black),),
        actions: [
          TextButton(onPressed: () async {
            // print("_createChildren : ${_createChildren}");
            print("communityPhoto : ${communityPhoto}");
            var insertMenu = '';
            var communityCount;

            dropdownValue == '카테고리1'
                ? insertMenu = 'category_1'
                : dropdownValue == '카테고리2'
                  ? insertMenu = 'category_2'
                  : dropdownValue == '카테고리3'
                    ? insertMenu = 'category_3'
                    : print("check ");
                    // : showAlert();
            await FirebaseService.saveCommunity(insertMenu).then((value) => communityCount=value);
            // print("${UserService.to.currentUser.value!.email}_${communityCount.toString()}");
            try {
              await FirebaseFirestore.instance
                  .collection("community")
                  .doc(insertMenu)
                  .update(({
                // UserService.to.currentUser.value!.email+"_"+writeCount.toString() : {
                "${insertMenu}_${UserService.to.currentUser.value!.email.split("@")[0]}_${communityCount.toString()}" : {
                  "imageList": communityPhoto,
                  "title": titleController.text,
                  "mainText": mainTextController.text,
                  "userName": UserService.to.currentUser.value!.name,
                  "userEmail" : UserService.to.currentUser.value!.email
                }
              }));
              EasyLoading.showSuccess("글쓰기 완료");
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (BuildContext context) =>
                      mainScreen()), (route) => false);
            } catch (e) {
              logger.e(e);
              EasyLoading.showSuccess("카테고리를 선택 해 주세요");
            }
          }, child: Text("완료", style: TextStyle(color: AppColors.black),))
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              DropdownButton<String>(
                value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: AppColors.black),
                  underline: Container(
                    height: 2,
                    color: AppColors.black,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              ),
              Container(
                color: AppColors.primary,
                height: size.height / 16,
                width: size.width / 1.05,
                child: Text("안내 중고거래 관련, 명예훼손, 광고/홍보 목적의 글은 올리실 수 없어. 동네생활 운영정책"),
              ),
              Container(
                decoration: BoxDecoration(border: Border.all(width: 1, color: AppColors.black)),
                height: size.height / 6,
                width: size.width,
                child: Row(
                  children: _createChildren,
                ),
              ),
              TextFormField(
                maxLines: null,
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '제목',
                ),
              ),
              TextFormField(
                maxLines: null,
                controller: mainTextController,
                decoration: InputDecoration(
                  hintText: '본문',
                ),
              ),
              Container(
                child: Row(
                  children: [
                    TextButton(onPressed: (){
                      takePhoto(ImageSource.gallery);

                    }, child: Text("사진")),
                    TextButton(onPressed: (){
                    }, child: Text("장소"))
                  ],
                ),
              ),
              SizedBox(height: size.height - 200,),
            ],
          ),
        ),
      ),
    );
  }
  //TextForm 필드로 사진 옮기기
  takePhoto(ImageSource source) async {
    final XFile? file = await ImagePicker().pickImage( source: source);

    setState(() {
        _imageFile = file;
        // communityPhoto.add(_imageFile!.path);
        _createChildren.add(
            Image.file(File(_imageFile!.path), width: 100 / 2.2, fit: BoxFit.fill,)
        );
    });
    await _fileStoarge.uploadFile(
        _imageFile!.path,
        'userCommunityImage'
    ).then((value) {
      // userViewModelController.user.value.profileImageReference = value;
      print("value : $value");
      communityPhoto.add(value);
    });
  }

  showAlert(){
    return showDialog<void>(
      //다이얼로그 위젯 소환
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경고'),
          content: SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                Text('카테고리를 선택 해 주세요'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // TextButton(
            //   child: Text('취소'),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),
          ],
        );
      },
    );
  }
}

import 'package:dongnerang/constants/common.constants2.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../constants/colors.constants.dart';

class noticemainAlarmpage extends StatefulWidget {
  List keywordList; List localList; List selectLocal;
  noticemainAlarmpage( this.keywordList, this.localList, this.selectLocal);

  @override
  State<noticemainAlarmpage> createState() => _noticemainAlarmpageState();
}

class _noticemainAlarmpageState extends State<noticemainAlarmpage> {
  TextEditingController addKeyword = new TextEditingController();
  String? userEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fnRestData() async {
    commonConstant2.keywordList = [];
    commonConstant2.localList = [];
    commonConstant2.selectLocal = [];
    FirebaseService.getUserLocalData(userEmail!, 'keyword').then((value) {
      value.forEach((element) {
        commonConstant2.keywordList.add(element);
      });
    });
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value) {
      value.forEach((element) {
        commonConstant2.localList.add(element);
        commonConstant2.selectLocal.add(element);
      });
      commonConstant2.localList.add('서울시');
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    widget.localList.remove('서울시');

    return WillPopScope(
      onWillPop: () async {
        fnRestData();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            // color: AppColors.primary,
          ),
          centerTitle: true,
          title: const Text('키워드 설정', style: TextStyle( color: AppColors.black),),
          actions: [
            TextButton(
                onPressed: (){
                  // print("widgetkeyword : ${widget.keywordList}");
                  // print("local : ${widget.selectLocal}");
                  FirebaseService.savePrivacyProfile(userEmail!, widget.keywordList, 'keyword');
                  FirebaseService.savePrivacyProfile(userEmail!, widget.selectLocal, 'alramlocal');
                  EasyLoading.showSuccess("알람 키워드 변경 되었습니다.");
                  Navigator.pop(context);
                },
                child: Text("완료", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),)
            ),
          ],
          leading:  IconButton(
            onPressed: () {
              fnRestData();
              Navigator.pop(context); //뒤로가기
            },
            color: Colors.black,
            icon: Icon(Icons.arrow_back)),
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 40),
              child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("관심 키워드" , style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 5,),
                    Container(
                      width: size.width / 1.25,
                      height: size.height / 15,
                      child: TextField(
                        onSubmitted: (value) {
                          if(widget.keywordList.length > 19){
                            EasyLoading.showError("키워드는 20개 이상은 불가 합니다.");
                            return;
                          }else if(addKeyword.text == ''){
                            EasyLoading.showError("공백은 등록 불가 합니다.");
                            return;
                          }
                          setState(() {
                            widget.keywordList.add(addKeyword.text);
                          });
                          addKeyword.text = '';
                        },
                        controller: addKeyword,
                        decoration: InputDecoration(
                          hintText: '키워드를 입력해주세요 ex) 예술, 모집',
                          hintStyle: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          suffixIcon: TextButton(
                            onPressed: (){
                              if(widget.keywordList.length > 19){
                                EasyLoading.showError("키워드는 20개 이상은 불가 합니다.");
                                return;
                              }else if(addKeyword.text == ''){
                                EasyLoading.showError("공백은 등록 불가 합니다.");
                                return;
                              }
                              setState(() {
                                widget.keywordList.add(addKeyword.text);
                              });
                              addKeyword.text = '';
                            },
                            child: Text("확인", style: TextStyle(color: AppColors.grey),)
                          )
                        ),
                      ),
                    ),
                    SizedBox(height: size.height / 30,),
                    Text("나의 키워드 (${widget.keywordList.length}/20)",
                      style: TextStyle(
                      fontWeight: FontWeight.bold
                      ),
                    ),
                    Wrap(
                      children: <Widget>[...generate_tags(widget.keywordList)],
                    ),
                    SizedBox(height: size.height / 30,),
                    Text("알림동네", style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        children: <Widget>[...localgenerate_tags(widget.localList)],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ),
        ),
      )
    );
  }
  // keyword 삭제
  generate_tags(value) {
    return value.map( (tag) => get_chip(tag) ).toList();
  }
  get_chip(name) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0,0,5,0),
      child: Chip(
        backgroundColor: AppColors.white,
        side: BorderSide(width: 1, color: AppColors.grey),
        labelStyle: TextStyle(color: Colors.black),
        deleteIcon: Icon( Icons.close,  size: 15, ),
        deleteIconColor: Colors.black,
        label: Text('${name}'),
        onDeleted: () {
          setState(() { widget.keywordList.remove(name); });
        },
      )
    );
  }
  localgenerate_tags(value) {
    return value.map( (tag) => localget_chip(tag) ).toList();
  }
  localget_chip(name) {
    // _value = name
    return Padding(
      padding: EdgeInsets.all(2),
      child: ChoiceChip(
        padding: EdgeInsets.all(8),
        label: Text('${name}', style: TextStyle(color: AppColors.white),),
        selected: widget.selectLocal.contains(name),
        // selected: _value != name,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.white,
        // backgroundColor: AppColors.primary,
        onSelected: (bool selec){
          setState(() {
            setState(() {
              // remove
              if(!selec){
                widget.selectLocal.remove(name);
              }else{
                widget.selectLocal.add(name);
              }
            });
          });
        },
      )
    );
  }
}

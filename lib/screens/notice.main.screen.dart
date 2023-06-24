import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/constants/common.constants2.dart';
import 'package:dongnerang/screens/setting/notice.main.screen.alarm.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import '../constants/colors.constants.dart';
import '../constants/common.constants.dart';
import '../services/firebase.service.dart';

class noticemainpage extends StatefulWidget {
  const noticemainpage({super.key});

  @override
  State<noticemainpage> createState() => _noticemainpageState();
}

class _noticemainpageState extends State<noticemainpage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  double topContainer = 0;

  String td = getToday();
  String? userEmail = FirebaseAuth.instance.currentUser?.email;

  Future<void> getNoticeData(td) async {
    final Size size = MediaQuery.of(context).size;
    DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore.instance.collection("notice").doc(td);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    late  Map<String, dynamic>? valueDoc = documentSnapshot.data();

    List<dynamic> noticeData = [];

    valueDoc?.forEach((key, value) {
      noticeData.add(value);
    });
    if(noticeData.length != 0){
      commonConstant2.noticeDataWidget = [];
    }
    for(var ntData in noticeData){
      commonConstant2.noticeDataWidget.add( GestureDetector(
      child: Container(
        width: size.width ,
        height: size.height / 7.5,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), //모서리를 둥글게
          border: Border.all(color: Colors.black, width: 1)), //테두리
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Image.asset('assets/images/alarm.png'),
                  Column(
                    children: [
                      Text(
                        '${ntData[0]}',
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        '${ntData[1]}',
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        )
      ));
    }
    setState(() {
      commonConstant2.noticeItemsData = commonConstant2.noticeDataWidget;
    });
  }
  // 키워드 알림
  Future<void>getKeywordData(String? userEmail)async {
    final Size size = MediaQuery.of(context).size;
    DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore.instance.collection("keywordnotification").doc(userEmail);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    late  Map<String, dynamic>? valueDoc = documentSnapshot.data();
    List<dynamic> userData = [];

    valueDoc?.forEach((key, value) {
      userData.add(value);
    });
    userData.sort((a,b) {
      var adate = a['registrationdate']; //before -> var adate = a.expiry;
      var bdate = b['registrationdate']; //before -> var bdate = b.expiry;
      return bdate.compareTo(adate); //to get the order other way just switch `adate & bdate`
    });

    if(userData.length != 0){
      commonConstant2.userDataWidget = [];
    }

    for(var userKeyword in userData){
      commonConstant2.colorindex = fnSeoulCnterCheck(userKeyword['center_name']);
      commonConstant2.userDataWidget.add( GestureDetector(
        onTap: () async{
          final Uri url = Uri.parse('${userKeyword["link"]}');
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
            url, userKeyword["body"], userKeyword['center_name'], userKeyword['registrationdate'], 0
          )));
        },
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 1)), //테두리
          width: size.width,
          height: 90,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0,0,8,0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '${userKeyword['body']}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                    maxLines: 2,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: commonConstant2.colorindex == 1
                              ? Color(0xff5496D2)
                              : commonConstant2.colorindex == 0
                              ? Color(0xff3CC181)
                              : commonConstant2.colorindex == 2
                              ? AppColors.darkgreen
                              : commonConstant2.colorindex == 3
                              ? AppColors.primary
                              : commonConstant2.colorindex == 4
                              ? AppColors.orange
                              : commonConstant2.colorindex == 5
                              ? AppColors.red
                              : commonConstant2.colorindex == 7
                              ? AppColors.primary
                              : Color(0xffEE6D01),
                          ),
                          child: Text(
                            ' ${userKeyword['center_name']} ',
                            style: const TextStyle(fontSize: 12, color: AppColors.white, fontWeight: FontWeight.w500),
                            textDirection: ui.TextDirection.ltr,
                          ),
                        ),
                        SizedBox(width: size.width / 20,),
                        Container(
                          child: Text(
                            '등록일 | ${userKeyword['registrationdate']}',
                            style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w500),
                            textDirection: ui.TextDirection.ltr,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ),
          )
        )
      ));
    }
    setState(() {
      commonConstant2.userItemsData = commonConstant2.userDataWidget;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getKeywordData(userEmail);
      getNoticeData(td);
    });
    _tabController = TabController(length: 2, vsync: this);
    controllers.addListener(() {
      double value = controllers.offset/119;
      setState(() {
        topContainer = value;
      });
    });
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

    // local exist Check
    FirebaseService.getUserKeyExist(userEmail!, 'alramlocal').then((value) {
      if(value == true){
        commonConstant2.selectLocal = [];
        FirebaseService.getUserLocalData(userEmail!, 'alramlocal').then((value) {
          value.forEach((element) {
            commonConstant2.selectLocal.add(element);
          });
        });
      }
    });
    commonConstant2().fnResetValue();
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          // color: AppColors.primary,
        ),
        centerTitle: true,
        title: const Text('알림', style: TextStyle( color: AppColors.black),),
        bottom: TabBar(
          labelColor: AppColors.primary,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, ),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: AppColors.black,
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: const <Widget>[
            Tab( text: '키워드 알림', ),
            Tab( text: '동네랑 알림', ),
          ],
          onTap: (value) {
            if(value == 0){
              setState(() {
                getKeywordData(userEmail);
              });
            }else if(value == 1){
              setState(() {
                getNoticeData(td);
              });
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
            SizedBox(
              height: size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: (){
                        Get.to(() => noticemainAlarmpage(commonConstant2.keywordList, commonConstant2.localList,commonConstant2.selectLocal));
                        // Navigator.push(
                        //   context, MaterialPageRoute(builder: (context) => noticemainAlarmpage(),),);
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        width: size.width / 4,
                        height: size.height / 23,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: AppColors.ligthGrey
                        ),
                        // child: Padding(
                        //   padding: const EdgeInsets.symmetric(2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon(Icons.settings, color: AppColors.white),
                              Text("키워드 설정", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black
                              ),)
                            ],
                          ),
                        // )
                      )
                  ),
                  //키워드 알림 push 메시지 쌓이는 코드
                  Expanded(
                    child: commonConstant2.userItemsData.length == 0
                      ? Container(
                        alignment: Alignment.center,
                        child: Text('받은 알림이 없어요. \n 키워드를 등록하고 알림을 받아보세요.\n\n\n\n\n',style: TextStyle(
                          fontSize: 15
                        ), textAlign:TextAlign.center
                      ),
                    )
                      :ListView.builder(
                        itemCount: commonConstant2.userItemsData.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (c, i){
                          double scale = 1.0;
                          if (topContainer > 0.5){
                            scale = i + 0.5 - topContainer;
                            if (scale < 0 ) { scale = 0;}
                            else if (scale > 1) { scale = 1; }
                          }
                          return Align(
                                  heightFactor: 1.1,
                                  alignment: Alignment.topCenter,
                                  // child: userItemsData[i],
                                  child : commonConstant2.userItemsData[i]
                          );
                        }
                    )
                  ),
                ],
              ),
            ),

              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: commonConstant2.noticeItemsData.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (c, i){
                        double scale = 1.0;
                        if (topContainer > 0.5){
                          scale = i + 0.5 - topContainer;
                          if (scale < 0 ) { scale = 0;}
                          else if (scale > 1) { scale = 1; }
                        }
                        return Align(
                              heightFactor: 0.98,
                              alignment: Alignment.topCenter,
                              child: commonConstant2.noticeItemsData[i],
                        );
                      }
                    )
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

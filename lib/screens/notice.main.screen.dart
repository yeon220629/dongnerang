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
  int colorindex = 0;

  String td = getToday();
  String? userEmail = FirebaseAuth.instance.currentUser?.email;

  List<Widget> noticeDataWidget = [];
  List<Widget> noticeItemsData = [];
  List<Widget> userDataWidget = [];
  List<Widget> userItemsData = [];

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
      noticeDataWidget = [];
    }
    for(var ntData in noticeData){
      noticeDataWidget.add( GestureDetector(
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
      noticeItemsData = noticeDataWidget;
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
    if(userData.length != 0){
      userDataWidget = [];
    }
    for(var userKeyword in userData){
      colorindex = fnSeoulCnterCheck(userKeyword['center_name']);
      // var date = DateTime.fromMillisecondsSinceEpoch(userKeyword['registrationdate']);
      userDataWidget.add( GestureDetector(
        onTap: () async{
          final Uri url = Uri.parse('${userKeyword["link"]}');
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
            url, userKeyword["body"], userKeyword['center_name'], userKeyword['registrationdate'], 0
          )));
        },
        child: SizedBox(
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
                  // const SizedBox(
                  //   height: 15,
                  // ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: colorindex == 1
                              ? Color(0xff5496D2)
                              : colorindex == 0
                              ? Color(0xff3CC181)
                              : colorindex == 2
                              ? AppColors.darkgreen
                              : colorindex == 3
                              ? AppColors.primary
                              : colorindex == 4
                              ? AppColors.orange
                              : colorindex == 5
                              ? AppColors.red
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
      userItemsData = userDataWidget;
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
    FirebaseService.getUserKeyExist(userEmail!).then((value) {
      if(value == true){
        commonConstant2.selectLocal = [];
        FirebaseService.getUserLocalData(userEmail!, 'alramlocal').then((value) {
          value.forEach((element) {
            commonConstant2.selectLocal.add(element);
          });
        });
      }
    });
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
          Center(
            child: SizedBox(
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
                  Expanded(
                    child: userItemsData.length == 0
                      ? Lottie.asset( 'assets/lottie/searchdata.json', width: size.width, height: size.height / 10, fit: BoxFit.contain, )
                      :ListView.builder(
                        itemCount: userItemsData.length,
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
                                  child : userItemsData[i]
                          );
                        }
                    )
                  ),
                ],
              ),
            ),
          ),

              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: noticeItemsData.length,
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
                              child: noticeItemsData[i],
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

import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/seoul.url.screen.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../constants/colors.constants.dart';
import '../constants/common.constants.dart';
import 'package:dongnerang/screens/search.screen.dart';
import '../services/firebase.service.dart';
import 'introduce.dart';
import 'notice.main.screen.dart';


class freeComponent_viewpage extends StatefulWidget {
  const freeComponent_viewpage({Key? key}) : super(key: key);

  @override
  State<freeComponent_viewpage> createState() => freeComponentviewpageState();
}

class freeComponentviewpageState extends State<freeComponent_viewpage> {
  final List<bool> _selectedCenter = <bool>[true, false];


  List<String> LIST_MENU = [];
  bool closeTapContainer = false;
  double topContainer = 0;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List listOrder = [];

  String? defaultCenter = '전체';
  String? SeouldefaultCenter = "전체";
  String url = "";
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String dropdownValue = '';
  String? centerName = '';
  String? centerLabel = '';
  String? seoulCenterLabel = '';

  int cuindex = 0;
  int colorindex = 0;

  Future<void> getUserLocalData() async {
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value){
      int ListData = value.length;
      for(int i = 0; i < ListData; i++){
        LIST_MENU.add(value[i]);
      }

      String? checklocalItem = fnChecklocal(LIST_MENU[0])?.first;
      print(checklocalItem);
      getPostsData("${checklocalItem}_전체");

      setState(() {
        dropdownValue = LIST_MENU[0];
      });
    });
  }

  Future<void> getPostsData(value) async {
    if(value.toString().contains("_")){
      centerName = value.toString().split("_")[1];
      value = fnChecklocal(value.toString().split("_")[0])?.last;
    }else{
      value = 'SEOUL';
      centerName = seoulCenterLabel;
    }

    listOrder = [];
    listItems = [];
    List<dynamic> valueData = [];
    List<dynamic> responseList = [];

    DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore.instance.collection("crawlingData").doc(value);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    late  Map<String, dynamic>? valueDoc = documentSnapshot.data();
    String? numberName = valueDoc?.keys.first.split("_")[0];
    for(int i = 1; i < valueDoc!.length + 2; i++){
      listOrder.add("${numberName}_${i.toString().trim()}");
    }
    List<DateTime> f = [];
    for(int i = 0; i<listOrder.length; i++){
      valueDoc.forEach((key, value) {
        if(listOrder[i] == key){
          DateTime dateTime = value["registrationdate"].toDate();
          valueData.add(value);
          f.add(dateTime);
        }
      });
    }

    valueData.sort((a,b) {
      var adate = a['registrationdate']; //before -> var adate = a.expiry;
      var bdate = b['registrationdate']; //before -> var bdate = b.expiry;
      return bdate.compareTo(adate); //to get the order other way just switch `adate & bdate`
    });

    responseList = valueData;

    for ( var post in responseList){
      colorindex = fnCnterCheck(post['center_name ']);

      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime dateTime = post["registrationdate"].toDate();
      if(centerLabel == "전체"){
        centerLabel = null;
      }
      if(centerName == centerLabel){
        if(post["center_name "].toString().contains(centerLabel!)){
          listItems.add( GestureDetector(
              onTap: () async{
                final Uri url = Uri.parse('${post["link"]}');
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                  // url, post["title"], post['center_name '], post['registrationdate'], 0
                    url, post["title"], post['center_name '], dateTime, 0
                )));
              },
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 7.5,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                      border: Border.all(color: Colors.black12, width: 1)), //테두리
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${post["title"]}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                          maxLines: 2,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Expanded(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    // padding: EdgeInsets.all(3),
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
                                          : AppColors.black,
                                      child: Text(
                                        '${post['center_name ']}',
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                        textDirection: ui.TextDirection.ltr,
                                      )
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  // '시작일 | ${post['registrationdate'].trim()}',
                                  '시작일 | ${dateFormat.format(dateTime)}',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  textDirection: ui.TextDirection.ltr,
                                ),
                              ],
                            )
                        )
                      ],
                    ),
                  )
              ))
          );
        }
      }else{
        listItems.add( GestureDetector(
            onTap: () async{
              final Uri url = Uri.parse('${post["link"]}');
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                // url, post["title"], post['center_name '], post['registrationdate'], 0
                  url, post["title"], post['center_name '], dateTime, 0
              )));
            },
            child: Container(
                width: 500,
                height: 110,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                    border: Border.all(color: Colors.black12, width: 1)), //테두리
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${post["title"]}',
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                        maxLines: 2,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Expanded(
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
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
                                      : AppColors.black,
                                  child: Text(
                                    '${post['center_name ']}',
                                    style: const TextStyle(fontSize: 13, color: Colors.white),
                                    textDirection: ui.TextDirection.ltr,
                                  )
                              ),
                              SizedBox(width: 8),
                              Text(
                                '시작일 | ${dateFormat.format(dateTime)}',
                                // '시작일 | ${post['registrationdate'].trim()}',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                textDirection: ui.TextDirection.ltr,
                              ),
                            ],
                          )
                      )
                    ],
                  ),
                )
            ))
        );
      }
    }
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();

    getUserLocalData();
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value){
      int ListData = value.length;
      PrivateLocalData = [];
      for(int i = 0; i < ListData; i++){
        PrivateLocalData.add(value[i]);
      }
    });

    mypageUserSaveData = FirebaseService.getUserPrivacyProfile(userEmail!);
    mypageUserSaveData.then((value){
      setState(() {
        value[0]?.forEach((element) {
          if(element.toString().contains('/')){
            profileImage = element.toString();
          }else{
            userName = element.toString();
          }
        });
      });
    });
    controllers.addListener(() {

      double value = controllers.offset/119;

      setState(() {
        topContainer = value;
        closeTapContainer = controllers.offset > 50;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height / 25;

    List<Widget> CategoryCenter = <Widget>[
      Text('동네소식'),
      Text('서울소식'),
    ];

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            title:
            DropdownButton(
              alignment: Alignment.center,
              focusColor: AppColors.primary,
              icon: const Icon(Icons.keyboard_arrow_down),
              isExpanded: false,
              isDense: false,
              underline: Container(),
              value: dropdownValue,
              items: LIST_MENU.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontWeight: FontWeight.w600)),
                );
              }).toList(),
              onChanged: (dynamic value){
                listItems = [];
                List? item = fnChecklocal(value);
                if(value == item?.first){
                  getPostsData("${item?.first}_전체");
                  // getPostsData(item?.last);
                }
                setState(() {
                  dropdownValue = value;
                  defaultCenter = "전체";
                });
              },
            ),
            actions: <Widget>[
              IconButton(onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => searchScreen(title: '',))
                );
              },
                  icon: const Icon(Icons.search)),
              IconButton(onPressed: (){
                Get.to(() => noticemainpage());
              }, icon: const Icon(Icons.notifications_none_outlined)),
            ],
          ),
          body: SizedBox(
            height: size.height,
            child: Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => introduceWidget(),),);
                    },
                    child: Image.asset("assets/images/banner.png")
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        ToggleButtons(
                          direction: Axis.horizontal,
                          isSelected: _selectedCenter,
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < _selectedCenter.length; i++) {
                                _selectedCenter[i] = i == index;
                              }
                              if(index == 0){
                                cuindex = 0;
                                defaultCenter = '전체';
                                getPostsData("${fnChecklocal(dropdownValue)?.first}_전체");
                              }else if(index == 1) {
                                cuindex = 1;
                                getPostsData('서울_전체');
                                SeouldefaultCenter = '전체';
                              }
                            });
                          },
                          fillColor: AppColors.background,
                          borderColor: AppColors.background,
                          selectedBorderColor: AppColors.background,
                          selectedColor: AppColors.primary,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          color: AppColors.black,
                          constraints: const BoxConstraints(
                            maxWidth: 100,
                            minWidth: 70,
                            minHeight: 40.0,
                          ),
                          children: CategoryCenter,
                        ),
                      ],
                    ),
                    SizedBox(width: size.width / 4,),
                    cuindex == 0
                        ? DropdownButton(
                        alignment: Alignment.center,
                        focusColor: AppColors.primary,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        isExpanded: false,
                        isDense: false,
                        underline: Container(),
                        value: defaultCenter,
                        items: centerCheck.map( (value) {
                          if(value == "전체"){
                            return DropdownMenuItem (
                              value: value, child: Text(value),
                            );
                          }else{
                            return DropdownMenuItem (
                              value: value, child: Text("${dropdownValue+value}"),
                              // value: value, child: Text(value),
                            );
                          }
                        },
                        ).toList(),
                        onChanged: (value){
                          setState(() {
                            listItems = [];
                            centerLabel = value as String?;
                            defaultCenter = value as String?;
                            getPostsData(dropdownValue+"_"+defaultCenter!);
                          }
                          );
                        }
                    )
                        : DropdownButton(

                        alignment: Alignment.center,
                        focusColor: AppColors.primary,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        isExpanded: false,
                        isDense: false,
                        underline: Container(),
                        value: SeouldefaultCenter,
                        items: SeoulCheck.map( (value) {
                          if(value == "전체"){
                            return DropdownMenuItem (
                              value: value, child: Text(value),
                            );
                          }else{
                            return DropdownMenuItem (
                              value: value,
                              child: value == '서울시청'
                                  ? Row(
                                      children: [
                                        Image.asset('assets/images/seoul.logo.png', width: size.width / 25),
                                        Text(value)
                                      ],
                                    )
                                  : Text(value),
                              // value: value, child: Text(value),
                            );
                          }
                        },
                        ).toList(),
                        onChanged: (value){
                          setState(() {
                            listItems = [];
                            seoulCenterLabel = value as String?;
                            centerLabel = value as String?;
                            SeouldefaultCenter = value as String?;
                            if(value == 'NPO지원센터'){
                              value = 'NPO';
                            }else if(value == '서울시청'){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                        contentPadding: EdgeInsets.only(top: 0.0),
                                        content: Container(
                                            width: size.width,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                InkWell(
                                                  child: Container(
                                                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Image.asset('assets/images/seoul.logo.white.png', width: 20,height: 20,),
                                                        Text(
                                                          " 서울시청",
                                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child:TextButton(onPressed: (){
                                                    final Uri url = Uri.parse('https://www.seoul.go.kr/realmnews/in/list.do');
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                                        seoulUrlLoadScreen(
                                                            url
                                                        )));
                                                  }, child: Text('분야별 새소식', style: TextStyle(color: AppColors.black),)),
                                                  decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                ),
                                                Container(
                                                  child:TextButton(onPressed: (){
                                                    final Uri url = Uri.parse('https://www.seoul.go.kr/thismteventfstvl/list.do');
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                                        seoulUrlLoadScreen(
                                                            url
                                                        )));
                                                  }, child: Text('이달의 행사 및 축제', style: TextStyle( color: AppColors.black),)),
                                                  decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                ),
                                                Container(
                                                  child:TextButton(onPressed: (){
                                                    final Uri url = Uri.parse('https://www.seoul.go.kr/eventreqst/list.do');
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                                        seoulUrlLoadScreen(
                                                            url
                                                        )));
                                                  }, child: Text('이벤트 신청', style: TextStyle( color: AppColors.black),)),
                                                  decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                ),
                                                Container(
                                                  child:TextButton(onPressed: (){
                                                    final Uri url = Uri.parse('https://mediahub.seoul.go.kr/competition/competitionList.do');
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                                        seoulUrlLoadScreen(
                                                            url
                                                        )));
                                                  }, child: Text('내 손안의 서울(공모전)', style: TextStyle( color: AppColors.black),)),
                                                  decoration: BoxDecoration(border: Border.all(width: 0.1, color: AppColors.grey)),
                                                )
                                              ],
                                            )
                                        )
                                    );
                                  }
                              );
                            }
                            getPostsData(value);
                          }
                          );
                        }
                    )
                  ],
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: itemsData.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (c, i){
                          double scale = 1.0;
                          if (topContainer > 0.5){
                            scale = i + 0.5 - topContainer;
                            if (scale < 0 ) { scale = 0;}
                            else if (scale > 1) { scale = 1; }
                          }
                          return Align(
                            heightFactor: 0.95,
                            alignment: Alignment.topCenter,
                            child: itemsData[i],
                          );
                        }
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}


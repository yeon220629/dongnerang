import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/setting/noticepage.screen.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  // final CategoriesScroller categoriesScroller = CategoriesScroller();
  final List<bool> _selectedCenter = <bool>[true, false];
  List<String> LIST_MENU = [];
  bool closeTapContainer = false;
  double topContainer = 0;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List listOrder = [];

  var currentItem = "";
  String compareTime = '';
  String url = "";
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String dropdownValue = '';
  int cuindex = 0;
  int colorindex = 0;
  String? defaultCenter = '전체';
  String? SeouldefaultCenter = "NPO";
  String? centerName = '';

  Future<void> getUserLocalData() async {
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value){
      int ListData = value.length;
      for(int i = 0; i < ListData; i++){
        LIST_MENU.add(value[i]);
      }

      String? checklocalItem = fnChecklocal(LIST_MENU[0])?.last;
      getPostsData(checklocalItem);

      setState(() {
        dropdownValue = LIST_MENU[0];
      });
    });
  }

  Future<void> getPostsData(value) async {
    // print(value);
    if(value.toString().contains("_")){
      centerName = value.toString().split("_")[1];
      value = fnChecklocal(value.toString().split("_")[0])?.last;
    }

    listOrder = [];
    listItems = [];
    List<dynamic> valueData = [];
    List<dynamic> responseList = [];

    DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore.instance.collection("crawlingData").doc(value);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    late  Map<String, dynamic>? valueDoc = documentSnapshot.data();

    String? numberName = valueDoc?.keys.first.split("_")[0];
    for(int i = 1; i < valueDoc!.length; i++){
      listOrder.add("${numberName}_${i.toString().trim()}");
    }

    List<DateTime> f = [];
    for (String element in listOrder) {
      valueDoc.forEach((key, value) {
        if(element == key){
          DateTime dateTime = value["registrationdate"].toDate();
          f.add(dateTime);
        }
      });
    }
    f.sort((a,b){
      return b.compareTo(a);
    });

    for(DateTime a in f){
      for (String element in listOrder) {
        valueDoc.forEach((key, value) {
          if(element == key){
            DateTime dateTime = value["registrationdate"].toDate();
            if(a == dateTime){
              valueData.add(value);
            }
          }
        });
      }
    }

    responseList = valueData;

    for ( var post in responseList){
      if(post["center_name "].toString().contains("구청")){
        colorindex = 1;
      }else{
        colorindex = 0;
      }

      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateTime dateTime = post["registrationdate"].toDate();

      if(centerName == '구청'){
        if(post["center_name "].toString().contains("구청")){
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
                                  // padding: EdgeInsets.all(3),
                                    color: colorindex == 1
                                        ? AppColors.blue
                                        : AppColors.green,
                                    // color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
                                    // [_random.nextInt(9) * 100],
                                    child: Text(
                                      '${post['center_name ']}',
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                      textDirection: ui.TextDirection.ltr,
                                    )
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
      }else if(centerName == '문화재단'){
        if(post["center_name "].toString().contains("문화재단")){
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
                                        ? AppColors.blue
                                        : AppColors.green,
                                    // color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
                                    // [_random.nextInt(9) * 100],
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
                                    ? AppColors.blue
                                    : AppColors.green,
                                // color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
                                // [_random.nextInt(9) * 100],
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
    // getPostsData(null);
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

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            // title: Container(
            //     width: 50,
            //     child: Image.asset("assets/images/logo.png"),
            // ),
            actions: <Widget>[
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: size.width / 22,),
                          Container(
                            width: size.width / 8,
                            child: Image.asset("assets/images/logo.png"),
                          ),
                          SizedBox(width: size.width / 15,),
                          DropdownButton(
                            value: dropdownValue,
                            items: LIST_MENU.map<DropdownMenuItem<String>>((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
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
                          const SizedBox(width: 130,),
                          IconButton(onPressed: (){
                            // Get.to(() => searchScreen(title: '',));
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
                      // GestureDetector(
                      //     onTap: () {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(builder: (context) => introduceWidget(),),);
                      //     },
                      //     child: Image.asset("assets/images/banner.png")
                      // ),
                    ],
                  )
              )
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
                              }else {
                                cuindex = 1;
                                getPostsData('서울_전체');
                              }
                            });
                          },
                          fillColor: AppColors.white,
                          borderColor: AppColors.white,
                          selectedBorderColor: AppColors.white,
                          selectedColor: AppColors.blue,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          color: AppColors.black,
                          constraints: const BoxConstraints(
                            minHeight: 40.0,
                            minWidth: 80.0,
                          ),
                          children: CategoryCenter,
                        ),
                      ],
                    ),
                    SizedBox(width: size.width / 4,),
                    cuindex == 0
                        ? DropdownButton(
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
                                defaultCenter = value as String?;
                                getPostsData(dropdownValue+"_"+defaultCenter!);
                              }
                              );
                            }
                        )
                        : DropdownButton(
                        value: SeouldefaultCenter,
                        items: SeoulCheck.map( (value) {
                          if(value == "전체"){
                            return DropdownMenuItem (
                              value: value, child: Text(value),
                            );
                          }else{
                            return DropdownMenuItem (
                              value: value, child: Text("$value"),
                              // value: value, child: Text(value),
                            );
                          }
                        },
                        ).toList(),
                        onChanged: (value){
                          setState(() {
                            listItems = [];
                            SeouldefaultCenter = value as String?;
                            if(SeouldefaultCenter == 'NPO'){

                            }
                          }
                          );
                        }
                    ),
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
                          return Opacity(
                            opacity: scale,
                            child: Transform(
                              transform: Matrix4.identity()..scale(scale, scale),
                              alignment: Alignment.bottomCenter,
                              child: Align(
                                heightFactor: 0.95,
                                alignment: Alignment.topCenter,
                                child: itemsData[i],
                              ),
                            ),
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



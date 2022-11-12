import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:dongnerang/screens/mainScreenBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import '../constants/common.constants.dart';
import '../services/firebase.service.dart';
import 'url.load.screen.dart';

class searchScreen extends StatefulWidget {
  searchScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _searchScreenState createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController SearcheditingController = new TextEditingController();
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String url = "";
  String label = "최근 검색어";
  String resetLabel = "전체 삭제";

  bool closeTapContainer = false;
  bool isTextEdit = true;

  final _random = Random();
  double topContainer = 0;
  int colorindex = 0;

  List ResentSearch = [];
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List? item = [];
  List getUserLocaldata = [];

  Future<void> getPostsData(value) async {
    List<dynamic> valueData = [];
    item = [];
    listItems = [];
    for (int i = 0; i < getUserLocaldata.length; i++) {
      item?.add(fnChecklocal(getUserLocaldata[i]));
    }
    item?.add(fnChecklocal("서울"));
    for (int i = 0; i < item!.length; i++) {
      DocumentReference<Map<String, dynamic>> docref = FirebaseFirestore
          .instance.collection("crawlingData").doc(item![i][1]);
      final DocumentSnapshot<
          Map<String, dynamic>> documentSnapshot = await docref.get();
      var valueDoc = documentSnapshot.data();
      if(value == ''){
        listItems = [];
        break;
      }
      valueDoc?.forEach((key, value) {
        valueData.add(value);
      });
    }

    List<dynamic> responseList = valueData;
    listItems = [];
    for (var post in responseList) {
      colorindex = fnCnterCheck(post['center_name ']);
      DateTime dateTime = post["registrationdate"].toDate();
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");

      if (post['title'].contains(value)) {
        listItems.add(GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('${post["link"]}');
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  urlLoadScreen(
                      url, post["title"], post['center_name '],
                      dateTime, 2
                  )));
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: 90,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                    border: Border.all(color: Colors.black12, width: 1)), //테두리
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          '${post["title"]}',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                          maxLines: 2,
                        ),
                      ),
                      // const SizedBox(
                      //   height: 11,
                      // ),
                      Expanded(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
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
                                      : AppColors.black,
                                  ),
                                  child: Text(
                                    ' ${post['center_name ']} ',
                                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                    textDirection: ui.TextDirection.ltr,
                                  )
                              ),
                            ),
                            SizedBox(width: 7),
                            Text(
                              '시작일 | ${dateFormat.format(dateTime)}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                              textDirection: ui.TextDirection.ltr,
                            ),
                          ],
                        ),
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
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value){
      int ListData = value.length;
      for(int i = 0; i < ListData; i++){
        getUserLocaldata.add(value[i]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
            color: AppColors.black
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            //페이지 리로드
            onPressed: (){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (BuildContext context) =>
                      mainScreen()), (route) => false);
            }
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          const SizedBox(width: 50,),
          Expanded(
            child: Center(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '키워드를 입력해주세요 ex) 예술, 대관',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.grey)
                ),
                controller: SearcheditingController,
                onChanged: (value){
                  print("value : $value");
                  setState(() {
                    if(value.isEmpty){
                      print("빈값임");
                      label = '최근 검색어';
                      resetLabel = '전체 삭제';
                      isTextEdit = true;
                    }else{
                      print("비어있지 않음");
                      label = '검색결과';
                      resetLabel = '';
                      isTextEdit = false;
                      getPostsData(value);
                    }
                  });
                },
                onSubmitted: (value){
                  // 엔터 쳣을때 이벤트.
                  ResentSearch.add(value);
                },
              ),
            ),
          ),
          IconButton(onPressed: (){
            setState(() {
              ResentSearch.add(SearcheditingController.text);
              // getPostsData(SearcheditingController.text);
            });
          }, icon: Icon(Icons.search)),
          IconButton(onPressed: () {
            setState(() {
              SearcheditingController.clear();
              isTextEdit = true;
              label = '최근 검색어';
              itemsData = [];
            });
          }, icon: Icon(Icons.clear, color: Colors.black))
        ],
      ),
    body: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
    return KeyboardDismissOnTap(
    child: SizedBox(
        height: size.height,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$label",
                          style: TextStyle( fontSize: 20),),
                        TextButton(
                            onPressed: (){
                              setState(() {
                                ResentSearch = [];
                              });
                            },
                            child: Text("$resetLabel", style: TextStyle(
                              color: AppColors.grey
                            ),)
                        )
                      ],
                    ),
                    isTextEdit
                      ? searchResult(size.height, size.width)
                      : SizedBox(
                          height: size.height / 1.3,
                          child: Column(
                            children: <Widget>[
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
                              )
                            ],
                          ),
                    )
                ],
              )
            ),
        ),
      );
      }),
    );
  }

  Widget searchResult(double height, double width){
    return Container(
      height: height/ 2,
      width: width,
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      // decoration: BoxDecoration(border: Border.all(width: 1)),
      child: GridView.builder(
        itemCount: ResentSearch.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 1 / 0.25, //item 의 가로 1, 세로 2 의 비율
          // mainAxisSpacing: 5, //수평 Padding
          // crossAxisSpacing: 5, //수직 Padding
        ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            // color: AppColors.red,
            // decoration: BoxDecoration(
            //   border: Border(
            //     bottom: BorderSide(width: 0.5)
            //   )
            // ),
            child: Column(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: TextButton(
                            onPressed: (){
                              setState(() {
                                SearcheditingController.text = ResentSearch[index];
                                isTextEdit = false;
                                getPostsData(ResentSearch[index]);
                              });
                            },
                          child: Text("${ResentSearch[index]}",style: TextStyle(color: AppColors.primary),)),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.bottom,
                          child: IconButton(
                              onPressed: (){
                                setState(() {
                                  ResentSearch.remove(ResentSearch[index]);
                                });
                              },
                              icon: Icon(Icons.close)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ),
          );
        }
      ),
    );
  }
}
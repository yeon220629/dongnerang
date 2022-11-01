import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
                width: 500,
                height: 110,
                margin: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(100), blurRadius: 10.0),
                ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15),
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
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(3),
                              color: Colors.primaries[_random.nextInt(Colors
                                  .primaries.length)]
                              [_random.nextInt(9) * 100],
                              child: Text(
                                '${post['center_name ']}',
                                style: const TextStyle(fontSize: 13,
                                    color: Colors.black),
                                textDirection: ui.TextDirection.ltr,
                              )
                          ),
                          SizedBox(width: 10),
                          Text(
                            // '시작일 | ${post['registrationdate'].trim()}',
                            '시작일 | ${dateFormat.format(dateTime)}',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.grey),
                            textDirection: ui.TextDirection.ltr,
                          ),
                        ],
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
        iconTheme: IconThemeData(
            color: AppColors.black
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          const SizedBox(width: 60,),
          Expanded(
            child: TextField(
              controller: SearcheditingController,
              onChanged: (value){
                setState(() {
                  if(value.isEmpty){
                    // print("빈값임");
                    label = '최근 검색어';
                    resetLabel = '전체 삭제';
                    isTextEdit = true;
                  }else{
                    // print("비어있지 않음");
                    label = '검색 결과';
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
              itemsData = [];
            });
          }, icon: Icon(Icons.clear, color: Colors.black,))
        ],
      ),
      body: SizedBox(
        height: size.height,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$label",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
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
        )
    );
  }

  Widget searchResult(double height, double width){
    return Container(
      height: height/ 2.3,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      // decoration: BoxDecoration(border: Border.all(width: 1)),
      child: GridView.builder(
        itemCount: ResentSearch.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 1 / 0.3, //item 의 가로 1, 세로 2 의 비율
          mainAxisSpacing: 10, //수평 Padding
          crossAxisSpacing: 10, //수직 Padding
        ),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            // color: AppColors.red,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1)
              )
            ),
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
                          child: Text("${ResentSearch[index]}",style: TextStyle(color: AppColors.black),)),
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
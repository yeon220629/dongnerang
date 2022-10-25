import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final KeywordScroller keywordscroller = KeywordScroller();
  late TextEditingController SearcheditingController = new TextEditingController();
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  bool closeTapContainer = false;
  final _random = Random();
  double topContainer = 0;
  String url = "";


  List ResentSearch = [];
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List<dynamic> responseData = [];
  List getUserkeyword = [];
  List? item = [];

  Future<void> getPostsData(value) async {
    item = [];
    List<dynamic> valueData = [];
    listItems = [];

    for (int i = 0; i < getUserkeyword.length; i++) {
      item?.add(fnChecklocal(getUserkeyword[i]));
    }
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
    for (var post in responseList) {
      if (post['title'].contains(value)) {
        listItems.add(GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('${post["link"]}');
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  urlLoadScreen(
                      url, post["title"], post['center_name '],
                      post['registrationdate'], 2
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
                                textDirection: TextDirection.ltr,
                              )
                          ),
                          SizedBox(width: 10),
                          Text(
                            '시작일 | ${post['registrationdate'].trim()}',
                            style: const TextStyle(
                                fontSize: 17, color: Colors.grey),
                            textDirection: TextDirection.ltr,
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

  Future<List> getKeword() async {
    List valueTemp = [];
    final checkDuplicate = await FirebaseFirestore.instance.collection("users")
        .doc(userEmail)
        .get();
    checkDuplicate.data()?.forEach((key, value) {
      if (key.contains("keyword")) {
        valueTemp.add(value);
      }
    });
    return valueTemp.first;
  }
  @override
  void initState() {
    super.initState();
    FirebaseService.getUserLocalData(userEmail!, 'local').then((value){
      int ListData = value.length;
      for(int i = 0; i < ListData; i++){
        getUserkeyword.add(value[i]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.30;

    return Scaffold(
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
                print(value);
                getPostsData(value);
              },
            ),
          ),
          IconButton(onPressed: (){
          }, icon: Icon(Icons.search)),
          IconButton(onPressed: () {
            SearcheditingController.clear();
          }, icon: Icon(Icons.clear, color: Colors.black,))
        ],
      ),
      body: SizedBox(
        height: size.height,
        child : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("인기 키워드", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    AnimatedOpacity(
                      opacity: closeTapContainer ? 0:1,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: size.width,
                        alignment: Alignment.topCenter,
                        height: closeTapContainer? 0 : categoryHeight - 160,
                        child: keywordscroller,),
                    ),
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text("검색 결과", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
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
            )
          ],
        )
      )
    );
  }
}

class KeywordScroller extends StatefulWidget {
  const KeywordScroller({Key? key}) : super(key: key);


  @override
  State<KeywordScroller> createState() => _KeywordScrollerState();
}

class _KeywordScrollerState extends State<KeywordScroller> {
  List tags = [];
  List selected_tags = [];
  List select_tags = [];

  @override
  Widget build(BuildContext context) {
    final double categoryHeight = MediaQuery
        .of(context)
        .size
        .height * 0.30 - 50;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
          child: Row(
            children: <Widget>[
              Container(
                width: categoryHeight * 2.9,
                margin: const EdgeInsets.only(right: 5),
                height: categoryHeight - 150,
                child: Center(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: <Widget>[...generate_tags(CustomKeyword)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      label: Text("${name}"),
      onSelected: (value) {
        print("${value} : ${name}");
        if (select_tags.length >= 1) {
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
        });
      },
    );
  }
}
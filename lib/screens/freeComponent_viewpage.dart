import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../constants/common.constants.dart';
import 'package:dongnerang/screens/search.screen.dart';


class freeComponent_viewpage extends StatefulWidget {
  const freeComponent_viewpage({Key? key}) : super(key: key);

  @override
  State<freeComponent_viewpage> createState() => freeComponentviewpageState();
}

class freeComponentviewpageState extends State<freeComponent_viewpage> {
  List<String> LIST_MENU = <String>[
    '동작', '강북', '관악', '광진', '강남', '서초', '성북', '양천', '영등포', '종로',
    '중구'
  ];

  String dropdownValue = '동작';
  final _random = Random();
  bool closeTapContainer = false;
  double topContainer = 0;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  String url = "";
  double progress = 0;
  var label = "전체소식";

  Future<void> getPostsData(value) async {
    listItems = [];
    List<dynamic> valueData = [];
    List<dynamic> responseList = [];
    if(value == null){
      print("들어온 변수가 null 값입니다.");
      value = 'DONGJAK';
    }

    DocumentReference<Map<String, dynamic>> docref =
      FirebaseFirestore.instance.collection("crawlingData").doc(value);

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await docref.get();
    var valueDoc = documentSnapshot.data();

    valueDoc?.forEach((key, value) {
      valueData.add(value);
    });

    responseList = valueData;

    for ( var post in responseList){
      listItems.add( GestureDetector(
          onTap: () async{
            final Uri url = Uri.parse('${post["link"]}');
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(url)));
          },
          child: Container(
              width: 500,
              height: 110,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
              ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${post["title"]}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                      maxLines: 3,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.all(3),
                            color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
                            [_random.nextInt(9) * 100],
                            child: Text(
                              '${post['center_name ']}',
                              style: const TextStyle(fontSize: 13, color: Colors.black),
                              textDirection: TextDirection.ltr,
                            )
                        ),
                        SizedBox(width: 10),
                        Text(
                          '시작일 | ${post['registrationdate']}',
                          style: const TextStyle(fontSize: 17, color: Colors.grey),
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
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(
          color : Colors.blue,
        ),
        onRefresh: () async {
          webViewController?.reload();
        }
    );

    getPostsData(null);
    controller.addListener(() {

      double value = controller.offset/119;

      setState(() {
        topContainer = value;
        closeTapContainer = controller.offset > 50;
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
    final double categoryHeight = size.height*0.30;

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: const Icon(Icons.ac_unit, color: Colors.black),
            actions: <Widget>[
              DropdownButton(
                value: dropdownValue,
                items: LIST_MENU.map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (dynamic value){
                  if(value == '강남'){
                    print("GANGNAM");
                    getPostsData("GANGNAM");
                  }else if(value == '강북'){
                    getPostsData("GANGBUK");
                  }else if(value == '관악'){
                    getPostsData("GWANAK");
                  }else if(value == '광진'){
                    getPostsData("GWANGZIN");
                  }else if(value == '동작'){
                    getPostsData("DONGJAK");
                  }else if(value == '서초'){
                    getPostsData("SEOCHO");
                  }else if(value == '성북'){
                    getPostsData("SEONGBUK");
                  }else if(value == '양천'){
                    getPostsData("YANGCHEON");
                  }else if(value == '영등포'){
                    getPostsData("YEONGDEUNGPO");
                  }else if(value == '종로'){
                    getPostsData("JONGRO");
                  }else if(value == '중구'){
                    getPostsData("JUNGGU");
                  }
                  setState(() {
                    if(mounted){
                      dropdownValue = value;
                    }
                  });
                },
              ),
              const SizedBox(width: 180,),
              IconButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => searchScreen(title: '',))
                );
              },
              icon: const Icon(Icons.search), color: Colors.blueAccent),
              IconButton(onPressed: (){}, icon: const Icon(Icons.baby_changing_station), color: Colors.blueAccent),
            ],
          ),
          body: SizedBox(
            height: size.height,
            child: Column(
              children: <Widget>[
                AnimatedOpacity(
                  opacity: closeTapContainer?0:1,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: size.width,
                    alignment: Alignment.topCenter,
                    height: closeTapContainer?0:categoryHeight - 75,
                    child: categoriesScroller,),
                ),
                BottomNavigationBar(
                    elevation: 1.0,
                    selectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    onTap: (value){
                      print(value);
                      setState(() {
                        // 이쪽 한번 이야기 필요.
                        if(value == 0 ){
                          label = "동네소식";
                          getPostsData('all');
                        }else if(value == 1){
                          label = "서울시소식";
                          setState(() {
                          });
                        }else {
                          label = "전체 소식";
                        }
                      });
                    },
                    items: [
                      BottomNavigationBarItem(
                        label: "동네소식",
                        icon: Icon(Icons.linear_scale, size: 0,)
                      ),
                      BottomNavigationBarItem(
                        label: "서울시 소식",
                        icon: Icon(Icons.linear_scale, size: 0,)
                      ),
                    ]
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("$label", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  )
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
            ),
          ),
        )
    );
  }
}

class CategoriesScroller extends StatelessWidget {
  const CategoriesScroller();
  @override
  Widget build(BuildContext context) {
    final double categoryHeight = MediaQuery.of(context).size.height * 0.30 - 50;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
          child: Row(
            children: <Widget>[
              Container(
                width: 375,
                margin: const EdgeInsets.only(right: 20),
                height: categoryHeight - 50,
                decoration: BoxDecoration(color: Colors.blueAccent.shade100),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text(
                        "현재 인기가\n가장 많은 지원사업",
                        style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



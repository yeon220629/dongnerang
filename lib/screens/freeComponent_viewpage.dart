import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/colors.constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/common.constants.dart';

class freeComponent_viewpage extends StatefulWidget {
  const freeComponent_viewpage({Key? key}) : super(key: key);

  @override
  State<freeComponent_viewpage> createState() => freeComponentviewpageState();
}

class freeComponentviewpageState extends State<freeComponent_viewpage> {
  final TextEditingController editingController = TextEditingController();
  final CategoriesScroller categoriesScroller = CategoriesScroller();

  ScrollController controller = ScrollController();
  bool closeTapContainer = false;
  double topContainer = 0;
  List<String> LIST_MENU = <String>[
    '동작', '강북', '관악', '광진', '강남',
    '서초', '성북', '양천', '영등포', '종로',
    '중구'
  ];
  List<Widget> itemsData = [];

  Future<void> getPostsData(value) async {
    if(value == null){
      print("들어온 변수가 null 값입니다.");
      value = 'DONGJAK';
    }

    DocumentReference<Map<String, dynamic>> docref =
    FirebaseFirestore.instance.collection("crawlingData").doc(value);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await docref.get();
    var valueDoc = documentSnapshot.data();

    List<dynamic> valueData = [];
    valueDoc?.forEach((key, value) {
      valueData.add(value);
    });

    List<dynamic> responseList= valueData;
    // List<dynamic> responseList = FOOD_DATAs;
    List<Widget> listItems = [];

    for ( var post in responseList){
      listItems.add( GestureDetector(
          onTap: () async{
            final Uri url = Uri.parse('${post["link"]}');
            await launchUrl(url);
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
                          Text(
                            '${post['center_name ']}',
                            style: const TextStyle(fontSize: 17, color: Colors.grey),
                            textDirection: TextDirection.ltr,
                          ),
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
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height*0.30;
    String dropdownValue = LIST_MENU.first;

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: const Icon(Icons.ac_unit, color: AppColors.black),
            title: CupertinoSearchTextField(
              controller: editingController,
              prefixIcon: const Icon(Icons.search),
              placeholder: "관련 검색",
              placeholderStyle:
              const TextStyle(fontSize: 14,color: AppColors.hintText),
              onChanged: (value) {
                print(value);
              },
            ),
            actions: [
              // DropdownButtonExample()
              DropdownButton(
                items: LIST_MENU.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: dropdownValue,
                onChanged: (String? value){
                  print(value);
                  if(value == '강남'){
                    print("GANGNAM");
                  }
                },
              )
            ],
          ),
          // drawer: DropdownButton(
          //     items: LIST_MENU.map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //     value: dropdownValue,
          //     onChanged: (String? value){
          //       print(value);
          //       if(value == '강남'){
          //         print("GANGNAM");
          //       }
          //     },
          //   ),
          // drawer: Drawer( // 함수로 뺴야하는 부분
          //     child: ListView(
          //       padding: EdgeInsets.zero,
          //       children: <Widget>[
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('강남'),
          //           onTap: () {
          //             EasyLoading.show(status: " 데이터 로딩 중...");
          //             getPostsData('GANGNAM');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('강북'),
          //           onTap: () {
          //             getPostsData('GANGBUK');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('관악'),
          //           onTap: () {
          //             getPostsData('GWANAK');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('광진'),
          //           onTap: () {
          //             getPostsData('GWANGZIN');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('동작'),
          //           onTap: () {
          //             getPostsData('DONGJAK');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('서초'),
          //           onTap: () {
          //             getPostsData('SEOCHO');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('성북'),
          //           onTap: () {
          //             getPostsData('SEONGBUK');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('양천'),
          //           onTap: () {
          //             getPostsData('YANGCHEON');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('영등포'),
          //           onTap: () {
          //             getPostsData('YEONGDEUNGPO');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('종로'),
          //           onTap: () {
          //             getPostsData('JONGRO');
          //           },
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.home,
          //             color: Colors.grey[850],
          //           ),
          //           title: Text('중구'),
          //           onTap: () {
          //             getPostsData("JUNGGU");
          //           },
          //         ),
          //       ],
          //     )
          // ),
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
                    height: closeTapContainer?0:categoryHeight,
                    child: categoriesScroller,),
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
                height: categoryHeight,
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
                        height: 15,
                      ),
                      Text(
                        "지원사업 보러가기",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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



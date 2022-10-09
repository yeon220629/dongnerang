import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/models/app_user.model.dart';
import 'package:dongnerang/screens/url.load.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../constants/colors.constants.dart';
import '../constants/common.constants.dart';
import 'package:dongnerang/screens/search.screen.dart';
import '../services/firebase.service.dart';
import 'noticepage.screen.dart';


class freeComponent_viewpage extends StatefulWidget {
  const freeComponent_viewpage({Key? key}) : super(key: key);

  @override
  State<freeComponent_viewpage> createState() => freeComponentviewpageState();
}

class freeComponentviewpageState extends State<freeComponent_viewpage> {
  final CategoriesScroller categoriesScroller = CategoriesScroller();
  // List<String> LIST_MENU = <String>[
  //   '동작', '강북', '관악', '광진', '강남', '서초', '성북', '양천', '영등포', '종로',
  //   '중구'
  // ];
  List<String> LIST_MENU = [];


  final _random = Random();
  bool closeTapContainer = false;
  double topContainer = 0;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  String url = "";
  var label = "전체소식";
  var currentItem = "";
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String dropdownValue = '';

  Future<void> getUserLocalData() async {
    FirebaseService.getUserLocalData(userEmail!).then((value){
      int ListData = value.length;
      for(int i = 0; i < ListData; i++){
        LIST_MENU.add(value[i]);
      }

      String? checklocalItem = fnChecklocal(LIST_MENU[0])?.last;
      getPostsData(checklocalItem);

      setState(() {
        dropdownValue = LIST_MENU[0]!;
      });
    });
  }

  Future<void> getPostsData(value) async {
    print("valuesss : $value");
    listItems = [];
    List<dynamic> valueData = [];
    List<dynamic> responseList = [];
    // if(value == null){
    //   value = 'DONGJAK';
    // }
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
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                url, post["title"], post['center_name '], post['registrationdate']
            )));
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
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
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
    getUserLocalData();
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
    final double categoryHeight = size.height*0.30;
    // String dropdownValue = LIST_MENU[0];
    bool isClicked = false;

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xff5d6acb),
            title: Container(
                width: 40,
                child: Image.asset("assets/images/app_logo.png"),
            ),
            // fit:BoxFit.cover,
            // height:20,
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
                  listItems = [];
                  // print("value : $value");
                  // print("return 확인 : ${fnChecklocal(value)}" );
                  List? item = fnChecklocal(value);
                  // print("item?.first : ${item?.first}");
                  // getPostsData("GANGNAM");
                  if(value == item?.first){
                    getPostsData(item?.last);
                  }
                  setState(() {
                    dropdownValue = value;
                  });
                },
              ),
              const SizedBox(width: 160,),
              IconButton(onPressed: (){
                Get.to(() => searchScreen(title: '',));
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => searchScreen(title: '',))
                // );
              },
              icon: const Icon(Icons.search)),
              IconButton(onPressed: (){
                Get.to(() => NoticePage());
              }, icon: const Icon(Icons.notifications_none_outlined)),
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
                    showUnselectedLabels: true,
                    showSelectedLabels: true,
                    // selectedLabelStyle: const TextStyle(color: Colors.red),
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.grey,
                    onTap: (value){
                      setState(() {
                        if(value == 0){
                          label = "동네소식";
                          isClicked = false;
                          if(currentItem == ""){
                            currentItem = "DONGJAK";
                            getPostsData(currentItem);
                          }
                          getPostsData(currentItem);
                        }
                        else if(value == 1){
                          label = "서울시 소식";
                          isClicked = false;
                          getPostsData("NPO");
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
                        icon: Icon(
                          Icons.linear_scale, size: 0,
                          color: isClicked == true ? AppColors.primary : AppColors.grey,
                          //
                        )
                      ),
                      BottomNavigationBarItem(
                        label: "서울시 소식",
                        icon: Icon(Icons.linear_scale, size: 0,
                        color: isClicked == true ? AppColors.primary : AppColors.grey,
                        )
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
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
          child: Row(
            children: <Widget>[
              Container(
                width: 375,
                margin: const EdgeInsets.only(right: 20),
                height: categoryHeight - 50,
                // decoration: BoxDecoration(color: Colors.blueAccent.shade100),
                child:Center(
                          child: Image.asset("assets/images/banner.png")
                      ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

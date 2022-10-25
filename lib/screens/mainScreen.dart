import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/setting/noticepage.screen.dart';
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
import 'introduce.dart';

class freeComponent_viewpage extends StatefulWidget {
  const freeComponent_viewpage({Key? key}) : super(key: key);

  @override
  State<freeComponent_viewpage> createState() => freeComponentviewpageState();
}

class freeComponentviewpageState extends State<freeComponent_viewpage> {
  // final CategoriesScroller categoriesScroller = CategoriesScroller();

  List<String> LIST_MENU = [];
  bool closeTapContainer = false;
  double topContainer = 0;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List listOrder = [];
  String url = "";
  var label = "전체소식";
  var currentItem = "";
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String dropdownValue = '';
  int cuindex = 0;
  int colorindex = 0;
  String? defaultCenter = '전체';
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
        dropdownValue = LIST_MENU[0]!;
      });
    });
  }

  Future<void> getPostsData(value) async {
    print(value);
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

    for (String element in listOrder) {
      valueDoc?.forEach((key, value) {
        if(element == key){
          valueData.add(value);
        }
      });
    }
    responseList = valueData;

    for ( var post in responseList){
      if(post["center_name "].toString().contains("구청")){
        colorindex = 1;
      }else{
        colorindex = 0;
      }
      if(centerName == '구청'){
        if(post["center_name "].toString().contains("구청")){
          listItems.add( GestureDetector(
              onTap: () async{
                final Uri url = Uri.parse('${post["link"]}');
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
                    url, post["title"], post['center_name '], post['registrationdate'], 0
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
                                      textDirection: TextDirection.ltr,
                                    )
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '시작일 | ${post['registrationdate'].trim()}',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  textDirection: TextDirection.ltr,
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
                    url, post["title"], post['center_name '], post['registrationdate'], 0
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
                                      textDirection: TextDirection.ltr,
                                    )
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '시작일 | ${post['registrationdate'].trim()}',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  textDirection: TextDirection.ltr,
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
                  url, post["title"], post['center_name '], post['registrationdate'], 0
              )));
            },
            child: Container(
                width: 500,
                height: 110,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                    border: Border.all(color: Colors.black12, width: 1)), //테두리
                // decoration: BoxDecoration(color: Colors.white, boxShadow: [
                //   BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
                // ]),
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
                                    textDirection: TextDirection.ltr,
                                  )
                              ),
                              SizedBox(width: 8),
                              Text(
                                '시작일 | ${post['registrationdate'].trim()}',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                                textDirection: TextDirection.ltr,
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

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            title: Container(
                width: 50,
                child: Image.asset("assets/images/logo.png"),
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
                  List? item = fnChecklocal(value);
                  if(value == item?.first){
                    getPostsData(item?.last);
                  }
                  setState(() {
                    dropdownValue = value;
                    defaultCenter = "전체";
                  });
                },
              ),
              const SizedBox(width: 160,),
              IconButton(onPressed: (){
                // Get.to(() => searchScreen(title: '',));
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => searchScreen(title: '',))
                );
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
                //배너
                GestureDetector(
                    // onTap: _launchUrl,
                      // child: Text('Show Flutter homepage'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => introduceWidget(),),);
                    },
                    // height: 200,
                    // width: 200,
                    child: Image.asset("assets/images/banner.png")),
                BottomNavigationBar(
                    currentIndex: cuindex,
                    elevation: 1.0,
                    showUnselectedLabels: true,
                    showSelectedLabels: true,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: AppColors.grey,
                    selectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                    unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                    onTap: (value){
                      setState(() {
                        cuindex = value;
                        if(value == 0){
                          label = "동네소식";
                          getPostsData(fnChecklocal(dropdownValue)?.last);
                          setState(() {});
                        }
                        else if(value == 1){
                          label = "서울시 소식";
                          getPostsData('서울_전체');
                          setState(() {});
                        }
                      });
                    },
                    items: [
                      new BottomNavigationBarItem(
                        label: "동네소식",
                        icon: Icon(
                          Icons.linear_scale, size: 0,
                          color: cuindex == 0
                              ? AppColors.primary
                              : AppColors.grey,
                          //
                        )
                      ),
                      new BottomNavigationBarItem(
                        label: "서울시 소식",
                        icon: Icon(Icons.linear_scale, size: 0,
                        color: cuindex == 1 ? AppColors.primary : AppColors.grey,
                        )
                      ),
                    ]
                ),
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
                : SizedBox(),
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


// final Uri _url = Uri.parse('https://moored-adasaurus-5d6.notion.site/bbdd58432e9d4f95a0863e691bffe61d');
// final List<String> imgList = [
//   'https://cdn.pixabay.com/photo/2020/08/09/11/31/business-5475283_1280.jpg',
//   'https://cdn.pixabay.com/photo/2016/04/05/07/08/money-1308823_1280.jpg',
// ];

// class CategoriesScroller extends StatelessWidget {
//   const CategoriesScroller();
//   @override
//   Widget build(BuildContext context) {
//     // final double categoryHeight = MediaQuery.of(context).size.height * 0.30 - 90;
//     return
      // SingleChildScrollView(
      // physics: const BouncingScrollPhysics(),
      // scrollDirection: Axis.horizontal,
      // child: Container(
      //   margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      //   child: FittedBox(
      //     fit: BoxFit.fill,
      //     alignment: Alignment.topCenter,
      //     child: Row(
      //       children: <Widget>[
      //         Container(
      //           color: Color(0xFFEDF0F4),
      //           width: 375,
      //           margin: const EdgeInsets.only(right: 20),
      //           height: categoryHeight - 10,
      //           // decoration: BoxDecoration(color: Colors.blueAccent.shade100),
      //           child:
      //           CarouselSlider(
      //             options: CarouselOptions(height: 400.0),
      //             items: [1,2,3,4,5].map((i) {
      //               return Builder(
      //                 builder: (BuildContext context) {
      //                   return Container(
      //                       width: MediaQuery.of(context).size.width,
      //                       margin: EdgeInsets.symmetric(horizontal: 5.0),
      //                       decoration: BoxDecoration(
      //                           color: Colors.amber
      //                       ),
      //                       child: Text('text $i', style: TextStyle(fontSize: 16.0),)
      //                   );
      //                 },
      //               );
      //             }).toList(),
      //           GestureDetector(
                          // child: Image.asset("assets/images/banner.png"),
      //                       onTap: _launchUrl,
      //                       final url = Uri.parse(
      //                       'https://moored-adasaurus-5d6.notion.site/bbdd58432e9d4f95a0863e691bffe61d',
      //                       );
      //                       if (await canLaunchUrl(url)) {
      //                       launchUrl(url);
      //                       } else {
      //                       // ignore: avoid_print
      //                       print("Can't launch $url");
      //                       }
      //                       },
      //                 ),
      //           ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


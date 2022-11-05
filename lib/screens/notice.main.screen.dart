import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/services/firebase.service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/colors.constants.dart';
import '../constants/common.constants.dart';

class noticemainpage extends StatefulWidget {
  const noticemainpage({super.key});

  @override
  State<noticemainpage> createState() => _noticemainpageState();
}

class _noticemainpageState extends State<noticemainpage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  double topContainer = 0;
  String td = FirebaseService().getToday();
  List<Widget> noticeDataWidget = [];
  List<Widget> noticeItemsData = [];

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controllers.addListener(() {
      double value = controllers.offset/119;
      setState(() {
        topContainer = value;
        getNoticeData(td);
      });
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
            Tab(
              text: '키워드 알림',
            ),
            Tab(
              text: '동네랑 알림',
            ),
          ],
          onTap: (value) {
            print(value);
            if(value == 1){
              setState(() {
                // getNoticeData(td);
              });
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
            Lottie.asset(
              'assets/lottie/77412-design.json',
              // width: 10,
              // height: 10,
              fit: BoxFit.contain,
            ),
            Lottie.asset(
              'assets/lottie/77412-design.json',
              // width: 10,
              // height: 10,
              fit: BoxFit.contain,
            ),
          // Center(
          //   child: SizedBox(
          //     height: size.height,
          //     child: Column(
          //       children: [

                  // Expanded(
                  //     child: ListView.builder(
                  //         itemCount: noticeItemsData.length,
                  //         physics: const BouncingScrollPhysics(),
                  //         itemBuilder: (c, i){
                  //           double scale = 1.0;
                  //           if (topContainer > 0.5){
                  //             scale = i + 0.5 - topContainer;
                  //             if (scale < 0 ) { scale = 0;}
                  //             else if (scale > 1) { scale = 1; }
                  //           }
                  //           return Opacity(
                  //             opacity: scale,
                  //             child: Transform(
                  //               transform: Matrix4.identity()..scale(scale, scale),
                  //               alignment: Alignment.bottomCenter,
                  //               child: Align(
                  //                 heightFactor: 0.95,
                  //                 alignment: Alignment.topCenter,
                  //                 child: noticeItemsData[i],
                  //               ),
                  //             ),
                  //           );
                  //         }
                  //     )
                  // ),
                // ],
              // ),
            // ),
          // ),
        ],
      ),
    );
  }
}

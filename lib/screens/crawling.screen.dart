import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.constants.dart';
import '../models/crawlling.model.dart';

//ver 2
Future<List<crawliingModel>> getCraData() async {
  List<crawliingModel> imgBox = [];
  List<String> imgStringBox = [];
  List<String> imgStringRemoveBox = [];
  List<String> imgStringTitle = [];

  List<String> imgLinkBox = [];
  List<String> imgLinkBoxA = [];

  const String response = 'https://www.ydpcf.or.kr/artexhibit.do';
  final http.Response rep = await http.get(Uri.parse(response));

  var doc = parser.parse(rep.body);
  doc
      .getElementsByClassName('gallery-wrap mt-80p')
      .forEach((element) {

        var Count = element.getElementsByClassName('gallery-item-wrap').length;
        for(int i=0; i<Count; i++){

          imgStringBox.add(element.getElementsByClassName('gallery-item-wrap')[i].text.replaceAll(RegExp(r"\s+"), ','));
          imgStringTitle.add(element.getElementsByClassName('subject text-shadow move-url')[i].text.replaceAll(RegExp(r"\s+"), ''));
          imgLinkBox.add('https://www.ydpcf.or.kr${element.getElementsByTagName('img')[i].attributes['src']}');
          imgLinkBoxA.add('https://www.ydpcf.or.kr${element.getElementsByTagName('a')[i].attributes['href']}');

          imgStringRemoveBox = imgStringBox[i].split(',');
          imgStringRemoveBox.removeLast();

          imgBox.add(crawliingModel(
              imgLink: imgLinkBox[i],
              imgLinkA: imgLinkBoxA[i],
              imgStatus: imgStringRemoveBox,
              imgStringTitle: imgStringTitle[i],
          ));
        }
      });
  return imgBox;
}

class crawlingScreen extends StatefulWidget {
  const crawlingScreen({Key? key}) : super(key: key);

  @override
  State<crawlingScreen> createState() => _crawlingScreenState();
}
// 크롤링 페이지
class _crawlingScreenState extends State<crawlingScreen> {
  refresh(){
    setState(() {
      getCraData();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  final controller = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CupertinoSearchTextField(
          prefixIcon: const Icon(Icons.search),
          placeholder: "관련 검색",
          placeholderStyle:
          const TextStyle(fontSize: 14,color: AppColors.hintText),
          onChanged: (value) {
            print(value);
          },
        ),
      ),
      drawer: Drawer( // 함수로 뺴야하는 부분
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.grey[850],
              ),
              title: Text('경기도'),
              onTap: () {
                print('Home is clicked');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.grey[850],
              ),
              title: Text('강원도'),
              onTap: () {
                print('Home is clicked');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.grey[850],
              ),
              title: Text('제주도'),
              onTap: () {
                print('Home is clicked');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.grey[850],
              ),
              title: Text('경상도'),
              onTap: () {
                print('Home is clicked');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.grey[850],
              ),
              title: Text('전라도'),
              onTap: () {
                if (kDebugMode) {
                  print('Home is clicked');
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: FutureBuilder<List<crawliingModel>>(
                  future: getCraData(),
                  builder: (context, snapshot){
                    if(snapshot.hasError){
                      return const Center(
                        child: Text('An Error has Occurred!'),
                      );
                    }else if(snapshot.hasData){
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index){
                            return Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                              height: 250,
                              // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data![index].imgStringTitle,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Container(
                                      child:Row(
                                        children: [
                                          Image.network(snapshot.data![index].imgLink),
                                          const SizedBox(width: 35, height: 50),
                                          Column(
                                            children: [
                                              IconButton(
                                                iconSize: 80,
                                                onPressed: (){},
                                                icon:
                                                Text("일정 : ${snapshot.data![index].imgStatus[2]}"),
                                              ),
                                              IconButton(
                                                alignment: Alignment.center,
                                                iconSize: 55,
                                                onPressed: (){
                                                  Uri url = Uri.parse(snapshot.data![index].imgLinkA);
                                                  launchUrl(url);
                                                },
                                                icon: Text(snapshot.data![index].imgStatus.last, style: const TextStyle(fontWeight: FontWeight.bold),),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                      );
                    }else{
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              )
            )
          ],
        ),
      // bottomNavigationBar: BOTTOM_NAVIGATOR,
      );
    }
  }

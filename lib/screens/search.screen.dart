import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/screens/freeComponent_viewpage.dart';
import 'package:dongnerang/screens/mainScreen.dart';
import 'package:dongnerang/screens/mypage.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../constants/common.constants.dart';
import 'url.load.screen.dart';

class searchScreen extends StatefulWidget {
  searchScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _searchScreenState createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen>
    with SingleTickerProviderStateMixin {
  static TextEditingController SearcheditingController = TextEditingController();

  List<TagModel> _tags = [];
  String get _searchText => SearcheditingController.text.trim();
  bool closeTapContainer = false;
  final _random = Random();
  double topContainer = 0;
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  List<dynamic> responseData = [];
  List<dynamic> Search_value = [];
  String url = "";
  double progress = 0;


  Future<void> getPostsData(value) async {
    if(value == null){
      print("들어온 변수가 null 값입니다.");
      value = 'DONGJAK';
    }

    DocumentReference<Map<String, dynamic>> docref =
    FirebaseFirestore.instance.collection("crawlingData").doc('DONGJAK');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await docref.get();
    var valueDoc = documentSnapshot.data();

    List<dynamic> valueData = [];

    valueDoc?.forEach((key, value) {
      valueData.add(value);
    });

    List<dynamic> responseList= valueData;
    // responseData.addAll(responseList);

    for ( var post in responseList){
      if(post['title'].contains(value)){
        print("data okay : ${post['title']}, ${post['number']}");
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
    }
    setState(() {
      itemsData = listItems;
    });
  }

  final List<TagModel> _tagsToSelect = [
    TagModel(id: 'DONGJAK', title: '사육신역사관'),
    TagModel(id: 'DONGDAEMUN', title: '문화예술교육'),
    TagModel(id: 'NPO', title: '지원사업'),
    TagModel(id: 'JUNGGU', title: '생활기술자를'),
    TagModel(id: 'JUNGGU', title: '이야기'),
    TagModel(id: 'JUNGGU', title: '선정결과'),
  ];
  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    SearcheditingController.addListener(() => refreshState(() {}));
    pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(
          color : Colors.blue,
        ),
        onRefresh: () async {
          webViewController?.reload();
        }
    );
    SearcheditingController.text = '';
    controller.addListener(() {
      double value = controller.offset/119;
      setState(() {
        topContainer = value;
        closeTapContainer = controller.offset > 50;
      });
    });
  }

  // @override
  // void dispose() {
  //   SearcheditingController.dispose();
  //   super.dispose();
  // }

  List<TagModel> _filterSearchResultList() {
    if (_searchText.isEmpty) {
      itemsData = [];
      return _tagsToSelect;
    }

    List<TagModel> _tempList = [];
    for (int index = 0; index < _tagsToSelect.length; index++) {
      TagModel tagModel = _tagsToSelect[index];
      if (tagModel.title
          .toLowerCase()
          .trim()
          .contains(_searchText.toLowerCase())) {
        _tempList.add(tagModel);
      }
    }

    return _tempList;
  }

  _addTags(tagModel) async {
    if (!_tags.contains(tagModel)) {
      setState(() {
        // _tags.add(tagModel);
        SearcheditingController.text = tagModel.title;
      });
    }
  }

  _removeTag(tagModel) async {
    if (_tags.contains(tagModel)) {
      setState(() {
        _tags.remove(tagModel);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Icon(Icons.ac_unit, color: Colors.black),
        actions: <Widget>[
          const SizedBox(width: 60,),
          Expanded(
            child: TextField(
              controller: SearcheditingController,
            ),
          ),
          IconButton(onPressed: (){
            setState(() {
              listItems = [];
            });
            Future.delayed(Duration.zero, () async {
              getPostsData(SearcheditingController.text);
            });
          }, icon: Icon(Icons.search, color: Colors.black,)),
          IconButton(onPressed: (){
            SearcheditingController.clear();
          }, icon: Icon(Icons.clear, color: Colors.black,))
        ],
      ),
      body: _tagIcon(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(label: '홈',icon: IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => mainScreen()),
              );
            }, icon: Icon(Icons.home),
          )),
          BottomNavigationBarItem(label: '마이페이지', icon: IconButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => mainScreen()),
            );
          }, icon: Icon(Icons.info)))
        ]
      ),
    );
  }

  Widget _tagIcon() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 25.0,),
        _tagsWidget(),
      ],
    );
  }

  _displayTagWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _filterSearchResultList().isNotEmpty
          ? _buildSuggestionWidget()
          : Text(''),
    );
  }

  Widget _buildSuggestionWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // if (_filterSearchResultList().length != _tags.length)
      Text('인기 키워드', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Wrap(
        alignment: WrapAlignment.start,
        children: _filterSearchResultList()
            .where((tagModel) => !_tags.contains(tagModel))
            .map((tagModel) => tagChip(
          tagModel: tagModel,
          onTap: () => _addTags(tagModel),
          action: 'Add',
        ))
            .toList(),
      ),
    ]);
  }

  Widget tagChip({
    tagModel,
    onTap,
    action,
  }) {
    return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  '${tagModel.title}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: CircleAvatar(
                backgroundColor: Colors.orange.shade600,
                radius: 8.0,
                child: Icon(
                  Icons.clear,
                  size: 10.0,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ));
  }

  Widget _tagsWidget() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _tags.length > 0
              ? Column(children: [
            Wrap(
              alignment: WrapAlignment.start,
              children: _tags
                  .map((tagModel) => tagChip(
                tagModel: tagModel,
                onTap: () => _removeTag(tagModel),
                // action: 'Remove',
              ))
                  .toSet()
                  .toList(),
            ),
          ])
              : Container(),
          _displayTagWidget(),
          _serachResultWidget(),
        ],
      ),
    );
  }

  Widget _serachResultWidget() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text("검색 결과", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    );
  }
}

class TagModel {
  String id;
  String title;

  TagModel({
    required this.id,
    required this.title,
  });
}
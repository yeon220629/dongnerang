import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dongnerang/constants/colors.constants.dart';
import 'package:dongnerang/screens/community/community.insert.screen.dart';
import 'package:dongnerang/screens/mainScreenBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';


class commnunityMainScreen extends StatefulWidget {
  final StatusNumber;
  commnunityMainScreen(this.StatusNumber);

  @override
  State<commnunityMainScreen> createState() => _commnunityMainScreenState();
}

class _commnunityMainScreenState extends State<commnunityMainScreen> {
  List<Widget> itemsData = [];
  List<Widget> listItems = [];
  final int _pageSize = 20;
  final PagingController<int, dynamic> _pagingController = PagingController(firstPageKey: 0);
  double topContainer = 0;

  Future<List<DocumentSnapshot>> getAllDocuments(String collectionName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
    return querySnapshot.docs;
  }

  Future<void> getListData(value) async{
    var photo;
    if(value["imageList"].toString() != "[]"){
      photo = value["imageList"][0].toString().replaceAll('[', '').replaceAll(']', '');
    }

    listItems.add( GestureDetector(
        onTap: () async{
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => urlLoadScreen(
          //     url, post["title"], post['center_name '], dateTime, 0
          // )));
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 90,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), //모서리를 둥글게
                border: Border.all(color: Colors.black, width: 1)), //테두리
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                '제목 : ${value["title"]}',
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  maxLines: 2,
                                ),
                                Text(
                                  '${value["mainText"]}',
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                            photo != null
                              ? Container(
                                  // child: CachedNetworkImage(
                                  //     imageUrl: value['imageList'].toString()
                                  //     , width: 10 / 2.2
                                  //     , fit: BoxFit.fill
                                  // )
                                    child: Flexible(
                                      child: Image.network(
                                        photo,
                                        fit: BoxFit.cover,
                                        width: MediaQuery.of(context).size.width / 4,
                                        height: MediaQuery.of(context).size.height / 10.5,
                                      )
                                    )
                                  )
                              : Text("no photo")
                          ],
                        )
                      ],
                    )
                  )
                ],
              ),
            )
        ))
    );
  }

  Future<void> getPostsData() async {
    List<DocumentSnapshot> documents = await getAllDocuments("community");

    // 리스트를 다시 부를때 스크롤 위치를 맨위로
    // var controller = PrimaryScrollController.of(context);
    for (DocumentSnapshot document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      // Do something with the data
      if(!data.values.isEmpty){
        data.values.forEach((element) {
          // print("element : ${element}");
          getListData(element);
        });
      }
    }
    print("listItems : ${listItems.length}");
    setState(() {
      itemsData = listItems;
    });
  }
  Future<void> _fetchPage(int pageKey) async {
    try {
      Future.delayed(Duration(milliseconds: pageKey == 0 ? 0 : 500), () {
        int lastIdx = itemsData.length;
        print("lastIdx : $lastIdx");
        print("listItems : ${listItems.length}");
        // 카테고리 필터, 거리순, _pageSize개수 만큼 불러오기
        List<dynamic> newItems = itemsData.sublist(pageKey, (pageKey + _pageSize < lastIdx ? pageKey + _pageSize : lastIdx));

        bool isLastPage = newItems.length < _pageSize;

        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      });
    } catch (error) {
      _pagingController.error = error;
    }
  }
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    getPostsData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    bool showBottomSheetBtn = false; // 리스트 보여주기 유무
    final Size size = MediaQuery.of(context).size;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SizedBox(
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.center,
              child: Column(
                children: [
                  Expanded(
                      child: PagedListView<int, dynamic>(
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<dynamic>(
                          itemBuilder: (context, item, i){
                            print("item : $item");
                            print("context : $context");
                            print("i : $i");
                            double scale = 1.0;
                            if (topContainer > 0.5){
                              scale = i + 0.5 - topContainer;
                              if (scale < 0 ) { scale = 0;}
                              else if (scale > 1) { scale = 1; }
                            }
                            return Align(
                              heightFactor: 0.98,
                              alignment: Alignment.topCenter,
                              child: itemsData[i],
                            );
                          },
                          firstPageProgressIndicatorBuilder: (_) => const SizedBox(),
                        ),
                      )
                  )
                ],
              )
            ),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 14.0),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showBottomSheetBtn = true;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => commnunityInsert())
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add_circle),
                            Text("글쓰기")
                          ],
                        ),
                      )
                    ),
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  width: size.width,
                  padding: EdgeInsets.only(
                    top: statusBarHeight,
                  ),
                  decoration: const BoxDecoration(color: AppColors.background),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 90),
                          child: Wrap(
                            spacing: 5.0,
                            children: ['전체', '알림', '행사', '소식'].map((category) {
                              return FilterChip(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                label: SizedBox(
                                  child: Text(
                                    category,
                                  ),
                                ),
                                onSelected: (bool value) {
                                  setState(() {
                                    getPostsData();
                                    if (value) {
                                    }
                                  });
                                  // markerInit();
                                  // _pagingController.refresh();
                                  // categoryCountSum = getCategoryCountSum();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

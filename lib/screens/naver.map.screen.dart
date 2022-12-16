import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

class NaverMapScreen extends StatefulWidget {
  // final StatusNumber;
  // mypageScreen(this.StatusNumber);

  @override
  State<NaverMapScreen> createState() => _NaverMapScreenState();

}

class _NaverMapScreenState extends State<NaverMapScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<NaverMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        // elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.settings, color: Colors.black),
        //     onPressed: () {
        //       Navigator.push(context, MaterialPageRoute(
        //           builder: (_) => SettingsPage(versionCode))
        //       );
        //     },
        //   )
        // ],
        // title: Text('내 정보 관리', style: TextStyle(color: Colors.black)),
        // backgroundColor: Colors.white,
      ),
      body: NaverMap(
          onMapCreated: _onMapCreated,
        ),
    );
  }
  
  void _onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}

import 'package:flutter/material.dart';

import '../constants/colors.constants.dart';

class noticemainpage extends StatefulWidget {
  const noticemainpage({super.key});

  @override
  State<noticemainpage> createState() => _noticemainpageState();
}

/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _noticemainpageState extends State<noticemainpage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: AppColors.primary,
        ),
        centerTitle: true,
        title: const Text('알림', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),),
        bottom: TabBar(
          // indicatorColor: AppColors.blue,
          unselectedLabelStyle: TextStyle(color: AppColors.grey),
          labelColor: AppColors.blue,
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: '키워드 알림',
            ),
            Tab(
              text: '동네랑 알림',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          Center(
            child: Text("It's cloudy here"),
          ),
          Center(
            child: Text("It's rainy here"),
          ),
        ],
      ),
    );
  }
}

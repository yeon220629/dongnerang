import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.constants.dart';

class commnunitySelect extends StatefulWidget {
  const commnunitySelect({Key? key}) : super(key: key);

  @override
  State<commnunitySelect> createState() => _commnunitySelectState();
}

class _commnunitySelectState extends State<commnunitySelect> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: AppColors.black,
            ),
            backgroundColor: AppColors.white,
            centerTitle: true,
            elevation: 0.0,
            title: Text('조회', style: TextStyle(color: AppColors.black),),
            actions: [

            ],
          ),
        )
    );
  }
}

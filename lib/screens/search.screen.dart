import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incom/screens/url.load.screen.dart';
import '../constants/common.constants.dart';
import 'package:filter_list/filter_list.dart';

class searchScreen extends StatefulWidget {
  const searchScreen({Key? key, this.allTextList, this.selectedUserList})
      : super(key: key);

  final List<User>? allTextList;
  final List<User>? selectedUserList;

  @override
  State<searchScreen> createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen> {

  List<User>? selectedUserList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilterListWidget<User>(
                hideSelectedTextCount: true,
                listData: userList,
                selectedListData: selectedUserList,
                onApplyButtonClick: (list) {
                  Navigator.pop(context, list);
                },
                choiceChipLabel: (item) {
                  return item!.name;
                },
                validateSelectedItem: (list, val) {
                  return list!.contains(val);
                },
                onItemSearch: (user, query) {
                  return user.name!.toLowerCase().contains(query.toLowerCase());
                },
              ),
            ],
          ),
        )
      ),
    );
  }
}

class User {
  final String? name;
  final String? avatar;
  User({this.name, this.avatar});
}

List<User> userList = [
  User(name: "Abigail", avatar: "user.png"),
  User(name: "Audrey", avatar: "user.png"),
  User(name: "Ava", avatar: "user.png"),
  User(name: "Bella", avatar: "user.png"),
  User(name: "Bernadette", avatar: "user.png"),
  User(name: "Carol", avatar: "user.png"),
  User(name: "Claire", avatar: "user.png"),
  User(name: "Deirdre", avatar: "user.png"),
  User(name: "Donna", avatar: "user.png"),
  User(name: "Dorothy", avatar: "user.png"),
  User(name: "Faith", avatar: "user.png"),
  User(name: "Gabrielle", avatar: "user.png"),
  User(name: "Grace", avatar: "user.png"),
  User(name: "Hannah", avatar: "user.png"),
  User(name: "Heather", avatar: "user.png"),
  User(name: "Irene", avatar: "user.png"),
  User(name: "Jan", avatar: "user.png"),
  User(name: "Jane", avatar: "user.png"),
  User(name: "Julia", avatar: "user.png"),
  User(name: "Kylie", avatar: "user.png"),
  User(name: "Lauren", avatar: "user.png"),
  User(name: "Leah", avatar: "user.png"),
  User(name: "Lisa", avatar: "user.png"),
  User(name: "Melanie", avatar: "user.png"),
  User(name: "Natalie", avatar: "user.png"),
  User(name: "Olivia", avatar: "user.png"),
  User(name: "Penelope", avatar: "user.png"),
  User(name: "Rachel", avatar: "user.png"),
  User(name: "Ruth", avatar: "user.png"),
  User(name: "Sally", avatar: "user.png"),
  User(name: "Samantha", avatar: "user.png"),
  User(name: "Sarah", avatar: "user.png"),
  User(name: "Theresa", avatar: "user.png"),
  User(name: "Una", avatar: "user.png"),
  User(name: "Vanessa", avatar: "user.png"),
  User(name: "Victoria", avatar: "user.png"),
  User(name: "Wanda", avatar: "user.png"),
  User(name: "Wendy", avatar: "user.png"),
  User(name: "Yvonne", avatar: "user.png"),
  User(name: "Zoe", avatar: "user.png"),
];

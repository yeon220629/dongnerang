import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.constants.dart';

class noticemainAlarmpage extends StatefulWidget {
  final List keywordList;
  final List localList;
  const noticemainAlarmpage( this.keywordList, this.localList);

  @override
  State<noticemainAlarmpage> createState() => _noticemainAlarmpageState();
}

class _noticemainAlarmpageState extends State<noticemainAlarmpage> {

  @override
  void initState() {
    super.initState();
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
        title: const Text('알림 키워드 설정', style: TextStyle( color: AppColors.black),),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 40),
          child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("관심 키워드" , style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                Container(
                  width: size.width / 1.25,
                  height: size.height / 15,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(10) 
                      ),
                      suffixIcon: TextButton(
                        onPressed: (){},
                        child: Text("확인", style: TextStyle(color: AppColors.grey),)
                      )
                    ),
                  ),
                ),
                SizedBox(height: size.height / 22.5,),
                Text("나의 키워드 (${widget.keywordList.length}/20)", style: TextStyle(
                  fontWeight: FontWeight.bold
                ),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: size.width,
                    height: size.height / 4,
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                        childAspectRatio: 1 / 0.6,
                      ),
                      children: <Widget>[...generate_tags(widget.keywordList)],
                    ),
                  ),
                ),
                Text("알림 동네", style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: size.width,
                    height: size.height / 4,
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                        childAspectRatio: 1 / 0.6,
                      ),
                      children: <Widget>[...localgenerate_tags(widget.localList)],
                    ),
                  ),
                ),
              ],
            ),],
          ),
        )
      ),
    );
  }
  generate_tags(value) {
    return value.map( (tag) => get_chip(tag) ).toList();
  }
  get_chip(name) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: Chip(
        backgroundColor: AppColors.white,
        side: BorderSide(width: 1),
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        deleteIcon: Icon( Icons.close,  size: 15, ),
        deleteIconColor: Colors.black,
        label: Text('${name}'),
        onDeleted: () {
          setState(() {
          });
        },
      )
    );
  }
  var _value = '';
  localgenerate_tags(value) {
    return value.map( (tag) => localget_chip(tag) ).toList();
  }
  localget_chip(name) {
    // _value = name
    return Padding(
      padding: EdgeInsets.all(2),
      child: ChoiceChip(
        padding: EdgeInsets.all(8),
        label: Text('${name}', style: TextStyle(color: AppColors.white),),
        selected: _value == name,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.white,
        // backgroundColor: AppColors.primary,
        onSelected: (bool selec){
          setState(() {
            _value = selec ? name : null;
            // print("_value : $_value");
          });
        },
      )
    );
  }
}

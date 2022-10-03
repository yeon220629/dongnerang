import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class mypageScreen extends StatefulWidget {
  const mypageScreen({Key? key}) : super(key: key);

  @override
  State<mypageScreen> createState() => _mypageScreenState();
}

late PickedFile _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
final ImagePicker _picker = ImagePicker();

class _mypageScreenState extends State<mypageScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            children: [
              SizedBox(
                child: Column(
                  children: [
                    Row(
                      children: [
                        imageProfile(),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('동작구참돔', style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                                  TextButton(
                                    onPressed: (){},
                                    child: Text("내 정보 관리 >"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 27),
                          child: IconButton(onPressed: (){}, icon: Icon(Icons.settings)),
                        ),
                      ],
                    ),
                    SizedBox(height: 35,),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                    )
                  ],
                )
              )
            ],
          ),
        ),
      )
    );
  }
}

Widget imageProfile() {
    return Center(
        child: Row(
            children: <Widget>[
                CircleAvatar(
                  radius: 40,
                )
            ],
        ),
    );
}

Widget myInterestedList() {
  return Center(
  );
}

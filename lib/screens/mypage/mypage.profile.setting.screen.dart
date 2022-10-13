import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.constants.dart';
import '../../constants/common.constants.dart';
import '../../services/firebase.service.dart';

class mypageProfileSetting extends StatefulWidget {
  const mypageProfileSetting({Key? key}) : super(key: key);

  @override
  State<mypageProfileSetting> createState() => _mypageProfileSettingState();
}

class _mypageProfileSettingState extends State<mypageProfileSetting> {
  // PickedFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  XFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  final ImagePicker _picker = ImagePicker(); // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)

  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String? profileImage = '';
  String? userName = '';
  late Future<List> userSaveData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    userSaveData = FirebaseService.getUserPrivacyProfile(userEmail!);
    userSaveData.then((value){
      // print("userSaveData 1 :  ${value[1]}");
      setState(() {
        profileImage = value[0][0];
        userName = value[0][1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: fnCommnAppbar(appBar: AppBar(), title: '프로필 수정', center: false, email: '', ListData: [], keyName: ''),
        body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: ListView(
              children: <Widget>[
                imageProfile(),
                SizedBox(height: 20),
                nameTextField(),
                SizedBox(height: 20),
              ],
            )
        )
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: _imageFile == null
                  ? CachedNetworkImage(imageUrl: profileImage!)
                  : CachedNetworkImage(imageUrl: profileImage!)
          ),
          Positioned(
              bottom: 20,
              right: 20,
              child: InkWell(
                onTap: () {
                  // 클릭시 모달 팝업을 띄워준다.
                  showModalBottomSheet(context: context, builder: ((builder) => BottomSheet()));
                },
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.black,
                  size: 40,
                ),
              )
          )
        ],
      ),
    );
  }

  // 카메라 아이콘 클릭시 띄울 모달 팝업
  Widget bottomSheet() {
    return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Choose Profile photo',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.camera, size: 50,),
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                  label: Text('Camera', style: TextStyle(fontSize: 20),),
                ),
                TextButton.icon(
                  icon: Icon(Icons.photo_library, size: 50,),
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
                  },
                  label: Text('Gallery', style: TextStyle(fontSize: 20),),
                )
              ],
            )
          ],
        )
    );
  }

  Widget nameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.black,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.person,
            color: AppColors.black,
          ),
          labelText: 'Name',
          hintText: 'Input your name'
      ),
    );
  }

  Widget BottomSheet() {
    return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Choose Profile photo',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.camera, size: 50,),
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                  label: Text('Camera', style: TextStyle(fontSize: 20),),
                ),
                TextButton.icon(
                  icon: Icon(Icons.photo_library, size: 50,),
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
                  },
                  label: Text('Gallery', style: TextStyle(fontSize: 20),),
                )
              ],
            )
          ],
        )
    );
  }

  takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
      
      print("_imageFile : $_imageFile");
    });
  }
  // Future<File?> takePhoto(ImageSource source) async {
  //   final XFile? image = await _picker.pickImage(source: source);
  //
  //   final File file = File(image!.path);
  //   return file;
  // }
}





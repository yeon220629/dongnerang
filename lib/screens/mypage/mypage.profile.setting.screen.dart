import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.constants.dart';
import '../../services/firebase.service.dart';
import '../mainScreenBar.dart';

class mypageProfileSetting extends StatefulWidget {
  const mypageProfileSetting({Key? key}) : super(key: key);

  @override
  State<mypageProfileSetting> createState() => _mypageProfileSettingState();
}

class _mypageProfileSettingState extends State<mypageProfileSetting> {
  XFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  final ImagePicker _picker = ImagePicker(); // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)

  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String? profileImage = '';
  String? userName = '';
  late Future<List> userSaveData;

  String? userUpdageName;

  List userUpdateData = [];

  @override
  void initState() {
    super.initState();
    userSaveData = FirebaseService.getUserPrivacyProfile(userEmail!);
    userSaveData.then((value){
      setState(() {
        value[0]?.forEach((element) {
          if(element.toString().contains('https')){
            profileImage = element.toString();
          }else{
            userName = element.toString();
          }
        });
      });
    });
    // _imageFile = profileImage as XFile?;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.black,
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text('프로필 수정', style: TextStyle(color: AppColors.black),),
        actions: [
          TextButton(onPressed: (){
            userUpdateData.add(userUpdageName);
            FirebaseService.savePrivacyProfileSetting(userEmail!, userUpdateData, ['name', 'profileImage']);
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (BuildContext context) =>
                    mainScreen()), (route) => false);
            }, child: Text("완료", style: TextStyle(color: AppColors.black),))
          ],
        ),
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
                  // ? Image.asset("assets/images/default-profile.png")
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
          labelText: '${userName}',
          hintText: '${userName}'
      ),
      // onSaved: ,
      onChanged: (value){
        setState(() {
          userUpdageName = value;
        });
      },
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
    print("source : ${source}");
    final pickedFile = await _picker.pickImage(source: source);
    print("pickedFile : $pickedFile");
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





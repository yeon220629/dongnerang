import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class mypageScreen extends StatefulWidget {
    const mypageScreen({Key? key}) : super(key: key);

    @override
    State<mypageScreen> createState() => _mypageScreenState();

    }

    class _mypageScreenState extends State<mypageScreen> {

    @override
    Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.greenAccent,
    appBar: AppBar(
    backgroundColor: Colors.green,
    centerTitle: true,
    elevation: 0.0,
    leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () {
    print('menu button is clicked');
    },
    ),
    actions: [
    IconButton(
    icon: Icon(Icons.shopping_cart),
    onPressed: () {
    print('shopping cart button is clicked');
    },
    ),
    IconButton(
    icon: Icon(Icons.search),
    onPressed: () {
    print('start button is clicked');
    },
    )
    ],
    title: Text('Profile'),
    ),
    body: Padding(
    padding: EdgeInsets.fromLTRB(30.0, 40.0, 0, 0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Center(
    child: CircleAvatar(
    backgroundImage: AssetImage("assets/camera.png"),
    radius: 60.0,
    ),
    ),
    Divider(
    height: 60.0,
    color: Colors.grey[850],
    thickness: 0.8,
    endIndent: 30.0,
    ),
    const Text('Name',
    style: TextStyle(
    color: Colors.white,
    letterSpacing: 3.0,
    ),
    ),
    const SizedBox(height: 10.0,),
    const Text('이창섭',
    style: TextStyle(
    color: Colors.white,
    letterSpacing:2.0,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    ),
    )
            ],
          ),
        ),
      );
    }
}
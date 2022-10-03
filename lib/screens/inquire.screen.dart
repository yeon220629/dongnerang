import 'package:flutter/material.dart';


class Inquire extends StatelessWidget {
  const Inquire({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text('마이페이지'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30.0, 30.0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Center(
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/camera.png"),
                    radius: 60.0,
                  ),
                ),
              ],
            ),
            const Text('Name',
              style: TextStyle(
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 10.0,),
            const Text('이창섭',
              style: TextStyle(
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

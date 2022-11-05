// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import '../../widgets/app_appbar_common.widget.dart';
//
// class Introduce extends StatelessWidget {
//   const Introduce({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Slidable Example',
//       home: Scaffold(
//         body: ListView(
//           children: [
//             Slidable(
//               key: const ValueKey(0),
//               // The start action pane is the one at the left or the top side.
//               startActionPane: ActionPane(
//                 // A motion is a widget used to control how the pane animates.
//                 motion: const ScrollMotion(),
//
//                 // A pane can dismiss the Slidable.
//                 dismissible: DismissiblePane(onDismissed: () {}),
//
//                 // All actions are defined in the children parameter.
//                 children: const [
//                   // A SlidableAction can have an icon and/or a label.
//                   SlidableAction(
//                     onPressed: doNothing,
//                     backgroundColor: Color(0xFFFE4A49),
//                     foregroundColor: Colors.white,
//                     icon: Icons.delete,
//                     label: 'Delete',
//                   ),
//                   SlidableAction(
//                     onPressed: doNothing,
//                     backgroundColor: Color(0xFF21B7CA),
//                     foregroundColor: Colors.white,
//                     icon: Icons.share,
//                     label: 'Share',
//                   ),
//                 ],
//               ),
//
//               // The end action pane is the one at the right or the bottom side.
//               endActionPane: const ActionPane(
//                 motion: ScrollMotion(),
//                 children: [
//                   SlidableAction(
//                     // An action can be bigger than the others.
//                     flex: 2,
//                     onPressed: doNothing,
//                     backgroundColor: Color(0xFF7BC043),
//                     foregroundColor: Colors.white,
//                     icon: Icons.archive,
//                     label: 'Archive',
//                   ),
//                   SlidableAction(
//                     onPressed: doNothing,
//                     backgroundColor: Color(0xFF0392CF),
//                     foregroundColor: Colors.white,
//                     icon: Icons.save,
//                     label: 'Save',
//                   ),
//                 ],
//               ),
//
//               // The child of the Slidable is what the user sees when the
//               // component is not dragged.
//               child: const ListTile(title: Text('Slide me')),
//             ),
//             Slidable(
//               // Specify a key if the Slidable is dismissible.
//               key: const ValueKey(1),
//
//               // The start action pane is the one at the left or the top side.
//               startActionPane: const ActionPane(
//                 // A motion is a widget used to control how the pane animates.
//                 motion: ScrollMotion(),
//
//                 // All actions are defined in the children parameter.
//                 children: [
//                   // A SlidableAction can have an icon and/or a label.
//                   SlidableAction(
//                     onPressed: doNothing,
//                     backgroundColor: Color(0xFFFE4A49),
//                     foregroundColor: Colors.white,
//                     icon: Icons.delete,
//                     label: 'Delete',
//                   ),
//                   SlidableAction(
//                     onPressed: doNothing,
//                     backgroundColor: Color(0xFF21B7CA),
//                     foregroundColor: Colors.white,
//                     icon: Icons.share,
//                     label: 'Share',
//                   ),
//                 ],
//               ),
//
//               // The end action pane is the one at the right or the bottom side.
//               endActionPane: ActionPane(
//                 motion: const ScrollMotion(),
//                 dismissible: DismissiblePane(onDismissed: () {}),
//                 children: const [
//                   SlidableAction(
//                     // An action can be bigger than the others.
//                     flex: 2,
//                     onPressed: doNothing,
//                     backgroundColor: Color(0xFF7BC043),
//                     foregroundColor: Colors.white,
//                     icon: Icons.archive,
//                     label: 'Archive',
//                   ),
//                   SlidableAction(
//                     onPressed: doNothing,
//                     backgroundColor: Color(0xFF0392CF),
//                     foregroundColor: Colors.white,
//                     icon: Icons.save,
//                     label: 'Save',
//                   ),
//                 ],
//               ),
//
//               // The child of the Slidable is what the user sees when the
//               // component is not dragged.
//               child: const ListTile(title: Text('Slide me')),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// void doNothing(BuildContext context) {}
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: fnCommnAppbarWidget(title: '동네랑 소개',appBar: AppBar()),
// //       body: const MyStatefulWidget(),
// //     );
// //   }
// // }
// //
// // class MyStatefulWidget extends StatefulWidget {
// //   const MyStatefulWidget({super.key});
// //
// //   @override
// //   State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
// // }
// //
// // class _MyStatefulWidgetState extends State<MyStatefulWidget> {
// //   bool _customTileExpanded = false;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return
// //       Column(
// //       children: const <Widget>[
// //         ExpansionTile(
// //           title: Text('"서울시 동작구의 소식부터 넓혀지는 "동네랑"'),
// //           subtitle: Text('22.11.08'),
// //           children: <Widget>[
// //             ListTile(title: Text('동네랑은 2명의 개발자와 함께 알리알라리알리아리리모콘트리아')),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// // }
//
// //사용 안 되는 파일!
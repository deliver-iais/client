// import 'package:flutter/material.dart';
// import '../introPageData.dart';

// class Slide extends StatelessWidget {
//   final int _index;

//   Slide(this._index);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: <Widget>[
//         Expanded(
//           flex: 5,
//           child: Row(
//             children: <Widget>[
//               // Container(),
//               Container(
//                 width: 250,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).accentColor,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Image.asset(
//                     sliderContents[_index].imgAddr,
//                     height: 120,
//                     width: 120,
//                   ),
//                 ),
//               ),
//               // Container(),
//             ],
//           ),
//         ),
        
//         Expanded(
//           flex: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Text(
//               sliderContents[_index].title,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//           ),
//         ),
        
//         Expanded(
//           flex: 3,
//           child: Text(
//             sliderContents[_index].description,
//             style: TextStyle(
//               fontSize: 14,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

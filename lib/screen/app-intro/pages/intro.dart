import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import '../introPageData.dart';

class IntroPage extends StatefulWidget {
  IntroPage({Key key}) : super(key: key);
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
  }

  void onDonePress() {
    // Do what you want
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: slidesList,
      onDonePress: this.onDonePress,
      styleNameSkipBtn: TextStyle(color: Theme.of(context).primaryColor),
      styleNameDoneBtn: TextStyle(color: Theme.of(context).primaryColor),
      styleNamePrevBtn: TextStyle(color: Theme.of(context).primaryColor),
      colorDot: Color(0xFFBCE0FD),
      colorActiveDot: Theme.of(context).primaryColor,
    );
  }
}
// class IntroPage extends StatefulWidget {
//   @override
//   _IntroPageState createState() => _IntroPageState();
// }

// class _IntroPageState extends State<IntroPage> {
//   final CarouselController _controller = CarouselController();
//   final List<SliderComponent> _sliderComponents = [
//     SliderComponent(0),
//     SliderComponent(1),
//     SliderComponent(2),
//     SliderComponent(3),
//   ];
//   int _current = 0;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).backgroundColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(
//               flex: 12,
//               child: CarouselSlider(
//                 items: _sliderComponents,
//                 options: CarouselOptions(
//                   height: 400,
//                   onPageChanged: (index, reason) {
//                     setState(
//                       () {
//                         _current = index;
//                       },
//                     );
//                   },
//                   reverse: false,
//                 ),
//                 carouselController: _controller,
//               ),
//             ),
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: <Widget>[
//                   RaisedButton(
//                     onPressed: () {},
//                     child: Text("Next"),
//                   ),
//                   Bubbles(_current, _sliderComponents.length),
//                   RaisedButton(
//                     onPressed: () {
//                       if (_current + 1 != _sliderComponents.length)
//                         _controller.nextPage();
//                     },
//                     child: Text("Skip"),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

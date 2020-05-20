import 'package:deliver_flutter/screen/app-intro/widgets/bubble.dart';
import 'package:deliver_flutter/screen/app-intro/widgets/sliderComponent.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

final Map<String, String> sliderContents = {
  'Messenger': 'assets/messengerLogo.png',
  'Fast': 'assets/fastLogo.png',
  'Private': 'assets/privateLogo.png',
  'Secure': 'assets/secureLogo.png'
};

// final List<Widget> imageSliders = imgList
//     .map((item) => Container(
//           child: Container(
//             margin: EdgeInsets.all(5.0),
//             child: ClipRRect(
//                 borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                 child: Stack(
//                   children: <Widget>[
//                     Image.asset(item, width: 1000.0),
//                     Positioned(
//                       bottom: 0.0,
//                       left: 0.0,
//                       right: 0.0,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Color.fromARGB(200, 0, 0, 0),
//                               Color.fromARGB(0, 0, 0, 0)
//                             ],
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                           ),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                             vertical: 10.0, horizontal: 20.0),
//                         child: Text(
//                           'No. ${imgList.indexOf(item)} image',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )),
//           ),
//         ))
//     .toList();

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final CarouselController _controller = CarouselController();
  final List<SliderComponent> _sliderComponents = [];
  int _current = 0;

  @override
  void initState() {
    super.initState();
  }

  void makeSliderComponents() {
    sliderContents.forEach((title, imgAddr) {
      _sliderComponents.add(new SliderComponent(title, imgAddr));
    });
  }

  @override
  Widget build(BuildContext context) {
    makeSliderComponents();
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [
      CarouselSlider(
        items: _sliderComponents,
        options: CarouselOptions(
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
          });
        },
        reverse: false
        ),
        carouselController: _controller,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
              RaisedButton(
                onPressed: null,
                child: Text("Skip"),
              )
            ] +
            List.generate(
                sliderContents.length, (index) => Bubble(_current, index)) +
            <Widget>[
              RaisedButton(
                onPressed: (){
                  if(_current + 1 != sliderContents.length)
                    _controller.nextPage();},
                child: Text("Next"),
              )
            ],
      ),
    ])));
  }
}

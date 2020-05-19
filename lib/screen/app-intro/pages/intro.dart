import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:CarouselSlider(
          items: <Widget>[],
          options: CarouselOptions(enlargeCenterPage: true, height: 200),
          carouselController: _controller,
        )
      )
    );
  }
}
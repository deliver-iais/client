import 'package:flutter/material.dart';

class AudioCallBottomRow extends StatefulWidget {
  const AudioCallBottomRow({Key key}) : super(key: key);

  @override
  _AudioCallBottomRowState createState() => _AudioCallBottomRowState();
}

class _AudioCallBottomRowState extends State<AudioCallBottomRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 80, right: 50, left: 50),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      width: 60,
                      height: 60,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Color(0xff4a5460),
                        child: const Icon(
                          Icons.volume_up,
                          color: Colors.white70,
                          size: 35,
                        ),
                      )),
                  DialIcon(),
                  Container(
                      width: 60,
                      height: 60,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Color(0xff4a5460),
                        child: const Icon(
                          Icons.mic_off,
                          size: 35,
                          color: Colors.white70,
                        ),
                      ))
                ])));
  }
}

class DialIcon extends StatelessWidget {


  final double size=90;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30 / 192 * size),
      height: MediaQuery.of(context).size.width * 0.3,
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.07),
            Colors.white.withOpacity(0.05)
          ],
          stops: [.5, 1],
        ),
      ),
      child: FloatingActionButton(
            backgroundColor: Color(0xffcf6869),
            elevation: 0, child: const Icon(Icons.call_end,size: 50,)),

    );
  }
}

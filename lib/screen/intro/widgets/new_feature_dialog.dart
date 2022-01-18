import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class NewFeatureDialog extends StatelessWidget {
  const NewFeatureDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      backgroundColor: Colors.white,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: const Image(
                image: AssetImage('assets/images/wave.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("ABOUT UPDATE",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    "V"+VERSION,
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: const [
                  Text(
                    "1.Fix some Bugs",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "2.Fix some Bugs",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "3.Fix some Bugs",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(25),
                child: OutlinedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue)),
                  child: const Text(
                    "Got it",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ]),
    );
  }
}

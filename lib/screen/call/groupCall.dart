import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GroupCall {
  createGroupCallBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        elevation: 10,
        backgroundColor: const Color(0xFF00101A),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Stack(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "group call",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 80),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF182731),
                    ),
                    child: Scrollbar(
                        child: ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Divider(
                                  color: Colors.white12,
                                ),
                              );
                            },
                            itemCount: 2,
                            itemBuilder: (BuildContext ctx, int index) {
                              return GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          CircleAvatarWidget(
                                              "0:b89fa74c-a583-4d64-aa7d-56ab8e37edcd"
                                                  .asUid(),
                                              23,
                                              showSavedMessageLogoIfNeeded:
                                                  true),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text(
                                            "Roya Chitsaz",
                                            overflow: TextOverflow.fade,
                                            maxLines: 1,
                                            softWrap: false,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                          onPressed: () => null,
                                          icon: const Icon(
                                              Icons.keyboard_voice_outlined,
                                              size: 21,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })),
                  )),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const FloatingActionButton(
                        onPressed: null,
                        child: Icon(
                          Icons.videocam_off_rounded,
                          color: Colors.white,
                        ),
                        backgroundColor: Color.fromARGB(255, 22, 91, 126),
                      ),
                      Lottie.asset('assets/animations/voice.json',
                          width: 200, height: 200),
                      const FloatingActionButton(
                        onPressed: null,
                        child: Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                        ),
                        backgroundColor: Color.fromARGB(255, 128, 54, 58),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }
}

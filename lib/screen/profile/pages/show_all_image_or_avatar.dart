import 'package:card_swiper/card_swiper.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ShowAllImageOrAvatar extends StatefulWidget {
  final int imageCount;
  final String roomUid;

  ShowAllImageOrAvatar(Key? key, this.imageCount, this.roomUid)
      : super(key: key);

  @override
  State<ShowAllImageOrAvatar> createState() => _ShowAllImageOrAvatarState();
}

class _ShowAllImageOrAvatarState extends State<ShowAllImageOrAvatar> {
  final SwiperController _swiperController = SwiperController();
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isDesktop())
              StreamBuilder<int>(
                  stream: _currentIndex.stream,
                  builder: (context, indexSnapShot) {
                    if (indexSnapShot.hasData && indexSnapShot.data! > 0) {
                      return IconButton(
                          onPressed: () {
                            _swiperController.previous();
                          },
                          icon: const Icon(Icons.arrow_back_ios_new_outlined));
                    } else {
                      return const SizedBox(width: 5,);
                    }
                  }),
            SizedBox(
              width: 500,
              height: 500,
              child: Swiper(
                itemCount: widget.imageCount,
                controller: _swiperController,
                onIndexChanged: (index) => _currentIndex.add(index),
                itemBuilder: (c, index) {
                  return Center(
                    child: Text("$index"),
                  );
                },
              ),
            ),
            if (isDesktop())
              StreamBuilder<int>(
                  stream: _currentIndex.stream,
                  builder: (context, indexSnapShot) {
                    if (indexSnapShot.hasData &&
                        indexSnapShot.data! != widget.imageCount) {
                      return IconButton(
                          onPressed: () {
                            _swiperController.next();
                          },
                          icon: const Icon(Icons.arrow_forward_ios_outlined));
                    } else {
                      return const SizedBox(width: 5,);
                    }
                  }),
          ],
        ),
      ),
    );
  }
}

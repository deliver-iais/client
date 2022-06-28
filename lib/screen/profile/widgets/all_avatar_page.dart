import 'dart:io';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:rxdart/rxdart.dart';

class AllAvatarPage extends StatefulWidget {
  final String? heroTag;
  final Uid userUid;
  final bool hasPermissionToDeletePic;

  const AllAvatarPage({
    super.key,
    required this.userUid,
    required this.hasPermissionToDeletePic,
    required this.heroTag,
  });

  @override
  AllAvatarPageState createState() => AllAvatarPageState();
}

class AllAvatarPageState extends State<AllAvatarPage> {
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _streamKey = GlobalKey();
  List<Avatar?> _avatars = [];
  final _fileCache = LruCache<String, String>(storage: InMemoryStorage(50));
  final BehaviorSubject<int> _swipePositionSubject = BehaviorSubject.seeded(0);
  final BehaviorSubject<bool> _isBarShowing = BehaviorSubject.seeded(true);
  final _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _fileCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag!,
      child: StreamBuilder<List<Avatar?>>(
        key: _streamKey,
        stream: _avatarRepo.getAvatar(widget.userUid),
        builder: (cont, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _avatars = snapshot.data!;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                systemNavigationBarColor: Colors.black,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
              child: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: buildAppBar(snapshot.data!.length),
                body: Container(
                  color: Colors.black,
                  child: Row(
                    children: [
                      if (isDesktop)
                        StreamBuilder<int>(
                          stream: _swipePositionSubject,
                          builder: (context, indexSnapShot) {
                            if (indexSnapShot.hasData &&
                                indexSnapShot.data! > 0) {
                              return IconButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: SLOW_ANIMATION_DURATION,
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                ),
                              );
                            } else {
                              return const SizedBox(
                                width: 40,
                              );
                            }
                          },
                        ),
                      Expanded(
                        child: PhotoViewGallery.builder(
                          scrollPhysics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          pageController: _pageController,
                          onPageChanged: (index) =>
                              _swipePositionSubject.add(index),
                          builder: (c, index) {
                            return PhotoViewGalleryPageOptions.customChild(
                              onTapDown: (c, t, p) =>
                                  _isBarShowing.add(!_isBarShowing.value),
                              child: FutureBuilder<String?>(
                                future: _fileRepo.getFile(
                                  snapshot.data![index]!.fileId!,
                                  snapshot.data![index]!.fileName!,
                                ),
                                builder: (c, filePath) {
                                  if (filePath.hasData &&
                                      filePath.data != null) {
                                    return InteractiveViewer(
                                      child: Center(
                                        child: isWeb
                                            ? Image.network(filePath.data!)
                                            : Image.file(File(filePath.data!)),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    );
                                  }
                                },
                              ),
                              initialScale: PhotoViewComputedScale.contained,
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 4.1,
                            );
                          },
                        ),
                      ),
                      if (isDesktop)
                        StreamBuilder<int>(
                          stream: _swipePositionSubject,
                          builder: (context, indexSnapShot) {
                            if (indexSnapShot.hasData &&
                                indexSnapShot.data! !=
                                    snapshot.data!.length - 1) {
                              return IconButton(
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: SLOW_ANIMATION_DURATION,
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: const Icon(
                                  Icons.arrow_forward_ios_outlined,
                                ),
                              );
                            } else {
                              return const SizedBox(
                                width: 40,
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  PreferredSizeWidget buildAppBar(int totalLength) {
    return BlurredPreferredSizedWidget(
      child: StreamBuilder<bool>(
        initialData: true,
        stream: _isBarShowing,
        builder: (context, snapshot) {
          return AnimatedOpacity(
            duration: ANIMATION_DURATION,
            opacity: snapshot.data! ? 1 : 0,
            child: snapshot.data!
                ? AppBar(
                    iconTheme: const IconThemeData(
                      color: Colors.white, //change your color here
                    ),
                    backgroundColor: Colors.black.withAlpha(120),
                    leading: _routingService.backButtonLeading(),
                    title: Align(
                      alignment: Alignment.topLeft,
                      child: StreamBuilder<int>(
                        stream: _swipePositionSubject,
                        builder: (c, position) {
                          if (position.hasData && position.data != null) {
                            return Text(
                              "${position.data! + 1} of $totalLength",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                    actions: [
                      if (widget.hasPermissionToDeletePic)
                        PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                          ),
                          itemBuilder: (cc) => [
                            PopupMenuItem(
                              child: const Text("delete"),
                              onTap: () async {
                                await _avatarRepo.deleteAvatar(
                                  _avatars[_swipePositionSubject.value]!,
                                );
                                _avatars.clear();
                                setState(() {});
                              },
                            ),
                          ],
                        )
                    ],
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

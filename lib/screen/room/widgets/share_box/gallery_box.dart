import 'dart:io';

import 'package:deliver/screen/room/widgets/share_box/cemara_box.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery_folder.dart';
import 'package:deliver/services/camera_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

class GalleryBox extends StatefulWidget {
  final ScrollController scrollController;
  final Uid roomUid;
  final int replyMessageId;
  final void Function() pop;
  final void Function(String)? onAvatarSelected;
  final void Function()? resetRoomPageDetails;
  final bool selectAsAvatar;

  const GalleryBox({
    super.key,
    required this.scrollController,
    required this.pop,
    required this.roomUid,
    this.onAvatarSelected,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
    this.selectAsAvatar = false,
  });

  @override
  GalleryBoxState createState() => GalleryBoxState();
}

class GalleryBoxState extends State<GalleryBox> {
  final _cameraService = GetIt.I.get<CameraService>();
  static final _checkPermissionServices =
      GetIt.I.get<CheckPermissionsService>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final BehaviorSubject<List<AssetPathEntity>> _folders =
      BehaviorSubject.seeded([]);

  @override
  void initState() {
    _initFolders();
    super.initState();
  }

  Future<void> _initFolders() async {
    if (await checkAccessMediaLocationPermission()) {
      final folders =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      final finalFolders = <AssetPathEntity>[];

      for (final f in folders) {
        if ((await f.assetCountAsync) > 0) {
          finalFolders.add(f);
        }
      }
      _folders.add(finalFolders);
    }
    await _checkPermissionServices.checkCameraRecorderPermission();
  }

  Future<bool> checkAccessMediaLocationPermission() async {
    return _checkPermissionServices.checkAccessMediaLocationPermission(
      context: context,
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surfaceVariant,
      body: FutureBuilder<bool>(
        initialData: false,
        future: _cameraService.initCamera(),
        builder: (c, hasCameraSnapshot) {
          final hasCamera = hasCameraSnapshot.hasData &&
              hasCameraSnapshot.data != null &&
              hasCameraSnapshot.data!;
          return StreamBuilder<List<AssetPathEntity>?>(
            stream: _folders,
            builder: (context, snap) {
              if (snap.hasData && snap.data != null) {
                final folders = snap.data!;
                return GridView.builder(
                  controller: widget.scrollController,
                  itemCount: hasCamera ? folders.length + 1 : folders.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (co, index) {
                    if (hasCamera && index == 0) {
                      return Container(
                        clipBehavior: Clip.hardEdge,
                        margin: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Theme.of(co).primaryColor,
                          borderRadius: secondaryBorder,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CameraBox(
                                onAvatarSelected: widget.onAvatarSelected,
                                selectAsAvatar: widget.selectAsAvatar,
                                roomUid: widget.roomUid,
                              ),
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _cameraService.buildPreview(),
                              const Center(
                                child: Icon(
                                  CupertinoIcons.camera,
                                  size: 40,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      final folder = folders[hasCamera ? index - 1 : index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            co,
                            MaterialPageRoute(
                              builder: (c) {
                                return GalleryFolder(
                                  folder,
                                  widget.roomUid,
                                  () => Navigator.pop(context),
                                  onAvatarSelected: widget.onAvatarSelected,
                                  selectAsAvatar: widget.selectAsAvatar,
                                  replyMessageId: widget.replyMessageId,
                                  resetRoomPageDetails:
                                      widget.resetRoomPageDetails,
                                );
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: FutureBuilder<List<AssetEntity>>(
                            future: folder.getAssetListPaged(page: 0, size: 2),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return Stack(
                                  children: buildGallery(
                                    snapshot.data!,
                                    folder.name,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  List<Widget> buildGallery(List<AssetEntity> assets, String folderName) {
    final theme = Theme.of(context);

    return <Widget>[
      for (var i = 0; i < assets.length; i++)
        Positioned(
          right: i * 6 + 10,
          top: (1 - i) * 7 + 6,
          child: FutureBuilder<File?>(
            future: assets[i].file,
            builder: (context, fileSnapshot) {
              if (fileSnapshot.hasData && fileSnapshot.data != null) {
                return Container(
                  width: MediaQuery.of(context).size.width / 2 - 40 - (i * 12),
                  height: MediaQuery.of(context).size.width / 2 - 40 - (i * 12),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: secondaryBorder,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 4), // changes position of shadow
                      ),
                    ],
                    image: DecorationImage(
                      image: Image.file(
                        fileSnapshot.data!,
                        cacheWidth: 200,
                        height: ((2 - i) * 10) + 480,
                      ).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: i == 0
                      ? Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            padding: const EdgeInsets.only(
                              top: 6,
                              bottom: 4,
                              left: 6,
                              right: 4,
                            ),
                            width: MediaQuery.of(context).size.width / 2 - 40,
                            decoration: BoxDecoration(
                              borderRadius: secondaryBorder.copyWith(
                                topLeft: Radius.zero,
                                topRight: Radius.zero,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      theme.colorScheme.shadow.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(
                                    0,
                                    3,
                                  ), // changes position of shadow
                                ),
                              ],
                              color: theme.colorScheme.onSurfaceVariant,
                              // borderRadius: mainBorder,
                            ),
                            child: Text(
                              folderName,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.surfaceVariant,
                                  ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
    ].reversed.toList();
  }
}

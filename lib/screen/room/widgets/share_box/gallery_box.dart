import 'dart:io';
import 'dart:math';

import 'package:deliver/screen/room/widgets/share_box/file_box_item_icon.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery_folder.dart';
import 'package:deliver/services/camera_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

class GalleryBox extends StatefulWidget {
  final ScrollController scrollController;
  final Uid? roomUid;
  final int replyMessageId;
  final void Function(String)? onAvatarSelected;
  final void Function()? resetRoomPageDetails;
  final bool selectAsAvatar;

  const GalleryBox({
    super.key,
    required this.scrollController,
    required this.roomUid,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
  })  : selectAsAvatar = false,
        onAvatarSelected = null;

  const GalleryBox.setAvatar({
    super.key,
    required this.scrollController,
    this.roomUid,
    this.onAvatarSelected,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
  }) : selectAsAvatar = true;

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
  final BehaviorSubject<bool> _canInitCamera = BehaviorSubject.seeded(false);

  final _routingService = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    _initFolders();
    super.initState();
  }

  Future<void> _initFolders() async {
    try {
      if (await checkAccessMediaLocationPermission()) {
        await PhotoManager.requestPermissionExtend();
        final folders =
            await PhotoManager.getAssetPathList(type: RequestType.image);
        final finalFolders = <AssetPathEntity>[];

        for (final f in folders) {
          if ((await f.assetCountAsync) > 0) {
            finalFolders.add(f);
          }
        }
        finalFolders.sort((a, b) => _checkName(a.name) - _checkName(b.name));
        _folders.add(finalFolders);
      }
      await _checkPermissionServices.checkCameraRecorderPermission();
      await _cameraService
          .initCamera()
          .then((value) => _canInitCamera.add(value));
    } catch (_) {
      print(_);
    }
  }

  int _checkName(String name) => name.toLowerCase().contains("camera") ? 0 : 1;

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
      body: StreamBuilder(
        stream: MergeStream([_folders, _canInitCamera]),
        builder: (context, snap) {
          final hasCamera = _canInitCamera.value;
          if (snap.hasData && snap.data != null) {
            return GridView.builder(
              controller: widget.scrollController,
              itemCount: _folders.value.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (co, index) {
                if (index == 0) {
                  return Container(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(co).colorScheme.primary,
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
                      onTap: () async {
                        if (hasCamera) {
                          await _cameraService.enableRecordAudio();
                        }
                        _routingService.openCameraBox(
                          selectAsAvatar: widget.selectAsAvatar,
                          roomUid: widget.roomUid,
                          onAvatarSelected: widget.onAvatarSelected,
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasCamera) _cameraService.buildPreview(),
                          const Center(
                            child: Icon(
                              CupertinoIcons.camera,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  final folder = _folders.value[index - 1];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        co,
                        MaterialPageRoute(
                          builder: (c) {
                            return GalleryFolder(
                              folder,
                              roomUid: widget.roomUid,
                              () => Navigator.pop(context),
                              onAvatarSelected: widget.onAvatarSelected,
                              selectAsAvatar: widget.selectAsAvatar,
                              replyMessageId: widget.replyMessageId,
                              resetRoomPageDetails: widget.resetRoomPageDetails,
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
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
      ),
    );
  }

  List<Widget> buildGallery(List<AssetEntity> assets, String folderName) {
    final theme = Theme.of(context);

    return <Widget>[
      for (var i = 0; i < min(assets.length, 2); i++)
        Positioned(
          right: i * 6 + 10,
          top: (1 - i) * 7 + 6,
          child: FutureBuilder<File?>(
            future: assets[i].file,
            builder: (context, fileSnapshot) {
              if (fileSnapshot.hasData && fileSnapshot.data != null) {
                if (!isVideo(fileSnapshot.data!.path)) {
                  return Container(
                    width:
                        MediaQuery.of(context).size.width / 2 - 40 - (i * 12),
                    height:
                        MediaQuery.of(context).size.width / 2 - 40 - (i * 12),
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
                          offset: const Offset(
                            0,
                            4,
                          ), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                        image: Image.file(
                          fileSnapshot.data!,
                          cacheWidth: 200,
                          cacheHeight: ((2 - i) * 10) + 480,
                        ).image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: i == 0
                        ? Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              padding: const EdgeInsetsDirectional.only(
                                top: 6,
                                bottom: 4,
                                start: 6,
                                end: 4,
                              ),
                              width: MediaQuery.of(context).size.width / 2 - 40,
                              decoration: BoxDecoration(
                                borderRadius: secondaryBorder.copyWith(
                                  topLeft: Radius.zero,
                                  topRight: Radius.zero,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow
                                        .withOpacity(0.5),
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

                return Container(
                  decoration: const BoxDecoration(
                    // border: Border.all(width: 1.0),
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        15.0,
                      ), //
                    ),
                  ),
                  width: MediaQuery.of(context).size.width / 2 - 40 - (i * 12),
                  height: MediaQuery.of(context).size.width / 2 - 40 - (i * 12),
                  child: Stack(
                    children: [
                      FileIcon(
                        file: fileSnapshot.data!,
                        width: 150,
                        height: 150,
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).highlightColor,
                            // border: Border.all(width: 1.0),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                6.0,
                              ), //
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.video_camera_solid,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
    ].reversed.toList();
  }
}

import 'dart:io';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/share_box/image_folder_widget.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:image_picker/image_picker.dart';

import 'helper_classes.dart';

class ShareBoxGallery extends StatefulWidget {
  final ScrollController scrollController;
  final Function? setAvatar;
  final bool selectAvatar;
  final Uid roomUid;

  const ShareBoxGallery(
      {Key? key,
      required this.selectAvatar,
      required this.scrollController,
      this.setAvatar,
      required this.roomUid})
      : super(key: key);

  @override
  _ShareBoxGalleryState createState() => _ShareBoxGalleryState();
}

class _ShareBoxGalleryState extends State<ShareBoxGallery> {
  final i18n = GetIt.I.get<I18N>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<StorageFile>> _future;

  @override
  void initState() {
    _future = ImageItem.getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StorageFile>?>(
        key: _scaffoldKey,
        future: _future,
        builder: (context, folders) {
          if (folders.hasData &&
              folders.data != null &&
              folders.data!.isNotEmpty) {
            return GridView.builder(
                controller: widget.scrollController,
                itemCount: folders.data!.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  StorageFile? folder =
                      index > 0 ? folders.data![index - 1] : null;
                  if (index <= 0) {
                    return Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.photo_camera,
                            color: Colors.white, size: 40),
                        onPressed: () async {
                          try {
                            Navigator.pop(context);
                            final picker = ImagePicker();
                            XFile? pickedFile = await picker.pickImage(
                                source: ImageSource.camera);
                            if (pickedFile != null) {
                              !widget.selectAvatar
                                  ? showCaptionDialog(
                                      roomUid: widget.roomUid,
                                      context: context,
                                      paths: [pickedFile.path],
                                      type: pickedFile.path.split(".").last)
                                  : widget.setAvatar!(pickedFile.path);
                            }
                          } catch (_) {}
                        },
                      ),
                    );
                  } else {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (c) {
                            return ImageFolderWidget(
                              folder!,
                              widget.roomUid,
                              () {
                                Navigator.pop(context);
                              },
                              selectAvatar: widget.selectAvatar,
                              setAvatar: widget.setAvatar,
                            );
                          }));
                        },
                        child: AnimatedPadding(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          child: Hero(
                            tag: folder!.folderName,
                            child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  image: DecorationImage(
                                      image: Image.file(
                                        File(
                                          folder.files.first,
                                        ),
                                        cacheWidth: 300,
                                        cacheHeight: 300,
                                      ).image,
                                      fit: BoxFit.cover),
                                ),
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    widthFactor: 200,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        folder.folderName,
                                        style: const TextStyle(
                                            fontSize: 15, color: Colors.black),
                                      ),
                                    ))),
                          ),
                        ));
                  }
                });
          }
          return const SizedBox.shrink();
        });
  }
}

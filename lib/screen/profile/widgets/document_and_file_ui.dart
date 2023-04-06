import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/metaRepo.dart';

import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DocumentAndFileUi extends StatefulWidget {
  final Uid roomUid;
  final int documentCount;
  final MetaType type;
  final void Function(Meta) addSelectedMeta;
  final List<Meta> selectedMeta;

  const DocumentAndFileUi({
    super.key,
    required this.roomUid,
    required this.documentCount,
    required this.type,
    required this.addSelectedMeta,
    required this.selectedMeta,
  });

  @override
  DocumentAndFileUiState createState() => DocumentAndFileUiState();
}

class DocumentAndFileUiState extends State<DocumentAndFileUi> {
  static final _metaRepo = GetIt.I.get<MetaRepo>();
  static final _fileRepo = GetIt.I.get<FileRepo>();
  final _metaCache = <int, Meta>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: widget.documentCount,
      itemBuilder: (c, index) {
        return FutureBuilder<Meta?>(
          future: _metaRepo.getAndCacheMetaPage(
            widget.documentCount - index,
            MetaType.FILE,
            widget.roomUid.asString(),
            _metaCache,
          ),
          builder: (c, mediaSnapshot) {
            if (mediaSnapshot.hasData) {
              if (mediaSnapshot.data!.isDeletedMeta()) {
                return const SizedBox.shrink();
              }
              final filePb = mediaSnapshot.data!.json.toFile();

              return GestureDetector(
                onLongPress: () => widget.addSelectedMeta(mediaSnapshot.data!),
                onTap: () => widget.addSelectedMeta(mediaSnapshot.data!),
                child: Container(
                  color: widget.selectedMeta.contains(mediaSnapshot.data)
                      ? theme.hoverColor.withOpacity(0.4)
                      : theme.colorScheme.background,
                  child: FutureBuilder<String?>(
                    future: _fileRepo.getFileIfExist(
                      filePb.uuid,
                      filePb.name,
                    ),
                    builder: (context, filePath) {
                      if (filePath.hasData && filePath.data != null) {
                        return Column(
                          children: [
                            ListTile(
                              title: GestureDetector(
                                onTap: () => _fileRepo.openFile(filePath.data!),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsetsDirectional.only(
                                        start: 2,
                                      ),
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                      child: IconButton(
                                        padding: const EdgeInsets.only(left: 1),
                                        icon: Icon(
                                          Icons.insert_drive_file_sharp,
                                          color: theme.colorScheme.primary,
                                          size: 35,
                                        ),
                                        onPressed: () => _fileRepo.openFile(
                                          filePath.data!,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(
                                              start: 15.0,
                                              top: 3,
                                            ),
                                            child: Text(
                                              filePb.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  LoadFileStatus(
                                    file: filePb,
                                    isUploading: false,
                                    onDownloadCompleted: (_) => setState(() {}),
                                    background: theme.colorScheme.primary,
                                    foreground: theme.colorScheme.onPrimary,
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            start: 15.0,
                                            top: 3,
                                          ),
                                          child: Text(
                                            filePb.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              );
            } else {
              return Container(
                height: 100,
              );
            }
          },
        );
      },
    );
  }
}

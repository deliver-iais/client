import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/screen/profile/widgets/music_play_progress.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MusicAndAudioUi extends StatefulWidget {
  final Uid roomUid;
  final int audioCount;
  final MetaType type;
  final void Function(Meta) addSelectedMeta;
  final List<Meta> selectedMeta;

  const MusicAndAudioUi({
    super.key,
    required this.roomUid,
    required this.type,
    required this.audioCount,
    required this.addSelectedMeta,
    required this.selectedMeta,
  });

  @override
  MusicAndAudioUiState createState() => MusicAndAudioUiState();
}

class MusicAndAudioUiState extends State<MusicAndAudioUi> {
  static final _audioPlayerService = GetIt.I.get<AudioService>();
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _metaCache = <int, Meta>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: widget.audioCount,
      itemBuilder: (c, index) {
        return FutureBuilder<Meta?>(
          future: _metaRepo.getAndCacheMetaPage(
            widget.audioCount - index,
            widget.type,
            widget.roomUid.asString(),
            _metaCache,
          ),
          builder: (c, snapShot) {
            if (snapShot.hasData &&
                snapShot.data != null ) {
              if(snapShot.data!.isDeletedMeta()){
                return const SizedBox.shrink();
              }
              final filePb = snapShot.data!.json.toFile();
              final fileUuid = filePb.uuid;
              final fileName = filePb.name;
              final fileDuration = filePb.duration;

              return GestureDetector(
                onLongPress: () => widget.addSelectedMeta(snapShot.data!),
                onTap: () => widget.addSelectedMeta(snapShot.data!),
                child: Container(
                  color: widget.selectedMeta.contains(snapShot.data)
                      ? theme.hoverColor.withOpacity(0.4)
                      : theme.colorScheme.background,
                  child: FutureBuilder<String?>(
                    future: _fileRepo.getFileIfExist(fileUuid, fileName),
                    builder: (context, filePath) {
                      if (filePath.hasData && filePath.data != null) {
                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  PlayAudioStatus(
                                    uuid: fileUuid,
                                    filePath: filePath.data!,
                                    name: fileName,
                                    duration: fileDuration,
                                    backgroundColor:
                                        theme.colorScheme.onPrimary,
                                    foregroundColor: theme.colorScheme.primary,
                                    // TODO(any): auto audio play for profile
                                    onAudioPlay: () {},
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(
                                            start: 8,
                                            top: 10,
                                          ),
                                          child: Text(
                                            fileName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(
                                            top: 20,
                                            bottom: 10,
                                            start: 8,
                                          ),
                                          child: MusicPlayProgress(
                                            audioUuid: fileUuid,
                                            duration: fileDuration,
                                            file: filePb,
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
                      } else {
                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  LoadFileStatus(
                                    file: filePb,
                                    isUploading: false,
                                    onDownloadCompleted: (audioPath) {
                                      setState(() {});
                                      if (audioPath != null) {
                                        _audioPlayerService.playAudioMessage(
                                          audioPath,
                                          fileUuid,
                                          fileName,
                                          fileDuration,
                                        );
                                      }
                                    },
                                    background: theme.colorScheme.primary,
                                    foreground: theme.colorScheme.onPrimary,
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(
                                            start: 8.0,
                                            top: 8,
                                          ),
                                          child: Text(
                                            fileName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        MusicPlayProgress(
                                          audioUuid: fileUuid,
                                          duration: fileDuration,
                                          file: filePb,
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
              return Container(height: 1000,);
            }
          },
        );
      },
    );
  }
}

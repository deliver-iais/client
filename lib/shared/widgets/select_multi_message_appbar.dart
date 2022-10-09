import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:share/share.dart';

class SelectMultiMessageAppBar extends StatelessWidget {
  final Map<int, Message> selectedMessages;
  final bool hasPermissionInChannel;
  final bool hasPermissionInGroup;
  final Function() onClose;
  final Function() deleteSelectedMessage;

  SelectMultiMessageAppBar({
    super.key,
    required this.selectedMessages,
    required this.hasPermissionInChannel,
    required this.hasPermissionInGroup,
    required this.onClose,
    required this.deleteSelectedMessage,
  });

  final _authRepo = GetIt.I.get<AuthRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var hasPermissionToDeleteMsg = true;
    var shareType = MessageType.FILE;
    var canShareMessage = true;

    for (final message in selectedMessages.values.toList()) {
      if ((_authRepo.isCurrentUserSender(message) ||
              (message.roomUid.isChannel() && hasPermissionInChannel) ||
              (message.roomUid.isGroup() && hasPermissionInGroup)) ==
          false) {
        hasPermissionToDeleteMsg = false;
      }
    }
    for (final message in selectedMessages.values.toList()) {
      if (message.type != MessageType.FILE && shareType == MessageType.FILE) {
        shareType = MessageType.TEXT;
      }
      if (message.type != MessageType.TEXT &&
          message.type != MessageType.FILE) {
        canShareMessage = false;
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: _i18n.get("forward"),
            child: IconButton(
              color: theme.primaryColor,
              icon: const Icon(CupertinoIcons.arrowshape_turn_up_right),
              onPressed: () {
                _routingService.openSelectForwardMessage(
                  forwardedMessages: selectedMessages.values.toList(),
                );
                selectedMessages.clear();
              },
            ),
          ),
          if (hasPermissionToDeleteMsg)
            Tooltip(
              message: _i18n.get("delete"),
              child: IconButton(
                color: theme.primaryColor,
                icon: const Icon(CupertinoIcons.delete),
                onPressed: () {
                  deleteSelectedMessage();
                },
              ),
            ),
          if (canShareMessage && isAndroid)
            Tooltip(
              message: _i18n.get("share"),
              child: IconButton(
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.share),
                onPressed: () async {
                  var copyText = "";
                  final messages = selectedMessages.values.toList()
                    ..sort(
                      (a, b) => a.id == null
                          ? 1
                          : b.id == null
                              ? -1
                              : a.id!.compareTo(b.id!),
                    );
                  if (shareType == MessageType.TEXT) {
                    for (final message in messages) {
                      if (message.type == MessageType.TEXT) {
                        copyText =
                            "$copyText${await _roomRepo.getName(message.from.asUid())}:\n${message.json.toText().text}";
                      } else if (message.type == MessageType.FILE) {
                        final type = message.json.toFile().type;
                        var fileType = "🖼";
                        if (type.contains("image")) {
                          fileType = "🖼";
                        } else if (type.contains("video")) {
                          fileType = "🎥";
                        } else if (type.contains("audio")) {
                          fileType = "🎵";
                        }

                        copyText =
                            "$copyText${await _roomRepo.getName(message.from.asUid())}:\n$fileType\n${message.json.toFile().caption}";
                      }
                      copyText =
                          "$copyText\n${DateTime.fromMillisecondsSinceEpoch(
                        message.time,
                      ).toString().substring(0, 19)}\n";
                    }

                    Share.share(
                      copyText,
                    ).ignore();
                  } else if (shareType == MessageType.FILE) {
                    final paths = <String>[];
                    for (final message in messages) {
                      final path = await _fileRepo.getFileIfExist(
                        message.json.toFile().uuid,
                        message.json.toFile().name,
                      );
                      if (path != null) {
                        paths.add(path);
                      } else {
                        ToastDisplay.showToast(
                          toastText: _i18n.get("download_file_to_share"),
                          toastContext: context,
                        );
                      }
                    }

                    Share.shareFiles(
                      paths,
                    ).ignore();
                  }

                  Clipboard.setData(ClipboardData(text: copyText)).ignore();
                  onClose();
                },
              ),
            ),
          Tooltip(
            message: _i18n.get("copy"),
            child: IconButton(
              color: Theme.of(context).primaryColor,
              icon: const Icon(CupertinoIcons.doc_on_clipboard),
              onPressed: () async {
                var copyText = "";
                final messages = selectedMessages.values.toList()
                  ..sort(
                    (a, b) => a.id == null
                        ? 1
                        : b.id == null
                            ? -1
                            : a.id!.compareTo(b.id!),
                  );
                for (final message in messages) {
                  if (message.type == MessageType.TEXT) {
                    copyText =
                        "$copyText${await _roomRepo.getName(message.from.asUid())}:\n${synthesizeToOriginalWord(message.json.toText().text)}\n";
                  } else if (message.type == MessageType.FILE &&
                      message.json.toFile().caption.isNotEmpty) {
                    copyText =
                        "$copyText${await _roomRepo.getName(message.from.asUid())}:\n${synthesizeToOriginalWord(
                      message.json.toFile().caption,
                    )}\n";
                  }
                }
                saveToClipboard(
                  copyText,
                  context: context,
                );
                onClose();
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty('hasPermissionInGroup', hasPermissionInGroup));
  }
}

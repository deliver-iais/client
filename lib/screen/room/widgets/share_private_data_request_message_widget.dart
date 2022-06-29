import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/attach_location.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SharePrivateDataRequestMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final double maxWidth;
  final CustomColorScheme colorScheme;

  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  const SharePrivateDataRequestMessageWidget({
    super.key,
    required this.message,
    required this.isSender,
    required this.maxWidth,
    required this.colorScheme,
    required this.isSeen,
  });

  @override
  Widget build(BuildContext context) {
    final sharePrivateDataRequest = message.json.toSharePrivateDataRequest();

    var label = "";
    switch (sharePrivateDataRequest.data) {
      case PrivateDataType.NAME:
        label = _i18n.get("get_access_name");
        break;
      case PrivateDataType.EMAIL:
        label = _i18n.get("get_access_email");
        break;
      case PrivateDataType.FILE:
        label = _i18n.get("click_to_send_file");
        break;
      case PrivateDataType.LOCATION:
        label = _i18n.get("click_to_send_location");
        break;
      case PrivateDataType.PHONE_NUMBER:
        label = _i18n.get("get_access_phone_number");
        break;
      case PrivateDataType.USERNAME:
        label = _i18n.get("get_access_username");
        break;
    }
    return Column(
      children: [
        if (sharePrivateDataRequest.description.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
                .copyWith(bottom: 0),
            width: maxWidth,
            child: Text(
              sharePrivateDataRequest.description,
              textDirection: sharePrivateDataRequest.description.isPersian()
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.all(4.0),
              constraints: const BoxConstraints(minHeight: 35),
              width: maxWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: colorScheme.primary,
                  onPrimary: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (sharePrivateDataRequest.data == PrivateDataType.FILE) {
                    _attachFile(sharePrivateDataRequest, context);
                  } else if (sharePrivateDataRequest.data ==
                      PrivateDataType.LOCATION) {
                    if (isAndroid || isIOS) {
                      showModalBottomSheet(
                        context: context,
                        builder: (c) {
                          return DraggableScrollableSheet(
                            initialChildSize: 1,
                            builder: (c, s) {
                              return AttachLocation(
                                context,
                                message.roomUid.asUid(),
                              ).showLocation();
                            },
                          );
                        },
                      );
                    } else {
                      if (isWindows || isMacOS) {
                        AttachLocation(context, message.roomUid.asUid())
                            .attachLocationInWindows();
                      } else {
                        ToastDisplay.showToast(
                          toastContext: context,
                          toastText: _i18n
                              .get("get_location_not_support_in_your_device"),
                        );
                      }
                    }
                  } else {
                    _showGetAccessPrivateData(context, sharePrivateDataRequest);
                  }
                },
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            TimeAndSeenStatus(
              message,
              isSender: isSender,
              isSeen: isSeen,
              needsPositioned: false,
              needsPadding: true,
            )
          ],
        ),
      ],
    );
  }

  Future<void> _attachFile(
    SharePrivateDataRequest sharePrivateDataRequest,
    BuildContext context,
  ) async {
    final res = <File>[];
    final types = sharePrivateDataRequest.fileTypeFilter.memeTypeFilter;
    if (isLinux) {
      final typeGroup = <XTypeGroup>[];
      for (final type in types) {
        typeGroup
            .add(XTypeGroup(label: type.superType, mimeTypes: [type.subType]));
      }

      final result = await openFiles(acceptedTypeGroups: typeGroup);
      for (final file in result) {
        res.add(
          File(
            file.path,
            file.name,
            extension: file.mimeType,
            size: await file.length(),
          ),
        );
      }
    } else {
      final type = types.isEmpty ? FileType.any : FileType.custom;
      final allowedExtensions = <String>[];
      for (final type in types) {
        allowedExtensions.add(type.subType);
      }

      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        for (final file in result.files) {
          res.add(
            File(
              isWeb
                  ? Uri.dataFromBytes(file.bytes!.toList()).toString()
                  : file.path!,
              file.name,
              size: file.size,
              extension: file.extension,
            ),
          );
        }
      }
    }
    showCaptionDialog(
      roomUid: message.roomUid.asUid(),
      context: context,
      files: res,
    );
  }

  void _showGetAccessPrivateData(
    BuildContext context,
    SharePrivateDataRequest sharePrivateDataRequest,
  ) {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          content: Text(
            sharePrivateDataRequest.data == PrivateDataType.PHONE_NUMBER
                ? _i18n.get("access_phone_number")
                : sharePrivateDataRequest.data == PrivateDataType.EMAIL
                    ? _i18n.get("access_email")
                    : sharePrivateDataRequest.data == PrivateDataType.NAME
                        ? _i18n.get("access_name")
                        : _i18n.get("access_username"),
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(_i18n.get("cancel")),
              onPressed: () => Navigator.pop(c),
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _messageRepo.sendPrivateDataAcceptanceMessage(
                  message.from.asUid(),
                  sharePrivateDataRequest.data,
                  sharePrivateDataRequest.token,
                );
                Navigator.pop(c);
              },
              child: Text(_i18n.get("ok")),
            ),
          ],
        );
      },
    );
  }
}

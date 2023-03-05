import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class OperationOnMedia extends PopupMenuEntry<OperationOnMessage> {
  final Future<Message?> Function() getMessage;

  const OperationOnMedia({
    super.key,
    required this.getMessage,
  });

  @override
  OperationOnImageState createState() => OperationOnImageState();

  @override
  double get height => 100;

  @override
  bool represents(OperationOnMessage? value) =>
      value == OperationOnMessage.REPLY;
}

class OperationOnImageState extends State<OperationOnMedia> {
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: Column(
        children: [
          if (isDesktopNative) ...[
            _buildPopupMenuItem(
              _i18n.get("show_in_folder"),
              CupertinoIcons.folder_open,
              () async {
                final message = await (widget.getMessage());
                if (context.mounted) {
                  return OperationOnMessageSelection(
                    message: message!,
                    context: context,
                  ).selectOperation(
                    OperationOnMessage.SHOW_IN_FOLDER,
                  );
                }
              },
            ),
            _buildPopupMenuItem(
              _i18n.get("save_to_downloads"),
              CupertinoIcons.down_arrow,
              () async {
                final message = await (widget.getMessage());
                if (context.mounted) {
                  return OperationOnMessageSelection(
                    message: message!,
                    context: context,
                  ).selectOperation(
                    OperationOnMessage.SAVE_TO_DOWNLOADS,
                  );
                }
              },
            ),
            _buildPopupMenuItem(
              _i18n.get("save_as"),
              Icons.save_alt_rounded,
              () async {
                final message = await (widget.getMessage());
                if (context.mounted) {
                  return OperationOnMessageSelection(
                    message: message!,
                    context: context,
                  ).selectOperation(
                    OperationOnMessage.SAVE_AS,
                  );
                }
              },
            ),
          ],
          if (isAndroidNative)
            _buildPopupMenuItem(
              _i18n.get("share"),
              Icons.share_rounded,
              () async {
                final message = await (widget.getMessage());
                if (context.mounted) {
                  return OperationOnMessageSelection(
                    message: message!,
                    context: context,
                  ).selectOperation(
                    OperationOnMessage.SHARE,
                  );
                }
              },
            ),
          if (isMobileNative)
            _buildPopupMenuItem(
              _i18n.get("save_to_gallery"),
              CupertinoIcons.down_arrow,
              () async {
                final message = await (widget.getMessage());
                if (context.mounted) {
                  return OperationOnMessageSelection(
                    message: message!,
                    context: context,
                  ).selectOperation(
                    OperationOnMessage.SAVE_TO_GALLERY,
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPopupMenuItem(String text, IconData icon, VoidCallback onTap) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: () => onTap(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

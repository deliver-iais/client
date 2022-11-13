import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class OperationOnImage extends PopupMenuEntry<OperationOnMessage> {
  final Future<Message?> Function() getMessage;

  const OperationOnImage({
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

class OperationOnImageState extends State<OperationOnImage> {
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: Column(
        children: [
          PopupMenuItem(
            onTap: () async {
              final message = await (widget.getMessage());
              return OperationOnMessageSelection(
                message: message!,
                context: context,
              ).selectOperation(
                OperationOnMessage.SHOW_IN_FOLDER,
              );
            },
            child: Row(
              children: [
                const Icon(CupertinoIcons.folder_open),
                const SizedBox(width: 8),
                Text(
                  _i18n.get("show_in_folder"),
                  style: theme.primaryTextTheme.bodyText2,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              final message = await (widget.getMessage());
              return OperationOnMessageSelection(
                message: message!,
                context: context,
              ).selectOperation(
                OperationOnMessage.SAVE_TO_DOWNLOADS,
              );
            },
            child: Row(
              children: [
                const Icon(CupertinoIcons.down_arrow),
                const SizedBox(width: 8),
                Text(
                  _i18n.get("save_to_downloads"),
                  style: theme.primaryTextTheme.bodyText2,
                )
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              final message = await (widget.getMessage());
              return OperationOnMessageSelection(
                message: message!,
                context: context,
              ).selectOperation(
                OperationOnMessage.SAVE_AS,
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.save_alt_rounded,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  _i18n.get("save_as"),
                  style: theme.primaryTextTheme.bodyText2,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

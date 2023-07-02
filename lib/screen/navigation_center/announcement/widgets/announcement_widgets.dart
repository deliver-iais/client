import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:deliver/shared/methods/colors.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/widgets/timer/count_down_timer_animation.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver_public_protocol/pub/v1/models/announcement.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class AnnouncementWidgets extends StatelessWidget {
  final Announcement announcement;
  final ImageProvider? image;
  final bool isAnnouncementPage;

  AnnouncementWidgets({
    super.key,
    required this.announcement,
    this.image,
    this.isAnnouncementPage = false,
  });

  final _i18n = GetIt.I.get<I18N>();

  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();

  final _fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isAnnouncementPage ? 2 : 0,
      shape: isAnnouncementPage
          ? const RoundedRectangleBorder(borderRadius: mainBorder)
          : const RoundedRectangleBorder(),
      margin: isAnnouncementPage
          ? const EdgeInsetsDirectional.symmetric(
              horizontal: p8,
              vertical: p4,
            )
          : EdgeInsetsDirectional.zero,
      color: isAnnouncementPage
          ? theme.cardColor
          : theme.colorScheme.inverseSurface,
      child: Container(
        width: double.infinity,
        padding: isAnnouncementPage
            ? const EdgeInsets.all(p24)
            : const EdgeInsets.all(p8),
        child: isAnnouncementPage
            ? buildDetailedWidget(context)
            : buildBriefWidget(context),
      ),
    );
  }

  Widget buildBriefWidget(BuildContext context) {
    final (theme, tt) = getTheming(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          announcement.title,
          textDirection: _i18n.getDirection(announcement.details.title),
          style: tt.titleMedium,
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onInverseSurface,
        )
      ],
    );
  }

  Widget buildDetailedWidget(BuildContext context) {
    final (_, tt) = getTheming(context);

    return Column(
      crossAxisAlignment: _i18n.getCrossAxisAlignment(
        announcement.details.title,
      ),
      children: [
        Text(
          announcement.details.title,
          textDirection: _i18n.getDirection(announcement.details.title),
          style: tt.displaySmall,
        ),
        const SizedBox(height: p8),
        Text(
          textDirection: _i18n.getDirection(
            announcement.details.description,
          ),
          announcement.details.description,
          style: tt.bodyMedium,
        ),
        if (announcement.details.animation.uuid.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsetsDirectional.only(top: p16),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: ColorUtils.stringColorToColor(
                announcement.details.primaryColor,
              ),
              borderRadius: mainBorder,
            ),
            child: buildMedia(announcement.details.animation),
          ),
        if (announcement.details.time != 0)
          RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.only(top: p8),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: CountdownTimerAnimation(
                    endIntTime: announcement.details.time.toInt(),
                    color: ColorUtils.stringColorToColor(
                      announcement.details.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (announcement.url.isNotEmpty)
          TextButton(
            onPressed: () => _urlHandlerService.handleNormalLink(
              announcement.url,
            ),
            child: Text(
              announcement.details.urlLabel.ifEmpty(_i18n.get("more")),
            ),
          ),
      ],
    );
  }

  (ThemeData, TextTheme) getTheming(BuildContext context) {
    final theme = Theme.of(context);
    final tt = isAnnouncementPage
        ? theme.textTheme
        : theme.textTheme.apply(
            bodyColor: theme.colorScheme.onInverseSurface,
            displayColor: theme.colorScheme.onInverseSurface,
          );

    return (theme, tt);
  }

  Widget? buildMedia(file_pb.File animation) {
    var animationType = animationFileType(animation.type);

    if (animationType == AnimationType.NONE) {
      animationType = animationFileType(animation.name);
    }

    return FutureBuilder<String?>(
      future: _fileRepo.getFilePathFromFileProto(animation),
      builder: (context, path) {
        if (path.hasData && path.data != null) {
          switch (animationType) {
            case AnimationType.GIF:
              return Image.file(
                File(path.data!),
                fit: BoxFit.cover,
              );
            case AnimationType.JSON:
              return Lottie.file(
                File(path.data!),
                height: 180,
              );
            case AnimationType.WS:
              return Ws.file(
                File(path.data!),
                height: 180,
              );
            case AnimationType.NONE:
              return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver/shared/widgets/out_of_date.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver_public_protocol/pub/v1/lb.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class NewVersion {
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _fileRepo = GetIt.I.get<FileRepo>();

  static Widget newVersionInfo({bool showEveryTime = false}) {
    return StreamBuilder<ClientVersion?>(
      stream: _authRepo.newClientVersionInformation,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final clientVersion = snapshot.data!;
          if (showEveryTime) {
            _newVersionInfo(context, clientVersion);
          } else {
            settings.onceShowNewVersionInformation.once(
              () async {
                await _newVersionInfo(context, clientVersion);
              },
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  static Widget newVersionDownloadingStatusCard(
    BuildContext context,
    BehaviorSubject<double> sliverScrollControllerOffset,
  ) {
    if (!isWeb) {
      final theme = Theme.of(context);
      return StreamBuilder<bool?>(
        stream: settings.autoUpdateIsEnable.stream,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return StreamBuilder<ClientVersion?>(
              stream: _authRepo.newClientVersionInformation,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final link = snapshot.data!.links.where(
                    (element) => element.isDirectLink,
                  );
                  final clientVersion = snapshot.data!;
                  if (link.isNotEmpty) {
                    return FutureBuilder<String?>(
                      future: _fileRepo.getFile(
                        _createUpdateUuid(clientVersion),
                        "${_createUpdateUuid(clientVersion)}.${link.first.url.split(".").last}",
                        directUrl: link.first.url,
                      ),
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                          duration: AnimationSettings.standard,
                          child: (snapshot.hasData)
                              ? StreamBuilder<double>(
                                  stream: sliverScrollControllerOffset,
                                  builder: (context, height) {
                                    final double h =
                                        max(70 - (height.data ?? 0) * 3, 0);
                                    return Opacity(
                                      opacity: h / 70,
                                      child: Container(
                                        height: h,
                                        color:
                                            theme.colorScheme.tertiaryContainer,
                                        padding: const EdgeInsetsDirectional
                                            .symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 70,
                                              child: _buildUpdateAnimation(
                                                clientVersion,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    _i18n.get(
                                                      "download_update_finish",
                                                    ),
                                                    style: theme
                                                        .textTheme.bodyLarge,
                                                  ),
                                                ),
                                                const Flexible(
                                                  child: SizedBox(
                                                    height: 3,
                                                  ),
                                                ),
                                                Flexible(
                                                  child:
                                                      _buildApplicationVersionInfo(
                                                    clientVersion,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const Spacer(),
                                            FilledButton(
                                              onPressed: () =>
                                                  _fileRepo.openFile(
                                                snapshot.data!,
                                                preferShowInFolder: true,
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .tertiary,
                                                ),
                                              ),
                                              child: Text(_i18n.get("open")),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox(),
                        );
                      },
                    );
                  }
                }

                return const SizedBox.shrink();
              },
            );
          }
          return const SizedBox.shrink();
        },
      );
    }
    return const SizedBox();
  }

  static String _createUpdateUuid(ClientVersion clientVersion) =>
      "$APPLICATION_NAME-${clientVersion.version}";

  static Future<void> _newVersionInfo(
    BuildContext context,
    ClientVersion clientVersion,
  ) async {
    await Future.delayed(Duration.zero);
    if (context.mounted) {
      showFloatingModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        builder: (c) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: p8,
              end: p24,
              start: p24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUpdateAnimation(clientVersion),
                Text(
                  "${_i18n.get("update")} $APPLICATION_NAME",
                  style: const TextStyle(fontSize: 25),
                ),
                _buildApplicationVersionInfo(clientVersion),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  clientVersion.description,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 19),
                ),
                const SizedBox(
                  height: 16,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (var downloadLink in clientVersion.links)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => _urlHandlerService.handleNormalLink(
                          downloadLink.url,
                        ),
                        child: Text(
                          downloadLink.label,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        _i18n.get("remind_me_later"),
                        style: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(c),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ).ignore();
    }
  }

  static Widget _buildApplicationVersionInfo(ClientVersion clientVersion) {
    return Text(
      "${_i18n.get(
        "version",
      )} ${clientVersion.version}.${clientVersion.revision} - ${_i18n.get("size")} ${clientVersion.size}",
    );
  }

  static Widget _buildUpdateAnimation(ClientVersion clientVersion) {
    if (clientVersion.hasAnimation()) {
      return FutureBuilder(
        future: _fileRepo.getFile(
          clientVersion.animation.uuid,
          clientVersion.animation.name,
        ),
        builder: (c, pathSnapshot) {
          if (pathSnapshot.hasData && pathSnapshot.data != null) {
            return Ws.asset(
              pathSnapshot.data,
              height: 230,
              width: 300,
            );
          }
          return const SizedBox.shrink();
        },
      );
    } else {
      return _getDefaultAnimation();
    }
  }

  static Ws _getDefaultAnimation() {
    return const Ws.asset(
      "assets/animations/new_version.ws",
      height: 230,
      width: 300,
    );
  }

  static Widget aborted(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _authRepo.isOutOfDate,
      builder: (c, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data!) {
          showOutOfDateDialog(context);
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

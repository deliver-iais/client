import 'dart:async';

import 'package:deliver/box/dao/registered_bot_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/input_pin.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SingleUrlWidget extends StatelessWidget {
  final UrlCase urlCase;
  final bool isAdvertisement;
  final bool isPrimary;
  final double? imageHeight;
  final double? width;
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  static final _botRepo = GetIt.I.get<BotRepo>();
  static final _registeredBotDao = GetIt.I.get<RegisteredBotDao>();

  const SingleUrlWidget({
    Key? key,
    required this.urlCase,
    this.isAdvertisement = false,
    required this.imageHeight,
    required this.width,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAdvertisement)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8),
            child: Text(
              _i18n.get("ads"),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              if (urlCase.hasUrl()) {
                unawaited(
                  _urlHandlerService.onUrlTap(
                    urlCase.url.url,
                    openLinkImmediately: true,
                  ),
                );
              } else if (urlCase.hasBotCallback()) {
                if (urlCase.botCallback.hasPinCodeSettings()) {
                  if (!urlCase.botCallback.pinCodeSettings
                          .isOutsideFirstRedirectionEnabled ||
                      await _registeredBotDao.botIsRegistered(
                        urlCase.botCallback.bot.asString(),
                      )) {
                    if (context.mounted) {
                      inputPin(
                        context: context,
                        pinCodeSettings: urlCase.botCallback.pinCodeSettings,
                        data: urlCase.botCallback.data,
                        botUid: urlCase.botCallback.bot.asString(),
                        showHelper: true,
                      );
                    }
                  } else if (urlCase.botCallback.pinCodeSettings
                      .isOutsideFirstRedirectionEnabled) {
                    if (context.mounted) {
                      ToastDisplay.showToast(
                        toastContext: context,
                        showWarningAnimation: true,
                        toastText: urlCase.botCallback.pinCodeSettings
                            .outsideFirstRedirectionAlert,
                      );
                    }
                    await (_registeredBotDao.saveRegisteredBot(
                      urlCase.botCallback.bot.asString(),
                    ));
                    Timer(
                      const Duration(seconds: 1),
                      () => unawaited(
                        _urlHandlerService.handleSendMsgToBot(
                          urlCase.botCallback.bot.node,
                          urlCase.botCallback.pinCodeSettings
                              .outsideFirstRedirectionText,
                          sendDirectly: true,
                        ),
                      ),
                    );
                  }
                } else {
                  final dialogContextCompleter = Completer<BuildContext>();
                  unawaited(
                    _botRepo
                        .sendCallbackQuery(
                          data: urlCase.botCallback.data,
                          to: urlCase.botCallback.bot,
                        )
                        .then(
                          (value) => dialogContextCompleter.future
                              .then((c) => Navigator.pop(c)),
                        ),
                  );
                  unawaited(
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (c) {
                        dialogContextCompleter.complete(c);
                        return const SizedBox(
                          height: 70,
                          width: 70,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  );
                }
              }
            },
            child: Container(
              width: width,
              decoration: const BoxDecoration(borderRadius: secondaryBorder),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: secondaryBorder,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        width: width,
                        height: imageHeight,
                        child: ClipRRect(
                          borderRadius: secondaryBorder,
                          child: FutureBuilder<String?>(
                            future: _fileRepo.getFile(
                              urlCase.img.uuid,
                              urlCase.img.name,
                            ),
                            builder: (c, s) {
                              if (s.hasData && s.data != null) {
                                return Image(
                                  image: s.data!.imageProvider(),
                                  fit: BoxFit.cover,
                                );
                              }
                              return const TextLoader();
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Container(
                          margin: const EdgeInsets.all(p4),
                          padding: const EdgeInsets.all(p4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.75),
                            borderRadius: tertiaryBorder,
                          ),
                          child: Icon(
                            Icons.open_in_new_rounded,
                            size: 20,
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: p8,
                      horizontal: p8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          urlCase.name,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          urlCase.description,
                          maxLines: 1,
                          style: TextStyle(color: theme.colorScheme.outline),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

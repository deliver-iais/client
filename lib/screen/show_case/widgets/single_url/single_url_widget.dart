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
  final double padding;
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  static final _botRepo = GetIt.I.get<BotRepo>();
  static final _registeredBotDao = GetIt.I.get<RegisteredBotDao>();

  const SingleUrlWidget({
    Key? key,
    required this.urlCase,
    this.isAdvertisement = false,
    this.imageHeight = 180,
    this.width = 350,
    this.padding = 20,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAdvertisement)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _i18n.get("ads"),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          Center(
            child: InkWell(
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
                decoration: BoxDecoration(
                  color: isPrimary ? theme.primaryColor.withOpacity(0.2) : null,
                  borderRadius: secondaryBorder,
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: secondaryBorder,
                      child: SizedBox(
                        width: width,
                        height: imageHeight,
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
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                        left: 15,
                        right: 15,
                        bottom: 15,
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
      ),
    );
  }
}

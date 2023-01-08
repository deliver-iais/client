import 'dart:io';

import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SingleBannerWidget extends StatelessWidget {
  final BannerCase bannerCase;
  final bool isAdvertisement;
  final bool isPrimary;
  final bool showDescription;
  final double? height;
  final double? width;
  final double padding;
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _botRepo = GetIt.I.get<BotRepo>();

  const SingleBannerWidget({
    Key? key,
    required this.bannerCase,
    this.height = 180,
    this.width = 350,
    this.padding = 20,
    this.isAdvertisement = false,
    this.isPrimary = false,
    this.showDescription = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Future<dynamic> infoFuture;
    if (bannerCase.uid.isBot()) {
      infoFuture = _botRepo.fetchBotInfo(bannerCase.uid);
    } else {
      infoFuture = _mucRepo.fetchMucInfo(bannerCase.uid);
    }
    return FutureBuilder(
      future: infoFuture,
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Container(
                  padding: isPrimary ? const EdgeInsets.all(10) : null,
                  decoration: BoxDecoration(
                    color:
                        isPrimary ? theme.primaryColor.withOpacity(0.2) : null,
                    borderRadius: secondaryBorder,
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: InkWell(
                    hoverColor: Theme.of(context).colorScheme.background,
                    onTap: () =>
                        _routingService.openRoom(bannerCase.uid.asString()),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: secondaryBorder,
                          child: SizedBox(
                            height: height,
                            width: width,
                            child: FutureBuilder<String?>(
                              future: _fileRepo.getFile(
                                bannerCase.bannerImg.uuid,
                                bannerCase.bannerImg.name,
                              ),
                              builder: (c, s) {
                                if (s.hasData && s.data != null) {
                                  return isWeb
                                      ? Image.network(
                                          s.data!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(s.data!),
                                          height: height,
                                          width: width,
                                          fit: BoxFit.cover,
                                        );
                                }
                                return TextLoader(
                                  const Text(""),
                                  width: width ??
                                      MediaQuery.of(context).size.width,
                                );
                              },
                            ),
                          ),
                        ),
                        if (showDescription && snapshot.data != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              left: 15,
                              right: 15,
                              bottom: 15,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  bannerCase.uid.isBot()
                                      ? (snapshot.data! as BotInfo).name ?? ""
                                      : (snapshot.data! as Muc).name,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  bannerCase.uid.isBot()
                                      ? (snapshot.data! as BotInfo)
                                              .description ??
                                          ""
                                      : (snapshot.data! as Muc).info,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: theme.colorScheme.outline,
                                  ),
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
      },
    );
  }
}

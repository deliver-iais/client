import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/fileRepo.dart';
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
  final double? height;
  final double? width;
  final double padding;
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();

  const SingleBannerWidget({
    Key? key,
    required this.bannerCase,
    this.height = 180,
    this.width = 350,
    this.padding = 20,
    this.isAdvertisement = false,
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
            child: Container(
              padding: isPrimary ? const EdgeInsets.all(10) : null,
              decoration: isPrimary
                  ? BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.2),
                      borderRadius: secondaryBorder,
                    )
                  : null,
              child: InkWell(
                hoverColor: Theme.of(context).colorScheme.background,
                onTap: () =>
                    _routingService.openRoom(bannerCase.uid.asString()),
                child: ClipRRect(
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
                          width: width ?? MediaQuery.of(context).size.width,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/methods/platform.dart';
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
                            return isWeb
                                ? Image.network(
                                    s.data!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(s.data!),
                                    fit: BoxFit.cover,
                                  );
                          }
                          return const TextLoader(
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 15, left: 15, right: 15),
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
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              child: Text(_i18n.get("see_website")),
                              onPressed: () => _urlHandlerService.onUrlTap(
                                urlCase.url,
                                context,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

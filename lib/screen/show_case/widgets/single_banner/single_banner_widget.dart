import 'dart:io';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SingleBannerWidget extends StatelessWidget {
  final BannerCase bannerCase;
  final double? height;
  final double? width;
  final double padding;
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();

  const SingleBannerWidget({
    Key? key,
    required this.bannerCase,
    this.height = 180,
    this.width,
    this.padding = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: InkWell(
        onTap: () => _routingService.openRoom(bannerCase.uid.asString()),
        child: SizedBox(
          child: ClipRRect(
            borderRadius: secondaryBorder,
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
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SingleBannerWidget extends StatelessWidget {
  final BannerCase bannerCase;
  static final _fileRepo = GetIt.I.get<FileRepo>();

  const SingleBannerWidget({Key? key, required this.bannerCase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 180,
        child: ClipRRect(
          borderRadius: mainBorder,
          child: FutureBuilder<String?>(
            future: _fileRepo.getFileIfExist(
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
                    : Image.file(File(s.data!), height: 180, fit: BoxFit.cover);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

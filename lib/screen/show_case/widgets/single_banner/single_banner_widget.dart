import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/show_case/widgets/ads.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SingleBannerWidget extends StatefulWidget {
  final BannerCase bannerCase;
  final bool isAdvertisement;
  final bool isPrimary;
  final bool showDescription;
  final double? height;
  final double? width;
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _botRepo = GetIt.I.get<BotRepo>();

  const SingleBannerWidget({
    Key? key,
    required this.bannerCase,
    required this.height,
    required this.width,
    this.isAdvertisement = false,
    this.isPrimary = false,
    this.showDescription = false,
  }) : super(key: key);

  @override
  State<SingleBannerWidget> createState() => _SingleBannerWidgetState();
}

class _SingleBannerWidgetState extends State<SingleBannerWidget> {
  late Future<dynamic> infoFuture;

  @override
  void initState() {
    if (widget.bannerCase.uid.isBot()) {
      infoFuture =
          SingleBannerWidget._botRepo.fetchBotInfo(widget.bannerCase.uid);
    } else {
      infoFuture =
          SingleBannerWidget._mucRepo.fetchMucInfo(widget.bannerCase.uid);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: infoFuture,
      builder: (context, snapshot) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: secondaryBorder,
            color: widget.showDescription && widget.isPrimary
                ? theme.colorScheme.tertiaryContainer
                : theme.colorScheme.surface,
          ),
          padding: widget.showDescription
              ? const EdgeInsets.symmetric(vertical: p16, horizontal: p8)
              : EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: secondaryBorder,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => SingleBannerWidget._routingService
                          .openRoom(widget.bannerCase.uid.asString()),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: secondaryBorder,
                            child: SizedBox(
                              height: widget.height,
                              width: widget.width,
                              child: FutureBuilder<String?>(
                                future: SingleBannerWidget._fileRepo.getFile(
                                  widget.bannerCase.bannerImg.uuid,
                                  widget.bannerCase.bannerImg.name,
                                ),
                                builder: (c, s) {
                                  if (s.hasData && s.data != null) {
                                    return Image(
                                      image: s.data!.imageProvider(),
                                      height: widget.height,
                                      width: widget.width,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return TextLoader(
                                    width: widget.width ??
                                        MediaQuery.of(context).size.width,
                                  );
                                },
                              ),
                            ),
                          ),
                          if (widget.showDescription && snapshot.data != null)
                            Padding(
                              padding: const EdgeInsetsDirectional.all(15),
                              child: Column(
                                children: [
                                  Text(
                                    widget.bannerCase.uid.isBot()
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
                                    widget.bannerCase.uid.isBot()
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
              ),
              if (widget.isAdvertisement)
                const PositionedDirectional(
                  start: p4,
                  top: p4,
                  child: Ads(),
                ),
            ],
          ),
        );
      },
    );
  }
}

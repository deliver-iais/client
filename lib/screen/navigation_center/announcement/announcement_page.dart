import 'package:deliver/box/announcement.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/announcement_repo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/navigation_center/announcement/widgets/announcement_widgets.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/announcement.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

const _empty = Empty(key: ValueKey("empty"));

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _announcementRepo = GetIt.I.get<AnnouncementRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  void initState() {
    super.initState();
    _announcementRepo.fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Announcements?>(
      stream: _announcementRepo.getFirstAnnouncement(),
      builder: (context, firstEvent) {
        if (firstEvent.hasData && firstEvent.data != null) {
          return StreamBuilder<Object>(
            stream: settings.showEvents.stream,
            builder: (context, showEvent) {
              if (showEvent.hasData && showEvent.data == true) {
                return scaffold(
                  StreamBuilder<List<Announcements>>(
                    stream: _announcementRepo.getAllAnnouncements(),
                    builder: (context, events) {
                      if (events.hasData && events.data != null) {
                        return loadEvents(events);
                      } else {
                        return _empty;
                      }
                    },
                  ),
                );
              } else {
                if (firstEvent.data!.json.toAnnouncment().severity ==
                    AnnouncementSeverity.FATAL) {
                  return scaffold(
                    StreamBuilder<List<Announcements>>(
                      stream: _announcementRepo.getFatalAnnouncements(),
                      builder: (context, fatalEvents) {
                        if (fatalEvents.hasData && fatalEvents.data != null) {
                          return loadEvents(fatalEvents);
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  );
                } else {
                  return _empty;
                }
              }
            },
          );
        } else {
          return _empty;
        }
      },
    );
  }

  Widget loadEvents(AsyncSnapshot<List<Announcements>> events) {
    return FluidContainerWidget(
      child: ListView.builder(
        itemCount: events.data!.length,
        itemBuilder: (c, index) {
          final eventToAnnouncement = events.data![index].json.toAnnouncment();
          if (eventToAnnouncement.details.backgroundImage.uuid.isNotEmpty) {
            return FutureBuilder<String?>(
              future: _fileRepo.getFilePathFromFileProto(
                eventToAnnouncement.details.backgroundImage,
              ),
              builder: (context, path) {
                if (path.hasData && path.data != null) {
                  final image = path.data!.imageProvider();
                  return AnnouncementWidgets(
                    image: image,
                    announcement: eventToAnnouncement,
                    isAnnouncementPage: true,
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          } else {
            return AnnouncementWidgets(
              announcement: eventToAnnouncement,
              isAnnouncementPage: true,
            );
          }
        },
      ),
    );
  }

  Widget scaffold(Widget widget) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:
            !isLarge(context) ? _routingServices.backButtonLeading() : null,
        title: Text(_i18n.get("events")),
      ),
      body: Directionality(textDirection: TextDirection.rtl, child: widget),
    );
  }
}

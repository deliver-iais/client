import 'package:deliver/box/announcement.dart';
import 'package:deliver/repository/announcement_repo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/navigation_center/announcement/widgets/announcement_widgets.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/announcement.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AnnouncementBar extends StatefulWidget {
  const AnnouncementBar({Key? key}) : super(key: key);

  @override
  State<AnnouncementBar> createState() => AnnouncementBarState();
}

class AnnouncementBarState extends State<AnnouncementBar> {
  final _announcementRepo = GetIt.I.get<AnnouncementRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  late Announcement _eventToAnnouncement;

  @override
  void initState() {
    _announcementRepo.fetchAnnouncements();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<Announcements?>(
        stream: _announcementRepo.getFirstAnnouncement(),
        builder: (context, event) {
          if (event.hasData) {
            _eventToAnnouncement = event.data!.json.toAnnouncment();
            return StreamBuilder<bool>(
              stream: settings.showEvents.stream,
              builder: (context, snapshot) {
                if (_eventToAnnouncement.severity ==
                        AnnouncementSeverity.FATAL ||
                    snapshot.hasData && snapshot.data == true) {
                  if (_eventToAnnouncement
                      .details.backgroundImage.uuid.isNotEmpty) {
                    return FutureBuilder<String?>(
                      future: _fileRepo.getFilePathFromFileProto(
                        _eventToAnnouncement.details.backgroundImage,
                      ),
                      builder: (context, path) {
                        if (path.hasData && path.data != null) {
                          final image = path.data!.imageProvider();
                          return AnnouncementWidgets(
                            image: image,
                            announcement: _eventToAnnouncement,
                            isAnnouncementPage: true,
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    );
                  } else {
                    return GestureDetector(
                      onTap: _routingService.openAnnouncementPage,
                      child: AnnouncementWidgets(
                        announcement: _eventToAnnouncement,
                      ),
                    );
                  }
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

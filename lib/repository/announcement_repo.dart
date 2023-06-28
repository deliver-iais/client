import 'package:deliver/box/announcement.dart';
import 'package:deliver/box/dao/announcement_dao.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/announcement.pb.dart';
import 'package:deliver_public_protocol/pub/v1/service_discovery.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class AnnouncementRepo {
  final _announcementDao = GetIt.I.get<AnnouncementDao>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _logger = GetIt.I.get<Logger>();

  Stream<List<Announcements>> getAllAnnouncements() {
    return _announcementDao.getAllAnnouncements();
  }

  Stream<Announcements?> getFirstAnnouncement() {
    return _announcementDao.getAnnouncement(0);
  }

  Stream<List<Announcements>> getFatalAnnouncements() {
    return _announcementDao.getFatalAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final localModifyTime = await _announcementDao.getTime();
      final result = await _sdr.serviceDiscoveryServiceClient.getAnnouncement(
        GetAnnouncementReq(
          userPreference: await getUserPreferencePB(),
          lastTimeModified: Int64(localModifyTime!),
        ),
      );

      if ((result.announcement.isNotEmpty ||
          result.lastTimeModified.toInt() > localModifyTime)) {
        await _announcementDao.clear();
        await _saveFetchedAnnouncements(
          result.announcement,
          result.lastTimeModified,
        );
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _saveFetchedAnnouncements(
    List<Announcement> getAnnouncements,
    Int64 lastTimeModified,
  ) async {
    final announcementsList = <Announcements>[];
    await _announcementDao.clear();
    await _announcementDao.saveTime(lastTimeModified.toInt());
    for (var i = 0; i < getAnnouncements.length; i++) {
      final insertedAnnouncement = Announcements(
        index: i,
        json: getAnnouncements[i].writeToJson(),
      );
      announcementsList.add(insertedAnnouncement);
      await _announcementDao.save(insertedAnnouncement);
    }
  }
}

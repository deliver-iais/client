import 'package:deliver/box/auto_download_room_category.dart';
import 'package:deliver/box/dao/auto_download_dao.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AutoDownloadPage extends StatefulWidget {
  const AutoDownloadPage({Key? key}) : super(key: key);

  @override
  State<AutoDownloadPage> createState() => _AutoDownloadPageState();
}

class _AutoDownloadPageState extends State<AutoDownloadPage> {
  final _autoDownloadDao = GetIt.I.get<AutoDownloadDao>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UltimateAppBar(
        child: AppBar(
          titleSpacing: 8,
          title: const Text('Auto Download'),
        ),
      ),
      body: FluidContainerWidget(
        showStandardContainer: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildAutoDownloadRow(
              title: 'In Private Chats',
              icon: CupertinoIcons.person_solid,
              category: AutoDownloadRoomCategory.IN_PRIVATE_CHATS,
            ),
            const Divider(),
            buildAutoDownloadRow(
              title: 'In Groups',
              icon: CupertinoIcons.person_2_fill,
              category: AutoDownloadRoomCategory.IN_GROUP,
            ),
            const Divider(),
            buildAutoDownloadRow(
              title: 'In Channels',
              icon: CupertinoIcons.news_solid,
              category: AutoDownloadRoomCategory.IN_CHANNEL,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAutoDownloadRow({
    required String title,
    required IconData icon,
    required AutoDownloadRoomCategory category,
  }) {
    return ExpandablePanel(
      header: ListTile(
        title: Text(title),
        leading: Icon(icon),
      ),
      collapsed: const SizedBox.shrink(),
      expanded: autoDownloadDetails(category),
      theme: ExpandableThemeData(
        iconColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget autoDownloadDetails(AutoDownloadRoomCategory category) {
    return Column(
      children: [
        const Divider(),
        FutureBuilder<bool>(
          future: _autoDownloadDao.isPhotoAutoDownloadEnable(category),
          builder: (context, snapshot) {
            return ListTile(
              title: const Text('Photos'),
              trailing: Switch(
                activeColor: Theme.of(context).colorScheme.primary,
                value: snapshot.data ?? false,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _autoDownloadDao.enablePhotoAutoDownload(category);
                    } else {
                      _autoDownloadDao.disablePhotoAutoDownload(category);
                    }
                  });
                },
              ),
            );
          },
        ),
        FutureBuilder<bool>(
          future: _autoDownloadDao.isFileAutoDownloadEnable(category),
          builder: (context, snapshot) {
            return ListTile(
              title: const Text('Files'),
              trailing: Switch(
                value: snapshot.data ?? false,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _autoDownloadDao.enableFileAutoDownload(category);
                    } else {
                      _autoDownloadDao.disableFileAutoDownload(category);
                    }
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

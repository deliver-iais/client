import 'package:deliver/box/auto_download_room_category.dart';
import 'package:deliver/box/dao/auto_download_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/src/section.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AutoDownloadSettingsPage extends StatefulWidget {
  const AutoDownloadSettingsPage({super.key});

  @override
  State<AutoDownloadSettingsPage> createState() =>
      _AutoDownloadSettingsPageState();
}

class _AutoDownloadSettingsPageState extends State<AutoDownloadSettingsPage> {
  final _autoDownloadDao = GetIt.I.get<AutoDownloadDao>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("automatic_download")),
        ),
      ),
      body: FluidContainerWidget(
        child: ListView(
          children: [
            Section(
              title: _i18n.get("in_private_chat"),
              children: autoDownloadDetails(
                AutoDownloadRoomCategory.IN_PRIVATE_CHATS,
              ),
            ),
            Section(
              title: _i18n.get("in_group_chat"),
              children:
                  autoDownloadDetails(AutoDownloadRoomCategory.IN_GROUP),
            ),
            Section(
              title: _i18n.get("in_channel_chat"),
              children:
                  autoDownloadDetails(AutoDownloadRoomCategory.IN_CHANNEL),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> autoDownloadDetails(AutoDownloadRoomCategory category) {
    return [
      FutureBuilder<bool>(
        future: _autoDownloadDao.isPhotoAutoDownloadEnable(category),
        builder: (context, snapshot) {
          return SettingsTile.switchTile(
            title: _i18n.get("photos"),
            leading: const Icon(CupertinoIcons.photo),
            switchValue: snapshot.data ?? false,
            onToggle: ({required newValue}) {
              setState(() {
                if (newValue) {
                  _autoDownloadDao.enablePhotoAutoDownload(category);
                } else {
                  _autoDownloadDao.disablePhotoAutoDownload(category);
                }
              });
            },
          );
        },
      ),
      FutureBuilder<bool>(
        future: _autoDownloadDao.isFileAutoDownloadEnable(category),
        builder: (context, snapshot) {
          return SettingsTile.switchTile(
            title: _i18n.get("files"),
            leading: const Icon(CupertinoIcons.folder),
            switchValue: snapshot.data ?? false,
            onToggle: ({required newValue}) {
              setState(() {
                if (newValue) {
                  _autoDownloadDao.enableFileAutoDownload(category);
                } else {
                  _autoDownloadDao.disableFileAutoDownload(category);
                }
              });
            },
          );
        },
      ),
      FutureBuilder<int>(
        future: _autoDownloadDao.getFileSizeLimitForAutoDownload(category),
        builder: (context, snapshot) {
          return Column(
            children: [
              SettingsTile(
                title: _i18n.get("limit_size"),
                leading: const Icon(CupertinoIcons.cloud_download),
                trailing:
                    Text("${_i18n.get("up_to")} ${snapshot.data ?? "1"} MB"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    trackHeight: 5,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    inactiveTrackColor: Colors.grey,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Slider.adaptive(
                      max: 500,
                      min: 1,
                      value: snapshot.data?.toDouble() == 0
                          ? 1
                          : snapshot.data?.toDouble() ?? 1,
                      onChanged: (value) {
                        setState(() {
                          _autoDownloadDao.setFileSizeLimitForAutoDownload(
                            category,
                            value.toInt(),
                          );
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      )
    ];
  }
}

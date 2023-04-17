import 'package:deliver/box/show_case.dart';
import 'package:deliver/repository/show_case_repo.dart';
import 'package:deliver/screen/show_case/widgets/grouped_banner/grouped_banner.dart';
import 'package:deliver/screen/show_case/widgets/grouped_rooms/grouped_rooms_widget.dart';
import 'package:deliver/screen/show_case/widgets/grouped_url/grouped_url_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_banner/single_banner_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_url/single_url_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({Key? key}) : super(key: key);

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  final BehaviorSubject<List<ShowCase>> _showCaseCache =
      BehaviorSubject.seeded([]);
  final _showCaseRepo = GetIt.I.get<ShowCaseRepo>();

  @override
  void initState() {
    super.initState();
    getShowCase(0, foreToUpdateShowCases: true);
  }

  Future<ShowCase?> getShowCase(
    int index, {
    bool foreToUpdateShowCases = false,
  }) async {
    final res = await _showCaseRepo.getShowCasePage(
      index,
      foreToUpdateShowCases: foreToUpdateShowCases,
    );
    if (res != null) {
      for (final showcase in res) {
        _showCaseCache.add(_showCaseCache.value + [showcase]);
      }
    }
    return _showCaseCache.value[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      extendBodyBehindAppBar: true,
      body: FluidContainerWidget(
        child: StreamBuilder<List<ShowCase>>(
          stream: _showCaseCache,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    thickness: 1,
                  );
                },
                itemCount: snapshot.data!.length,
                itemBuilder: (ctx, index) {
                  return _buildShowCaseItem(
                    snapshot.data![index].json,
                    isLast: (snapshot.data!.length == index + 1),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildShowCaseItem(String showCaseJson, {required bool isLast}) {
    final showCaseType = _showCaseRepo.findShowCaseType(showCaseJson);
    final showCase = showCaseJson.toShowCase();
    switch (showCaseType) {
      case Showcase_Type.groupedBanners:
        return GroupedBanner(
          showCase: showCase,
        );
      case Showcase_Type.groupedRooms:
        return GroupedRoomsWidget(
          showCase: showCase,
        );
      case Showcase_Type.singleBanner:
        return SingleBannerWidget(
          bannerCase: showCase.singleBanner,
          isAdvertisement: showCase.isAdvertisement,
          isPrimary: showCase.primary,
          height: 200,
          width: showcaseBoxSingleBannerWidth(),
          showDescription: true,
        );
      case Showcase_Type.singleUrl:
        return SingleUrlWidget(
          urlCase: showCase.singleUrl,
          isAdvertisement: showCase.isAdvertisement,
          isPrimary: showCase.primary,
          imageHeight: 180,
          width: 350,
        );
      case Showcase_Type.groupedUrl:
        return GroupedUrlWidget(
          showCase: showCase,
        );
      case Showcase_Type.notSet:
        return const SizedBox.shrink();
    }
  }
}

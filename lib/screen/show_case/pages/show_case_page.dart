import 'package:deliver/box/show_case.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/show_case_repo.dart';
import 'package:deliver/screen/show_case/widgets/grouped_banner/grouped_banner.dart';
import 'package:deliver/screen/show_case/widgets/grouped_rooms/grouped_rooms_widget.dart';
import 'package:deliver/screen/show_case/widgets/grouped_url/grouped_url_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_banner/single_banner_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
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
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();
  final BehaviorSubject<List<ShowCase>> _showCaseCache =
      BehaviorSubject.seeded([]);
  final _showCaseRepo = GetIt.I.get<ShowCaseRepo>();

  @override
  void initState() {
    getShowCase(0, foreToUpdateShowCases: true);
    super.initState();
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("showcase")),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        child: Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: StreamBuilder<List<ShowCase>>(
            stream: _showCaseCache,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 20, left: 20, top: 10),
                      child: Divider(),
                    );
                  },
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, index) {
                    return _buildShowCaseItem(
                      snapshot.data![index].json,
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShowCaseItem(String showCaseJson) {
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
        );
      case Showcase_Type.singleUrl:
        // todo: Handle this case.
        return const SizedBox.shrink();
      case Showcase_Type.groupedUrl:
        return GroupedUrlWidget(
          groupedUrls: showCase.groupedUrl,
        );
      case Showcase_Type.notSet:
        return const SizedBox.shrink();
    }
  }
}

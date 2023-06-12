import 'package:deliver/box/show_case.dart';
import 'package:deliver/repository/show_case_repo.dart';
import 'package:deliver/screen/navigation_center/search/not_result_widget.dart';
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
  final BehaviorSubject<List<ShowCase>?> _showCaseCache =
      BehaviorSubject.seeded(null);
  final _isLoadMoreRunning = BehaviorSubject.seeded(false);
  final _showCaseRepo = GetIt.I.get<ShowCaseRepo>();
  late final ScrollController _controller;
  int _page = 0;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    getShowCase();
    _controller = ScrollController()..addListener(_loadMore);
  }

  Future<void> _loadMore() async {
    if (_controller.position.extentAfter < 300 &&
        !_isLoadMoreRunning.value &&
        !isFinished) {
      _isLoadMoreRunning.add(true);
      _page++;
      await getShowCase();
      _isLoadMoreRunning.add(false);
    }
  }

  Future<void> getShowCase() async {
    final (List<ShowCase>? showcaseList, bool finished) =
        await _showCaseRepo.getShowCasePage(
      _page,
    );
    if (showcaseList != null) {
      isFinished = finished;
      _showCaseCache.add((_showCaseCache.value ?? []) + showcaseList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      extendBodyBehindAppBar: true,
      body: FluidContainerWidget(
        child: StreamBuilder<List<ShowCase>?>(
          stream: _showCaseCache,
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.hasData) {
              if (snapshot.data!.isNotEmpty) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        controller: _controller,
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 1,
                            thickness: 1,
                            color: theme.colorScheme.outlineVariant
                                .withOpacity(0.5),
                          );
                        },
                        itemCount: snapshot.data!.length,
                        itemBuilder: (ctx, index) {
                          return _buildShowCaseItem(
                            snapshot.data![index].json,
                            isLast: (snapshot.data!.length == index + 1),
                          );
                        },
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: _isLoadMoreRunning
                          .debounceTime(const Duration(milliseconds: 250)),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 40),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                );
              } else {
                return const NoResultWidget();
              }
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
          width: showcaseBoxSingleBannerWidth(),
          showDescription: true,
        );
      case Showcase_Type.singleUrl:
        return SingleUrlWidget(
          urlCase: showCase.singleUrl,
          isAdvertisement: showCase.isAdvertisement,
          isPrimary: showCase.primary,
          width: showcaseBoxSingleBannerWidth(),
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

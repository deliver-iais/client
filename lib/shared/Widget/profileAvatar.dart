import 'package:carousel_slider/carousel_slider.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfileAvatar extends StatefulWidget {
  @required
  final bool innerBoxIsScrolled;
  @required
  final String uuid;
  @required
  final bool settingProfile;


  ProfileAvatar(
      {this.innerBoxIsScrolled, this.uuid, this.settingProfile});

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  double currentAvatarIndex = 0;
  final selectedImages = Map<int, bool>();
  final finalSelected = Map<int, String>();
  var avatarRepo =  GetIt.I.get<AvatarRepo>();

  showBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 1,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                  color: Colors.white,
                  child: Stack(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(0),
                      child: ShareBoxGallery(
                        scrollController: scrollController,
                        onClick: (index, path) async {
                          setState(() {
                            selectedImages[index - 1] =
                                !(selectedImages[index - 1] ?? false);

                            selectedImages[index - 1]
                                ? finalSelected[index - 1] = path
                                : finalSelected.remove(index - 1);
                          });
                        },
                        selectedImages: selectedImages,
                        selectGallery: false,
                      ),
                    ),
                  ]));
            },
          );
        });
  }

  onSelected(String selected) {
    switch (selected) {
      case "select":
        showBottomSheet();
        break;
      case "delete":
        deleteAvatar();
        break;
    }
  }
  void deleteAvatar(){
    Avatar avatar;
    avatarRepo.fetchAvatar();

  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return SliverAppBar(
        actions: <Widget>[
          widget.settingProfile
              ? PopupMenuButton(
                  itemBuilder: (_) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                        child: Text(
                            appLocalization.getTraslateValue("setProfile")),
                        value: "select"),
                    new PopupMenuItem<String>(
                        child: Text(appLocalization.getTraslateValue("delete")),
                        value: "delete"),
                  ],
                  onSelected: onSelected,
                )
              : SizedBox.shrink()
        ],
        forceElevated: widget.innerBoxIsScrolled,
        leading: BackButton(
          color: ExtraTheme.of(context).infoChat,
        ),
        expandedHeight: MediaQuery.of(context).size.width - 40,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          collapseMode: CollapseMode.pin,
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            child: Text(widget.uuid,
                //textAlign: TextAlign.center,
                style: TextStyle(
                  color: ExtraTheme.of(context).infoChat,
                  fontSize: 28.0,
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 30.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                )),
          ),
          background: Container(
            child: Stack(
              children: <Widget>[
                CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.width,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentAvatarIndex = index.ceilToDouble();
                      });
                    },
                  ),
                  items: [1, 2, 3, 4, 5].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          child: Image.network(
                            'https://picsum.photos/seed/picsum/300/300',
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                          ),
                          foregroundDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color.fromARGB(150, 0, 0, 0)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.6, 1],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DotsIndicator(
                    dotsCount: 5,
                    position: currentAvatarIndex,
                    decorator: DotsDecorator(
                      size: const Size(5.0, 5.0),
                      color: Colors.white, // Inactive color
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

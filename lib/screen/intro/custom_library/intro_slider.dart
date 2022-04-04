// ignore_for_file: no_logic_in_create_state

import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/language.dart';
import 'package:flutter/material.dart';

import 'slide_object.dart';

class IntroSlider extends StatefulWidget {
  // ---------- Slides ----------
  /// An array of Slide object
  final List<Slide> slides;

  /// Background color for all slides
  final Color? backgroundColorAllSlides;

  // ---------- SKIP button ----------
  /// Render your own SKIP button
  final Widget? renderSkipBtn;

  /// Width of view wrapper SKIP button
  final double? widthSkipBtn;

  /// Fire when press SKIP button
  final void Function()? onSkipPress;

  /// Change SKIP to any text you want
  final String? nameSkipBtn;

  /// Style for text at SKIP button
  final TextStyle? styleNameSkipBtn;

  /// Color for SKIP button
  final Color? colorSkipBtn;

  /// Color for Skip button when press
  final Color? highlightColorSkipBtn;

  /// Show or hide SKIP button
  final bool? isShowSkipBtn;

  /// Rounded SKIP button
  final double? borderRadiusSkipBtn;

  // ---------- PREV button ----------
  /// Render your own PREV button
  final Widget? renderPrevBtn;

  /// Width of view wrapper PREV button
  final double? widthPrevBtn;

  /// Change PREV to any text you want
  final String? namePrevBtn;

  /// Style for text at PREV button
  final TextStyle? styleNamePrevBtn;

  /// Color for PREV button
  final Color? colorPrevBtn;

  /// Color for PREV button when press
  final Color? highlightColorPrevBtn;

  /// Show or hide PREV button (only visible if skip is hidden)
  final bool? isShowPrevBtn;

  /// Rounded PREV button
  final double? borderRadiusPrevBtn;

  // ---------- NEXT button ----------
  /// Render your own NEXT button
  final Widget? renderNextBtn;

  /// Change NEXT to any text you want
  final String? nameNextBtn;

  /// Show or hide NEXT button
  final bool? isShowNextBtn;

  // ---------- DONE button ----------
  /// Change DONE to any text you want
  final String? nameDoneBtn;

  /// Render your own DONE button
  final Widget? renderDoneBtn;

  /// Width of view wrapper DONE button
  final double? widthDoneBtn;

  /// Fire when press DONE button
  final void Function()? onDonePress;

  /// Style for text at DONE button
  final TextStyle? styleNameDoneBtn;

  /// Color for DONE button
  final Color? colorDoneBtn;

  /// Color for DONE button when press
  final Color? highlightColorDoneBtn;

  /// Rounded DONE button
  final double? borderRadiusDoneBtn;

  /// Show or hide DONE button
  final bool? isShowDoneBtn;

  // ---------- Dot indicator ----------
  /// Show or hide dot indicator
  final bool? isShowDotIndicator;

  /// Color for dot when passive
  final Color? colorDot;

  /// Color for dot when active
  final Color? colorActiveDot;

  /// Size of each dot
  final double? sizeDot;

  // ---------- Tabs ----------
  /// Render your own custom tabs
  final List<Widget>? listCustomTabs;

  final void Function(double)? onAnimationChange;

  // Constructor
  const IntroSlider({
    Key? key,
    // Slides
    required this.slides,
    this.backgroundColorAllSlides,
    // Skip
    this.renderSkipBtn,
    this.widthSkipBtn,
    this.onSkipPress,
    this.nameSkipBtn,
    this.styleNameSkipBtn,
    this.colorSkipBtn,
    this.highlightColorSkipBtn,
    this.isShowSkipBtn,
    this.borderRadiusSkipBtn,

    // Prev
    this.renderPrevBtn,
    this.widthPrevBtn,
    this.namePrevBtn,
    this.isShowPrevBtn,
    this.styleNamePrevBtn,
    this.colorPrevBtn,
    this.highlightColorPrevBtn,
    this.borderRadiusPrevBtn,

    // Done
    this.renderDoneBtn,
    this.widthDoneBtn,
    this.onDonePress,
    this.nameDoneBtn,
    this.colorDoneBtn,
    this.highlightColorDoneBtn,
    this.borderRadiusDoneBtn,
    this.styleNameDoneBtn,
    this.isShowDoneBtn,

    // Next
    this.renderNextBtn,
    this.nameNextBtn,
    this.isShowNextBtn,

    // Dots
    this.isShowDotIndicator,
    this.colorDot,
    this.colorActiveDot,
    this.sizeDot,

    // Tabs
    this.listCustomTabs,

    // Behavior
    this.onAnimationChange,
  }) : super(key: key);

  @override
  IntroSliderState createState() {
    return IntroSliderState(
      // Slides
      slides: slides,
      backgroundColorAllSlides: backgroundColorAllSlides,

      // Skip
      renderSkipBtn: renderSkipBtn,
      widthSkipBtn: widthSkipBtn,
      onSkipPress: onSkipPress,
      nameSkipBtn: nameSkipBtn,
      styleNameSkipBtn: styleNameSkipBtn,
      isShowSkipBtn: isShowSkipBtn,

      // Prev
      renderPrevBtn: renderPrevBtn,
      widthPrevBtn: widthPrevBtn,
      namePrevBtn: namePrevBtn,
      isShowPrevBtn: isShowPrevBtn,
      styleNamePrevBtn: styleNamePrevBtn,

      // Done
      renderDoneBtn: renderDoneBtn,
      widthDoneBtn: widthDoneBtn,
      onDonePress: onDonePress,
      nameDoneBtn: nameDoneBtn,
      styleNameDoneBtn: styleNameDoneBtn,
      isShowDoneBtn: isShowDoneBtn,

      // Next
      renderNextBtn: renderNextBtn,
      nameNextBtn: nameNextBtn,
      isShowNextBtn: isShowNextBtn,

      // Dots
      isShowDotIndicator: isShowDotIndicator,
      colorDot: colorDot,
      colorActiveDot: colorActiveDot,
      sizeDot: sizeDot,

      // Tabs
      listCustomTabs: listCustomTabs,

      // Behavior
      onAnimationChange: onAnimationChange,
    );
  }
}

class IntroSliderState extends State<IntroSlider>
    with SingleTickerProviderStateMixin {
  /// Default values
  static TextStyle defaultBtnNameTextStyle =
      const TextStyle(color: Colors.white);

  static double defaultBtnBorderRadius = 28.0;

  static Color defaultBtnColor = Colors.transparent;

  static Color defaultBtnHighlightColor = Colors.white.withOpacity(0.3);

  // ---------- Slides ----------
  /// An array of Slide object
  final List<Slide> slides;

  /// Background color for all slides
  Color? backgroundColorAllSlides;

  // ---------- SKIP button ----------
  /// Render your own SKIP button
  Widget? renderSkipBtn;

  /// Width of view wrapper SKIP button
  double? widthSkipBtn;

  /// Fire when press SKIP button
  void Function()? onSkipPress;

  /// Change SKIP to any text you want
  String? nameSkipBtn;

  /// Style for text at SKIP button
  TextStyle? styleNameSkipBtn;

  /// Show or hide SKIP button
  bool? isShowSkipBtn;

  // ---------- PREV button ----------
  /// Render your own PREV button
  Widget? renderPrevBtn;

  /// Change PREV to any text you want
  String? namePrevBtn;

  /// Style for text at PREV button
  TextStyle? styleNamePrevBtn;

  /// Width of view wrapper PREV button
  double? widthPrevBtn;

  /// Show or hide PREV button
  bool? isShowPrevBtn;

  // ---------- DONE button ----------
  /// Render your own DONE button
  Widget? renderDoneBtn;

  /// Width of view wrapper DONE button
  double? widthDoneBtn;

  /// Fire when press DONE button
  void Function()? onDonePress;

  /// Change DONE to any text you want
  String? nameDoneBtn;

  /// Style for text at DONE button
  TextStyle? styleNameDoneBtn;

  /// Show or hide DONE button
  bool? isShowDoneBtn;

  // ---------- NEXT button ----------
  /// Render your own NEXT button
  Widget? renderNextBtn;

  /// Change NEXT to any text you want
  String? nameNextBtn;

  /// Show or hide NEXT button
  bool? isShowNextBtn;

  // ---------- Dot indicator ----------
  /// Show or hide dot indicator
  bool? isShowDotIndicator = true;

  /// Color for dot when passive
  Color? colorDot;

  /// Color for dot when active
  Color? colorActiveDot;

  /// Size of each dot
  double? sizeDot = 8.0;

  // ---------- Tabs ----------
  /// List custom tabs
  List<Widget>? listCustomTabs;

  void Function(double)? onAnimationChange;

  // Constructor
  IntroSliderState({
    // List slides
    required this.slides,
    this.backgroundColorAllSlides,

    // Skip button
    this.renderSkipBtn,
    this.widthSkipBtn,
    this.onSkipPress,
    this.nameSkipBtn,
    this.styleNameSkipBtn,
    this.isShowSkipBtn,

    // Prev button
    this.widthPrevBtn,
    this.isShowPrevBtn,
    this.namePrevBtn,
    this.renderPrevBtn,
    this.styleNamePrevBtn,

    // Done button
    this.renderDoneBtn,
    this.widthDoneBtn,
    this.onDonePress,
    this.nameDoneBtn,
    this.styleNameDoneBtn,
    this.isShowDoneBtn,

    // Next button
    this.nameNextBtn,
    this.renderNextBtn,
    this.isShowNextBtn,

    // Dot indicator
    this.isShowDotIndicator,
    this.colorDot,
    this.colorActiveDot,
    this.sizeDot,

    // Tabs
    this.listCustomTabs,
    this.onAnimationChange,
  });

  late TabController tabController;

  List<Widget>? tabs = [];
  List<Widget> dots = [];
  List<double> sizeDots = [];
  List<double> opacityDots = [];

  // For DOT_MOVEMENT
  double marginLeftDotFocused = 0;
  double marginRightDotFocused = 0;

  // For SIZE_TRANSITION
  double currentAnimationValue = 0;
  int currentTabIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: slides.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        currentTabIndex = tabController.previousIndex;
      } else {
        currentTabIndex = tabController.index;
      }
      currentAnimationValue = tabController.animation!.value;
    });

    // Dot animation
    sizeDot ??= 8.0;

    for (var i = 0; i < slides.length; i++) {
      if (i == 0) {
        sizeDots.add(sizeDot! * 1.5);
        opacityDots.add(1.0);
      } else {
        sizeDots.add(sizeDot!);
        opacityDots.add(0.5);
      }
    }

    tabController.animation!.addListener(() {
      setState(() {
        onAnimationChange?.call(tabController.animation!.value);
        if (tabController.animation!.value == currentAnimationValue) {
          return;
        }

        var diffValueAnimation =
            (tabController.animation!.value - currentAnimationValue).abs();
        final diffValueIndex = (currentTabIndex - tabController.index).abs();

        // When press skip button
        if (tabController.indexIsChanging &&
            (tabController.index - tabController.previousIndex).abs() > 1) {
          if (diffValueAnimation < 1.0) {
            diffValueAnimation = 1.0;
          }
          sizeDots[currentTabIndex] = sizeDot! * 1.5 -
              (sizeDot! / 2) * (1 - (diffValueIndex - diffValueAnimation));
          sizeDots[tabController.index] = sizeDot! +
              (sizeDot! / 2) * (1 - (diffValueIndex - diffValueAnimation));
          opacityDots[currentTabIndex] =
              1.0 - (diffValueAnimation / diffValueIndex) / 2;
          opacityDots[tabController.index] =
              0.5 + (diffValueAnimation / diffValueIndex) / 2;
        } else {
          if (tabController.animation!.value > currentAnimationValue) {
            // Swipe left
            sizeDots[currentTabIndex] =
                sizeDot! * 1.5 - (sizeDot! / 2) * diffValueAnimation;
            sizeDots[currentTabIndex + 1] =
                sizeDot! + (sizeDot! / 2) * diffValueAnimation;
            opacityDots[currentTabIndex] = 1.0 - diffValueAnimation / 2;
            opacityDots[currentTabIndex + 1] = 0.5 + diffValueAnimation / 2;
          } else {
            // Swipe right
            sizeDots[currentTabIndex] =
                sizeDot! * 1.5 - (sizeDot! / 2) * diffValueAnimation;
            sizeDots[currentTabIndex - 1] =
                sizeDot! + (sizeDot! / 2) * diffValueAnimation;
            opacityDots[currentTabIndex] = 1.0 - diffValueAnimation / 2;
            opacityDots[currentTabIndex - 1] = 0.5 + diffValueAnimation / 2;
          }
        }
      });
    });

    // Dot indicator
    isShowDotIndicator ??= true;
    colorDot ??= const Color(0x80000000);
    colorActiveDot ??= colorDot;

    setupButtonDefaultValues();
    super.initState();
  }

  void setupButtonDefaultValues() {
    // Skip button
    onSkipPress ??= () {
      if (!isAnimating()) {
        tabController.animateTo(slides.length - 1);
      }
    };
    isShowSkipBtn ??= true;
    styleNameSkipBtn ??= defaultBtnNameTextStyle;
    nameSkipBtn ??= "SKIP";
    renderSkipBtn ??= Text(
      nameSkipBtn!,
      style: styleNameSkipBtn,
    );

    // Prev button
    if (isShowPrevBtn == null || isShowSkipBtn!) {
      isShowPrevBtn = false;
    }
    styleNamePrevBtn ??= defaultBtnNameTextStyle;
    namePrevBtn ??= "PREV";
    renderPrevBtn ??= Text(
      namePrevBtn!,
      style: styleNamePrevBtn,
    );
    isShowDoneBtn ??= true;

    isShowNextBtn ??= true;

    // Done button
    onDonePress ??= () {};
    styleNameDoneBtn ??= defaultBtnNameTextStyle;
    nameDoneBtn ??= "DONE";
    renderDoneBtn ??= Text(
      nameDoneBtn!,
      style: styleNameDoneBtn,
    );

    // Next button
    nameNextBtn ??= "NEXT";
    renderNextBtn ??= Text(
      nameNextBtn!,
      style: styleNameDoneBtn,
    );
  }

  void goToTab(int index) {
    if (index < tabController.length) {
      tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  // Checking if tab is animating
  bool isAnimating() {
    return tabController.animation!.value -
            tabController.animation!.value.truncate() !=
        0;
  }

  bool isRTLLanguage(Language language) {
    return false;
//    return rtlLanguages.contains(language);
  }

  @override
  Widget build(BuildContext context) {
    if (listCustomTabs == null) {
      tabs = renderListTabs().cast<Widget>();
    } else {
      tabs = listCustomTabs;
    }
    return Scaffold(
      body: DefaultTabController(
        length: slides.length,
        child: Stack(
          children: <Widget>[
            TabBarView(
              children: tabs!,
              controller: tabController,
              physics: const ScrollPhysics(),
            ),
            renderBottom(),
          ],
        ),
      ),
      backgroundColor: backgroundColorAllSlides,
    );
  }

  Widget buildSkipButton() {
    if (tabController.index + 1 == slides.length) {
      return Container();
    } else {
      return TextButton(
        onPressed: () {
          onSkipPress?.call();
        },
        child: renderSkipBtn!,
      );
    }
  }

  Widget buildDoneButton() {
    return TextButton(
      onPressed: () => onDonePress?.call(),
      child: renderDoneBtn!,
    );
  }

  Widget buildPrevButton() {
    if (tabController.index == 0) {
      return Container();
    } else {
      return TextButton(
        onPressed: () {
          if (!isAnimating()) {
            tabController.animateTo(tabController.index - 1);
          }
        },
        child: renderPrevBtn!,
      );
    }
  }

  Widget buildNextButton() {
    return TextButton(
      onPressed: () {
        if (!isAnimating()) {
          tabController.animateTo(tabController.index + 1);
        }
      },
      child: renderNextBtn!,
    );
  }

  Widget renderBottom() {
    return Positioned(
      child: Row(
        children: <Widget>[
          // Skip button
          Container(
            alignment: Alignment.center,
            child: isShowSkipBtn!
                ? buildSkipButton()
                : (isShowPrevBtn! ? buildPrevButton() : Container()),
          ),

          // Dot indicator
          Flexible(
            child: isShowDotIndicator!
                ? Stack(
                    children: <Widget>[
                      Row(
                        children: (tabController.index + 1 == slides.length)
                            ? [Container()]
                            : renderListDots(),
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Container()
                    ],
                  )
                : Container(),
          ),

          // Next, Done button
          Container(
            alignment: Alignment.center,
            child: tabController.index + 1 == slides.length
                ? isShowDoneBtn!
                    ? buildDoneButton()
                    : Container()
                : isShowNextBtn!
                    ? buildNextButton()
                    : Container(),
            height: 50,
          ),
        ],
      ),
      bottom: 10.0,
      left: 10.0,
      right: 10.0,
    );
  }

  List<Widget?> renderListTabs() {
    final t = <Widget?>[];
    for (var i = 0; i < slides.length; i++) {
      t.add(
        renderTab(
          slides[i].widgetTitle,
          slides[i].title,
          slides[i].maxLineTitle,
          slides[i].styleTitle,
          slides[i].marginTitle,
          slides[i].widgetDescription,
          slides[i].description,
          slides[i].maxLineTextDescription,
          slides[i].styleDescription,
          slides[i].marginDescription,
          slides[i].pathImage,
          slides[i].widthImage,
          slides[i].heightImage,
          slides[i].foregroundImageFit,
          slides[i].centerWidget,
          slides[i].onCenterItemPress,
          slides[i].backgroundColor,
          slides[i].colorBegin,
          slides[i].colorEnd,
          slides[i].directionColorBegin,
          slides[i].directionColorEnd,
          slides[i].backgroundImage,
          slides[i].backgroundImageFit,
          slides[i].backgroundOpacity,
          slides[i].backgroundOpacityColor,
          slides[i].backgroundBlendMode,
        ),
      );
    }
    return t;
  }

  Widget renderTab(
    // Title
    Widget? widgetTitle,
    String? title,
    int? maxLineTitle,
    TextStyle? styleTitle,
    EdgeInsets? marginTitle,

    // Description
    Widget? widgetDescription,
    String? description,
    int? maxLineTextDescription,
    TextStyle? styleDescription,
    EdgeInsets? marginDescription,

    // Image
    String? pathImage,
    double? widthImage,
    double? heightImage,
    BoxFit? foregroundImageFit,

    // Center Widget
    Widget? centerWidget,
    Function? onCenterItemPress,

    // Background color
    Color? backgroundColor,
    Color? colorBegin,
    Color? colorEnd,
    AlignmentGeometry? directionColorBegin,
    AlignmentGeometry? directionColorEnd,

    // Background image
    String? backgroundImage,
    BoxFit? backgroundImageFit,
    double? backgroundOpacity,
    Color? backgroundOpacityColor,
    BlendMode? backgroundBlendMode,
  ) {
    final animationSize = animationSquareSize(context);
    return Container(
      padding: EdgeInsets.only(top: animationSize + 40),
      width: double.infinity,
      height: double.infinity,
      decoration: backgroundImage != null
          ? BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: backgroundImageFit,
                colorFilter: ColorFilter.mode(
                  backgroundOpacityColor != null
                      ? backgroundOpacityColor.withOpacity(backgroundOpacity!)
                      : Colors.black.withOpacity(backgroundOpacity!),
                  backgroundBlendMode ?? BlendMode.darken,
                ),
              ),
            )
          : null,
      child: Container(
        // Title
        child: widgetTitle ??
            Text(
              title ?? "",
              style: styleTitle ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
              maxLines: maxLineTitle ?? 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
        margin: marginTitle ??
            const EdgeInsets.only(
              top: 20.0,
              bottom: 60.0,
              left: 20.0,
              right: 20.0,
            ),
      ),
    );
  }

  List<Widget> renderListDots() {
    dots.clear();
    for (var i = 0; i < slides.length; i++) {
      dots.add(renderDot(sizeDots[i], colorDot!, opacityDots[i]));
    }
    return dots;
  }

  Widget renderDot(double radius, Color color, double opacity) {
    return Opacity(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius / 2),
        ),
        width: radius,
        height: radius,
        margin: EdgeInsets.only(left: radius / 2, right: radius / 2),
      ),
      opacity: opacity,
    );
  }
}

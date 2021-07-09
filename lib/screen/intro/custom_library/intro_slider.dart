import 'package:deliver_flutter/theme/constants.dart';
import 'package:flutter/material.dart';

import 'slide_object.dart';

class IntroSlider extends StatefulWidget {
  // ---------- Slides ----------
  /// An array of Slide object
  final List<Slide> slides;

  /// Background color for all slides
  final Color backgroundColorAllSlides;

  // ---------- SKIP button ----------
  /// Render your own SKIP button
  final Widget renderSkipBtn;

  /// Width of view wrapper SKIP button
  final double widthSkipBtn;

  /// Fire when press SKIP button
  final Function onSkipPress;

  /// Change SKIP to any text you want
  final String nameSkipBtn;

  /// Style for text at SKIP button
  final TextStyle styleNameSkipBtn;

  /// Color for SKIP button
  final Color colorSkipBtn;

  /// Color for Skip button when press
  final Color highlightColorSkipBtn;

  /// Show or hide SKIP button
  final bool isShowSkipBtn;

  /// Rounded SKIP button
  final double borderRadiusSkipBtn;

  // ---------- PREV button ----------
  /// Render your own PREV button
  final Widget renderPrevBtn;

  /// Width of view wrapper PREV button
  final double widthPrevBtn;

  /// Change PREV to any text you want
  final String namePrevBtn;

  /// Style for text at PREV button
  final TextStyle styleNamePrevBtn;

  /// Color for PREV button
  final Color colorPrevBtn;

  /// Color for PREV button when press
  final Color highlightColorPrevBtn;

  /// Show or hide PREV button (only visible if skip is hidden)
  final bool isShowPrevBtn;

  /// Rounded PREV button
  final double borderRadiusPrevBtn;

  // ---------- NEXT button ----------
  /// Render your own NEXT button
  final Widget renderNextBtn;

  /// Change NEXT to any text you want
  final String nameNextBtn;

  /// Show or hide NEXT button
  final bool isShowNextBtn;

  // ---------- DONE button ----------
  /// Change DONE to any text you want
  final String nameDoneBtn;

  /// Render your own DONE button
  final Widget renderDoneBtn;

  /// Width of view wrapper DONE button
  final double widthDoneBtn;

  /// Fire when press DONE button
  final Function onDonePress;

  /// Style for text at DONE button
  final TextStyle styleNameDoneBtn;

  /// Color for DONE button
  final Color colorDoneBtn;

  /// Color for DONE button when press
  final Color highlightColorDoneBtn;

  /// Rounded DONE button
  final double borderRadiusDoneBtn;

  /// Show or hide DONE button
  final bool isShowDoneBtn;

  // ---------- Dot indicator ----------
  /// Show or hide dot indicator
  final bool isShowDotIndicator;

  /// Color for dot when passive
  final Color colorDot;

  /// Color for dot when active
  final Color colorActiveDot;

  /// Size of each dot
  final double sizeDot;

  // ---------- Tabs ----------
  /// Render your own custom tabs
  final List<Widget> listCustomTabs;

  final Function onAnimationChange;

  // Constructor
  IntroSlider({
    // Slides
    @required this.slides,
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
  });

  @override
  IntroSliderState createState() {
    return new IntroSliderState(
        // Slides
        slides: this.slides,
        backgroundColorAllSlides: this.backgroundColorAllSlides,

        // Skip
        renderSkipBtn: this.renderSkipBtn,
        widthSkipBtn: this.widthSkipBtn,
        onSkipPress: this.onSkipPress,
        nameSkipBtn: this.nameSkipBtn,
        styleNameSkipBtn: this.styleNameSkipBtn,
        colorSkipBtn: this.colorSkipBtn,
        highlightColorSkipBtn: this.highlightColorSkipBtn,
        isShowSkipBtn: this.isShowSkipBtn,
        borderRadiusSkipBtn: this.borderRadiusSkipBtn,

        // Prev
        renderPrevBtn: this.renderPrevBtn,
        widthPrevBtn: this.widthPrevBtn,
        namePrevBtn: this.namePrevBtn,
        isShowPrevBtn: this.isShowPrevBtn,
        styleNamePrevBtn: this.styleNamePrevBtn,
        colorPrevBtn: this.colorPrevBtn,
        highlightColorPrevBtn: this.highlightColorPrevBtn,
        borderRadiusPrevBtn: this.borderRadiusPrevBtn,

        // Done
        renderDoneBtn: this.renderDoneBtn,
        widthDoneBtn: this.widthDoneBtn,
        onDonePress: this.onDonePress,
        nameDoneBtn: this.nameDoneBtn,
        styleNameDoneBtn: this.styleNameDoneBtn,
        colorDoneBtn: this.colorDoneBtn,
        highlightColorDoneBtn: this.highlightColorDoneBtn,
        borderRadiusDoneBtn: this.borderRadiusDoneBtn,
        isShowDoneBtn: this.isShowDoneBtn,

        // Next
        renderNextBtn: this.renderNextBtn,
        nameNextBtn: this.nameNextBtn,
        isShowNextBtn: this.isShowNextBtn,

        // Dots
        isShowDotIndicator: this.isShowDotIndicator,
        colorDot: this.colorDot,
        colorActiveDot: this.colorActiveDot,
        sizeDot: this.sizeDot,

        // Tabs
        listCustomTabs: this.listCustomTabs,

        // Behavior
        onAnimationChange: this.onAnimationChange);
  }
}

class IntroSliderState extends State<IntroSlider>
    with SingleTickerProviderStateMixin {
  /// Default values
  static TextStyle defaultBtnNameTextStyle = TextStyle(color: Colors.white);

  static double defaultBtnBorderRadius = 30.0;

  static Color defaultBtnColor = Colors.transparent;

  static Color defaultBtnHighlightColor = Colors.white.withOpacity(0.3);

  // ---------- Slides ----------
  /// An array of Slide object
  final List<Slide> slides;

  /// Background color for all slides
  Color backgroundColorAllSlides;

  // ---------- SKIP button ----------
  /// Render your own SKIP button
  Widget renderSkipBtn;

  /// Width of view wrapper SKIP button
  double widthSkipBtn;

  /// Fire when press SKIP button
  Function onSkipPress;

  /// Change SKIP to any text you want
  String nameSkipBtn;

  /// Style for text at SKIP button
  TextStyle styleNameSkipBtn;

  /// Color for SKIP button
  Color colorSkipBtn;

  /// Color for SKIP button when press
  Color highlightColorSkipBtn;

  /// Show or hide SKIP button
  bool isShowSkipBtn;

  /// Rounded SKIP button
  double borderRadiusSkipBtn;

  // ---------- PREV button ----------
  /// Render your own PREV button
  Widget renderPrevBtn;

  /// Change PREV to any text you want
  String namePrevBtn;

  /// Style for text at PREV button
  TextStyle styleNamePrevBtn;

  /// Color for PREV button
  Color colorPrevBtn;

  /// Width of view wrapper PREV button
  double widthPrevBtn;

  /// Color for PREV button when press
  Color highlightColorPrevBtn;

  /// Show or hide PREV button
  bool isShowPrevBtn;

  /// Rounded PREV button
  double borderRadiusPrevBtn;

  // ---------- DONE button ----------
  /// Render your own DONE button
  Widget renderDoneBtn;

  /// Width of view wrapper DONE button
  double widthDoneBtn;

  /// Fire when press DONE button
  Function onDonePress;

  /// Change DONE to any text you want
  String nameDoneBtn;

  /// Style for text at DONE button
  TextStyle styleNameDoneBtn;

  /// Color for DONE button
  Color colorDoneBtn;

  /// Color for DONE button when press
  Color highlightColorDoneBtn;

  /// Rounded DONE button
  double borderRadiusDoneBtn;

  /// Show or hide DONE button
  bool isShowDoneBtn;

  // ---------- NEXT button ----------
  /// Render your own NEXT button
  Widget renderNextBtn;

  /// Change NEXT to any text you want
  String nameNextBtn;

  /// Show or hide NEXT button
  bool isShowNextBtn;

  // ---------- Dot indicator ----------
  /// Show or hide dot indicator
  bool isShowDotIndicator = true;

  /// Color for dot when passive
  Color colorDot;

  /// Color for dot when active
  Color colorActiveDot;

  /// Size of each dot
  double sizeDot = 8.0;

  // ---------- Tabs ----------
  /// List custom tabs
  List<Widget> listCustomTabs;

  Function onAnimationChange;

  // Constructor
  IntroSliderState({
    // List slides
    @required this.slides,
    @required this.backgroundColorAllSlides,

    // Skip button
    @required this.renderSkipBtn,
    @required this.widthSkipBtn,
    @required this.onSkipPress,
    @required this.nameSkipBtn,
    @required this.styleNameSkipBtn,
    @required this.colorSkipBtn,
    @required this.highlightColorSkipBtn,
    @required this.isShowSkipBtn,
    @required this.borderRadiusSkipBtn,

    // Prev button
    @required this.widthPrevBtn,
    @required this.isShowPrevBtn,
    @required this.namePrevBtn,
    @required this.renderPrevBtn,
    @required this.styleNamePrevBtn,
    @required this.colorPrevBtn,
    @required this.highlightColorPrevBtn,
    @required this.borderRadiusPrevBtn,

    // Done button
    @required this.renderDoneBtn,
    @required this.widthDoneBtn,
    @required this.onDonePress,
    @required this.nameDoneBtn,
    @required this.styleNameDoneBtn,
    @required this.colorDoneBtn,
    @required this.highlightColorDoneBtn,
    @required this.borderRadiusDoneBtn,
    @required this.isShowDoneBtn,

    // Next button
    @required this.nameNextBtn,
    @required this.renderNextBtn,
    @required this.isShowNextBtn,

    // Dot indicator
    @required this.isShowDotIndicator,
    @required this.colorDot,
    @required this.colorActiveDot,
    @required this.sizeDot,

    // Tabs
    @required this.listCustomTabs,
    @required this.onAnimationChange,
  });

  TabController tabController;

  List<Widget> tabs = [];
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
    tabController = new TabController(length: slides.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        currentTabIndex = tabController.previousIndex;
      } else {
        currentTabIndex = tabController.index;
      }
      currentAnimationValue = tabController.animation.value;
    });

    // Dot animation
    if (sizeDot == null) {
      sizeDot = 8.0;
    }
    double initValueMarginRight = (sizeDot * 2) * (slides.length - 1);

    for (int i = 0; i < slides.length; i++) {
      if (i == 0) {
        sizeDots.add(sizeDot * 1.5);
        opacityDots.add(1.0);
      } else {
        sizeDots.add(sizeDot);
        opacityDots.add(0.5);
      }
    }

    tabController.animation.addListener(() {
      this.setState(() {
        onAnimationChange?.call(tabController.animation.value);
        if (tabController.animation.value == currentAnimationValue) {
          return;
        }

        double diffValueAnimation =
            (tabController.animation.value - currentAnimationValue).abs();
        int diffValueIndex = (currentTabIndex - tabController.index).abs();

        // When press skip button
        if (tabController.indexIsChanging &&
            (tabController.index - tabController.previousIndex).abs() > 1) {
          if (diffValueAnimation < 1.0) {
            diffValueAnimation = 1.0;
          }
          sizeDots[currentTabIndex] = sizeDot * 1.5 -
              (sizeDot / 2) * (1 - (diffValueIndex - diffValueAnimation));
          sizeDots[tabController.index] = sizeDot +
              (sizeDot / 2) * (1 - (diffValueIndex - diffValueAnimation));
          opacityDots[currentTabIndex] =
              1.0 - (diffValueAnimation / diffValueIndex) / 2;
          opacityDots[tabController.index] =
              0.5 + (diffValueAnimation / diffValueIndex) / 2;
        } else {
          if (tabController.animation.value > currentAnimationValue) {
            // Swipe left
            sizeDots[currentTabIndex] =
                sizeDot * 1.5 - (sizeDot / 2) * diffValueAnimation;
            sizeDots[currentTabIndex + 1] =
                sizeDot + (sizeDot / 2) * diffValueAnimation;
            opacityDots[currentTabIndex] = 1.0 - diffValueAnimation / 2;
            opacityDots[currentTabIndex + 1] = 0.5 + diffValueAnimation / 2;
          } else {
            // Swipe right
            sizeDots[currentTabIndex] =
                sizeDot * 1.5 - (sizeDot / 2) * diffValueAnimation;
            sizeDots[currentTabIndex - 1] =
                sizeDot + (sizeDot / 2) * diffValueAnimation;
            opacityDots[currentTabIndex] = 1.0 - diffValueAnimation / 2;
            opacityDots[currentTabIndex - 1] = 0.5 + diffValueAnimation / 2;
          }
        }
      });
    });

    // Dot indicator
    if (isShowDotIndicator == null) {
      isShowDotIndicator = true;
    }
    if (colorDot == null) {
      colorDot = Color(0x80000000);
    }
    if (colorActiveDot == null) {
      colorActiveDot = colorDot;
    }

    setupButtonDefaultValues();
    super.initState();
  }

  void setupButtonDefaultValues() {
    // Skip button
    if (onSkipPress == null) {
      onSkipPress = () {
        if (!this.isAnimating(tabController.animation.value)) {
          tabController.animateTo(slides.length - 1);
        }
      };
    }
    if (isShowSkipBtn == null) {
      isShowSkipBtn = true;
    }
    if (styleNameSkipBtn == null) {
      styleNameSkipBtn = defaultBtnNameTextStyle;
    }
    if (nameSkipBtn == null) {
      nameSkipBtn = "SKIP";
    }
    if (renderSkipBtn == null) {
      renderSkipBtn = Text(
        nameSkipBtn,
        style: styleNameSkipBtn,
      );
    }
    if (colorSkipBtn == null) {
      colorSkipBtn = defaultBtnColor;
    }
    if (highlightColorSkipBtn == null) {
      highlightColorSkipBtn = defaultBtnHighlightColor;
    }
    if (borderRadiusSkipBtn == null) {
      borderRadiusSkipBtn = defaultBtnBorderRadius;
    }

    // Prev button
    if (isShowPrevBtn == null || isShowSkipBtn) {
      isShowPrevBtn = false;
    }
    if (styleNamePrevBtn == null) {
      styleNamePrevBtn = defaultBtnNameTextStyle;
    }
    if (namePrevBtn == null) {
      namePrevBtn = "PREV";
    }
    if (renderPrevBtn == null) {
      renderPrevBtn = Text(
        namePrevBtn,
        style: styleNamePrevBtn,
      );
    }
    if (colorPrevBtn == null) {
      colorPrevBtn = defaultBtnColor;
    }
    if (highlightColorPrevBtn == null) {
      highlightColorPrevBtn = defaultBtnHighlightColor;
    }
    if (borderRadiusPrevBtn == null) {
      borderRadiusPrevBtn = defaultBtnBorderRadius;
    }
    if (isShowDoneBtn == null) {
      isShowDoneBtn = true;
    }

    if (isShowNextBtn == null) {
      isShowNextBtn = true;
    }

    // Done button
    if (onDonePress == null) {
      onDonePress = () {};
    }
    if (styleNameDoneBtn == null) {
      styleNameDoneBtn = defaultBtnNameTextStyle;
    }
    if (nameDoneBtn == null) {
      nameDoneBtn = "DONE";
    }
    if (renderDoneBtn == null) {
      renderDoneBtn = Text(
        nameDoneBtn,
        style: styleNameDoneBtn,
      );
    }
    if (colorDoneBtn == null) {
      colorDoneBtn = defaultBtnColor;
    }
    if (highlightColorDoneBtn == null) {
      highlightColorDoneBtn = defaultBtnHighlightColor;
    }
    if (borderRadiusDoneBtn == null) {
      borderRadiusDoneBtn = defaultBtnBorderRadius;
    }

    // Next button
    if (nameNextBtn == null) {
      nameNextBtn = "NEXT";
    }
    if (renderNextBtn == null) {
      renderNextBtn = Text(
        nameNextBtn,
        style: styleNameDoneBtn,
      );
    }
  }

  void goToTab(index) {
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
  bool isAnimating(value) {
    return tabController.animation.value -
            tabController.animation.value.truncate() !=
        0;
  }

  bool isRTLLanguage(language) {
    return false;
//    return rtlLanguages.contains(language);
  }

  @override
  Widget build(BuildContext context) {
    if (this.listCustomTabs == null) {
      tabs = renderListTabs();
    } else {
      tabs = this.listCustomTabs;
    }
    return Scaffold(
      body: DefaultTabController(
        length: slides.length,
        child: Stack(
          children: <Widget>[
            TabBarView(
              children: tabs,
              controller: tabController,
              physics: ScrollPhysics(),
            ),
            renderBottom(),
          ],
        ),
      ),
      backgroundColor: this.backgroundColorAllSlides ?? Colors.transparent,
    );
  }

  Widget buildSkipButton() {
    if (tabController.index + 1 == slides.length) {
      return Container();
    } else {
      return FlatButton(
        onPressed: onSkipPress,
        child: renderSkipBtn,
        color: colorSkipBtn,
        highlightColor: highlightColorSkipBtn,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(borderRadiusSkipBtn)),
      );
    }
  }

  Widget buildDoneButton() {
    return FlatButton(
      onPressed: onDonePress,
      child: renderDoneBtn,
      color: colorDoneBtn,
      highlightColor: highlightColorDoneBtn,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(borderRadiusDoneBtn)),
    );
  }

  Widget buildPrevButton() {
    if (tabController.index == 0) {
      return Container();
    } else {
      return FlatButton(
        onPressed: () {
          if (!this.isAnimating(tabController.animation.value)) {
            tabController.animateTo(tabController.index - 1);
          }
        },
        child: renderPrevBtn,
        color: colorPrevBtn,
        highlightColor: highlightColorPrevBtn,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(borderRadiusPrevBtn)),
      );
    }
  }

  Widget buildNextButton() {
    return FlatButton(
      onPressed: () {
        if (!this.isAnimating(tabController.animation.value)) {
          tabController.animateTo(tabController.index + 1);
        }
      },
      child: renderNextBtn,
      color: colorDoneBtn,
      highlightColor: highlightColorDoneBtn,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(borderRadiusDoneBtn)),
    );
  }

  Widget renderBottom() {
    return Positioned(
      child: Row(
        children: <Widget>[
          // Skip button
          Container(
            alignment: Alignment.center,
            child: isShowSkipBtn
                ? buildSkipButton()
                : (isShowPrevBtn ? buildPrevButton() : Container()),
          ),

          // Dot indicator
          Flexible(
            child: isShowDotIndicator
                ? Container(
                    child: Stack(
                      children: <Widget>[
                        Row(
                          children: (tabController.index + 1 == slides.length)
                              ? [Container()]
                              : this.renderListDots(),
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        Container()
                      ],
                    ),
                  )
                : Container(),
          ),

          // Next, Done button
          Container(
            alignment: Alignment.center,
            child: tabController.index + 1 == slides.length
                ? isShowDoneBtn
                    ? buildDoneButton()
                    : Container()
                : isShowNextBtn
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

  List<Widget> renderListTabs() {
    List<Widget> t = [];
    for (int i = 0; i < slides.length; i++) {
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
    Widget widgetTitle,
    String title,
    int maxLineTitle,
    TextStyle styleTitle,
    EdgeInsets marginTitle,

    // Description
    Widget widgetDescription,
    String description,
    int maxLineTextDescription,
    TextStyle styleDescription,
    EdgeInsets marginDescription,

    // Image
    String pathImage,
    double widthImage,
    double heightImage,
    BoxFit foregroundImageFit,

    // Center Widget
    Widget centerWidget,
    Function onCenterItemPress,

    // Background color
    Color backgroundColor,
    Color colorBegin,
    Color colorEnd,
    AlignmentGeometry directionColorBegin,
    AlignmentGeometry directionColorEnd,

    // Background image
    String backgroundImage,
    BoxFit backgroundImageFit,
    double backgroundOpacity,
    Color backgroundOpacityColor,
    BlendMode backgroundBlendMode,
  ) {
    double animationSize = ANIMATION_SQUARE_SIZE(context);
    double paddingTop = ANIMATION_TOP_PADDING(context);
    return Container(
      padding: EdgeInsets.only(top: animationSize + paddingTop),
      width: double.infinity,
      height: double.infinity,
      decoration: backgroundImage != null
          ? BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: backgroundImageFit ?? BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  backgroundOpacityColor != null
                      ? backgroundOpacityColor
                          .withOpacity(backgroundOpacity ?? 0.5)
                      : Colors.black.withOpacity(backgroundOpacity ?? 0.5),
                  backgroundBlendMode ?? BlendMode.darken,
                ),
              ),
            )
          : BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundColor != null
                    ? [backgroundColor, backgroundColor]
                    : [
                        colorBegin ?? Colors.amberAccent,
                        colorEnd ?? Colors.amberAccent
                      ],
                begin: directionColorBegin ?? Alignment.topLeft,
                end: directionColorEnd ?? Alignment.bottomRight,
              ),
            ),
      child: Container(
        // Title
        child: widgetTitle ??
            Text(
              title ?? "",
              style: styleTitle ??
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
              maxLines: maxLineTitle != null ? maxLineTitle : 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
        margin: marginTitle ??
            EdgeInsets.only(top: 20.0, bottom: 60.0, left: 20.0, right: 20.0),
      ),
    );
  }

  List<Widget> renderListDots() {
    dots.clear();
    for (int i = 0; i < slides.length; i++) {
      dots.add(renderDot(sizeDots[i], colorDot, opacityDots[i]));
    }
    return dots;
  }

  Widget renderDot(double radius, Color color, double opacity) {
    return Opacity(
      child: Container(
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(radius / 2)),
        width: radius,
        height: radius,
        margin: EdgeInsets.only(left: radius / 2, right: radius / 2),
      ),
      opacity: opacity,
    );
  }
}

import 'package:animations/animations.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/screen/room/pages/room_page.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  final _logger = GetIt.I.get<Logger>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();

  late InAppWebViewController webViewController;
  late PullToRefreshController? pullToRefreshController;
  late WebMessagePort? weMessengerChannel;
  final GlobalKey webViewKey = GlobalKey();
  final webViewSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
    supportZoom: false,
  );
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  final _isScrolling = BehaviorSubject.seeded(
    ScrollingState(0, ScrollingDirection.UP, isScrolling: false),
  );

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          await webViewController.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          await webViewController.loadUrl(
            urlRequest: URLRequest(
              url: await webViewController.getUrl(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest:
                        URLRequest(url: WebUri(settings.webViewUrl.value)), // http://172.16.121.131/
                    initialSettings: webViewSettings,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onPermissionRequest: (controller, request) async {
                      return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT,
                      );
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      final uri = navigationAction.request.url!;

                      if (![
                        "http",
                        "https",
                        "file",
                        "chrome",
                        "data",
                        "javascript",
                        "about"
                      ].contains(uri.scheme)) {
                        if (await canLaunchUrl(uri)) {
                          // Launch the App
                          await launchUrl(
                            uri,
                          );
                          // and cancel the request
                          return NavigationActionPolicy.CANCEL;
                        }
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) async {
                      await pullToRefreshController?.endRefreshing();
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                      await initializeWebChannel(controller);
                    },
                    onReceivedError: (controller, request, error) {
                      pullToRefreshController?.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController?.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress / 100;
                        urlController.text = url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                    },
                    onScrollChanged: (controller, x, y) {
                      final direction = getScrollingDirection(y);
                      _isScrolling.add(
                        ScrollingState(
                          y.toDouble(),
                          direction,
                          isScrolling: true,
                        ),
                      );
                    },
                  ),
                  if (progress < 1.0)
                    Shimmer.fromColors(
                      baseColor: theme.outline.withOpacity(0.15),
                      highlightColor: theme.onSurface.withOpacity(0.23),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.surface,
                        ),
                        height: size.height,
                        width: size.width,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  StreamBuilder<ScrollingState>(
                    stream: _isScrolling,
                    builder: (context, snapshot) {
                      Widget renderer;
                      if (snapshot.hasData &&
                          snapshot.data!.scrollingDirection ==
                              ScrollingDirection.UP) {
                        renderer = Container(
                          decoration: BoxDecoration(
                            color: theme.secondary.withOpacity(
                              0.3,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(p8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ElevatedButton(
                                      child: const Icon(Icons.arrow_back),
                                      onPressed: () async {
                                        webViewController.goForward();
                                        webViewController.evaluateJavascript(
                                            source: "changeBackground('red')");
                                      },
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      child: const Icon(Icons.arrow_forward),
                                      onPressed: () async {
                                        webViewController.goBack();
                                        webViewController.evaluateJavascript(
                                            source: "changeBackground('blue')");
                                      },
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  child: const Icon(Icons.refresh),
                                  onPressed: () {
                                    webViewController.reload();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        renderer = const SizedBox.shrink();
                      }
                      return PageTransitionSwitcher(
                        duration: AnimationSettings.verySlow,
                        transitionBuilder: (
                          child,
                          animation,
                          secondaryAnimation,
                        ) {
                          return SharedAxisTransition(
                            fillColor: Colors.transparent,
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            child: child,
                          );
                        },
                        child: renderer,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initializeWebChannel(InAppWebViewController controller) async {
    if (defaultTargetPlatform != TargetPlatform.android ||
        await WebViewFeature.isFeatureSupported(
          WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL,
        )) {
      // wait until the page is loaded, and then create the Web Message Channel
      final webMessageChannel = await controller.createWebMessageChannel();
      weMessengerChannel = webMessageChannel!.port1;
      final port2 = webMessageChannel.port2;

      // set the web message callback for the port1
      await weMessengerChannel!.setWebMessageCallback((message) async {
        _logger.i("Message coming from web side: $message");
        final command = ChannelCommunicationCommands.values.byName(message!);
        switch (command) {
          case ChannelCommunicationCommands.IDENTIFICATION:
            //TODO implemete call profile Service and get identiry Token
            //_sdr.userServiceClient.
            await weMessengerChannel!.postMessage(
              WebMessage(data: "09379612324"),
            );
            break;
        }
      });
      // transfer port2 to the webpage to initialize the communication
      await controller.postWebMessage(
        message: WebMessage(data: "capturePort", ports: [port2]),
        targetOrigin: WebUri(
          "*",
        ),
      );
    }
  }

  ScrollingDirection getScrollingDirection(int pixel) {
    final oldPixel = _isScrolling.valueOrNull?.pixel ?? 0;

    return (pixel >= oldPixel)
        ? ScrollingDirection.DOWN
        : ScrollingDirection.UP;
  }
}

enum ChannelCommunicationCommands {
  IDENTIFICATION,
}

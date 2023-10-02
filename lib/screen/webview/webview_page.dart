import 'dart:async';
import 'dart:convert';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

// commands
const IDENTIFICATION = "IDENTIFICATION";

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  static final _routingService = GetIt.I.get<RoutingService>();
  final _logger = GetIt.I.get<Logger>();
  final _i18n = GetIt.I.get<I18N>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();

  InAppWebViewController? webViewController;
  late PullToRefreshController? pullToRefreshController;
  late WebMessagePort? weMessengerChannel;
  final webViewSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
    supportZoom: false,
    overScrollMode: OverScrollMode.ALWAYS,
  );
  final progress = BehaviorSubject<double>.seeded(0.0);

  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Scaffold(
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
                        URLRequest(url: WebUri(settings.webViewUrl.value)),
                    initialSettings: webViewSettings,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onReceivedError: (controller, request, error) async {
                      unawaited(pullToRefreshController?.endRefreshing());
                      // Handle web page loading errors here
                      final isForMainFrame = request.isForMainFrame ?? false;
                      if (!isForMainFrame ||
                          (!kIsWeb &&
                              defaultTargetPlatform == TargetPlatform.iOS &&
                              error.type == WebResourceErrorType.CANCELLED)) {
                        return;
                      }

                      final errorUrl = request.url;

                      await controller.loadData(
                        data: notAvailable(
                          _i18n.get("store_not_available"),
                          _i18n.get("reload"),
                          colorListToCss([
                            ...getCorePaletteList(settings.corePalette),
                            ...getThemeDataColorList(settings.themeData)
                          ]),
                        ),
                        baseUrl: errorUrl,
                        historyUrl: errorUrl,
                      );
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
                      await injectCss(controller);
                      await initializeWebChannel(controller);
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController?.endRefreshing();
                      }

                      this.progress.add(progress / 100);
                    },
                  ),
                  StreamBuilder<double>(
                    stream: progress,
                    builder: (context, snapshot) {
                      final p = snapshot.data ?? 0;
                      if (p < 1.0) {
                        return Shimmer.fromColors(
                          baseColor: theme.outline.withOpacity(0.15),
                          highlightColor: theme.onSurface.withOpacity(0.23),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.surface,
                            ),
                            height: size.height,
                            width: size.width,
                          ),
                        );
                      }

                      return const SizedBox.shrink();
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

  @override
  void initState() {
    super.initState();

    _routingService.registerPreMaybePopScope(
      "web_view_page",
      checkWebviewCanBackOrNot,
    );

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: settings.themeData.colorScheme.primaryContainer,
        backgroundColor: settings.themeData.colorScheme.onPrimaryContainer,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          await webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          await webViewController?.loadUrl(
            urlRequest: URLRequest(
              url: await webViewController?.getUrl(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _routingService.unregisterPreMaybePopScope("web_view_page");
    super.dispose();
  }

  Future<bool> checkWebviewCanBackOrNot() async {
    if (webViewController == null) {
      return true;
    }
    if (await webViewController!.canGoBack()) {
      unawaited(webViewController!.goBack());

      return false;
    }
    return true;
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
        try {
          final command = jsonDecode(message ?? "{}");

          _logger.i("Message coming from web side: $message");

          switch (command["command"]) {
            case IDENTIFICATION:
              final res = await _sdr.userServiceClient
                  .getWebViewIdentifyToken(GetWebViewIdentifyTokenReq());

              final data = {
                "command": IDENTIFICATION,
                "data": {"bearer": res.identifyToken}
              };

              await weMessengerChannel!.postMessage(
                WebMessage(data: jsonEncode(data)),
              );
              break;
          }
        } catch (e) {
          _logger.e("error on channel communication", e);
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

  Future<void> injectCss(InAppWebViewController controller) async {
    await controller.injectCSSCode(
      source: colorListToCss([
        ...getCorePaletteList(settings.corePalette),
        ...getThemeDataColorList(settings.themeData)
      ]),
    );
  }
}

String notAvailable(String titleText, String reloadText, String css) => """
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <style>
      $css
      body {
        margin: 0;
        background:
          radial-gradient(circle at center, var(--we-color-primary-container), var(--we-color-background)); 
      }
      .center {
        height: 100vh;
        display: flex;
        align-content: center;
        justify-content: center;
        flex-direction: column;
        align-items: center;
        color: var(--we-color-on-primary-container);
        padding: 24px 24px ;
        text-align: center; 
      }
      
      .not-available {
        width: min(128px, 50vw);
      }
      svg {
        fill: var(--we-color-on-primary-container); 
      }
      .button {
       font-family: "Open Sans", sans-serif;
       font-size: 16px;
       letter-spacing: 2px;
       text-decoration: none;
       text-transform: uppercase;
       color: var(--we-color-on-tertiary);
       cursor: pointer;
       border: 3px solid;
       background-color: var(--we-color-tertiary);
       padding: 0.25em 0.5em;
       box-shadow: 1px 1px 0px 0px, 2px 2px 0px 0px, 3px 3px 0px 0px, 4px 4px 0px 0px, 5px 5px 0px 0px;
       position: relative;
       user-select: none;
       -webkit-user-select: none;
       touch-action: manipulation;
      }
      .button:active {
        box-shadow: 0px 0px 0px 0px;
        top: 5px;
        left: 5px;
      }
      
      @media (min-width: 768px) {
        .button {
          padding: 0.25em 0.75em;
        }
      }
    </style>
  </head>
  <div class="center">
    <h2>$titleText</h2>
  
    <div class="not-available">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 40">
        <g data-name="404 Page Not Found">
          <path d="M30.83,4.77A5,5,0,0,0,26,1H6A5,5,0,0,0,1.15,4.83Z"/>
          <path
            d="M1,6.83V26a5,5,0,0,0,5,5H26a5,5,0,0,0,5-5V6.77Zm19.29,4.88a1,1,0,0,1,1.42-1.42L23,11.59l1.29-1.3a1,1,0,0,1,1.42,1.42L24.41,13l1.3,1.29a1,1,0,0,1,0,1.42,1,1,0,0,1-1.42,0L23,14.41l-1.29,1.3a1,1,0,0,1-1.42,0,1,1,0,0,1,0-1.42L21.59,13Zm-14,0a1,1,0,0,1,1.42-1.42L9,11.59l1.29-1.3a1,1,0,0,1,1.42,1.42L10.41,13l1.3,1.29a1,1,0,0,1,0,1.42,1,1,0,0,1-1.42,0L9,14.41l-1.29,1.3a1,1,0,0,1-1.42,0,1,1,0,0,1,0-1.42L7.59,13ZM26,22c-.34,0-.5.16-.9.64a2.86,2.86,0,0,1-4.87,0c-.41-.48-.57-.64-.91-.64s-.49.16-.89.64A3.08,3.08,0,0,1,16,24a3,3,0,0,1-2.43-1.36c-.41-.48-.56-.64-.9-.64s-.5.16-.9.64A3,3,0,0,1,9.33,24,3,3,0,0,1,6.9,22.64C6.47,22.13,6.32,22,6,22a1,1,0,0,1,0-2,3,3,0,0,1,2.43,1.36c.43.51.58.64.9.64s.49-.16.89-.64A3.08,3.08,0,0,1,12.66,20a3,3,0,0,1,2.43,1.36c.41.48.56.64.9.64s.5-.16.9-.64A3,3,0,0,1,19.32,20a3,3,0,0,1,2.44,1.36c.4.48.56.64.9.64s.5-.16.9-.64A3.08,3.08,0,0,1,26,20a1,1,0,0,1,0,2Z"/>
        </g>
      </svg>
    </div>
    
    <button class="button" onclick="location.reload();">$reloadText</button>
  </div>
</html>
""";

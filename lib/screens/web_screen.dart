import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:oishi/configuration.dart';
import 'package:oishi/js_bridge.dart';
import 'package:oishi/utils/notification_service.dart';
import 'web_screen_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'error_page.dart';

class WebScreen extends StatefulWidget {
  final String url;
  final String? pageTitle;
  final bool hasPageTitle;
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final VoidCallback? onLoadFinished;
  final List<ButtonConfig>? buttons;
  final String? logo;
  final ActionConfig? action;

  WebScreen({
    super.key,
    required this.url,
    this.logo,
    this.buttons,
    this.pageTitle,
    this.hasPageTitle = true,
    this.onLoadFinished,
    this.action,
  });

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen>
    with SingleTickerProviderStateMixin {
  late Duration timeout;
  Timer? _timeoutTimer;
  late final WebViewController _controller;
  late JsBridge jsBridge;

  final WebViewCookieManager _cookieManager = WebViewCookieManager();
  bool _hasError = false;
  bool canRefresh = false;
  String _errorMessage = '';
  bool isHapticWorking = false;
  bool finishedTouchingScreen = false;

  // Animation controller for refresh icon rotation
  late final AnimationController _refreshIconController;
  // Value notifier for refresh icon offset
  final ValueNotifier<double> _refreshIconOffset = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    jsBridge = JsBridge();
    jsBridge.buttons = widget.buttons;

    // Initialize animation controller
    _refreshIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Platform-specific WebView controller setup
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = const PlatformWebViewControllerCreationParams();
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        // if (message.level == JavaScriptLogLevel.error &&
        //     !message.message.contains('[object Object]')) {
        //   setState(() {
        //     _hasError = true;
        //     _errorMessage = 'Console Error: ${message.message}';
        //   });

        //   debugPrint('Console Error: ${message.message}');
        // }
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            timeout = const Duration(seconds: 30);
            setState(() {
              widget.isLoading.value = true;
            });

            // Cancel existing timer if any
            _timeoutTimer?.cancel();

            // Start new timer that decrements timeout every second
            _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (timeout.inSeconds > 0) {
                setState(() {
                  timeout = Duration(seconds: timeout.inSeconds - 1);
                });
              } else {
                timer.cancel();
                setState(() {
                  widget.isLoading.value = false;
                });
              }
            });
          },
          onPageFinished: (String url) {
            _timeoutTimer?.cancel();
            setState(() {
              widget.isLoading.value = false;
              isHapticWorking = false;
            });
            if (widget.onLoadFinished != null) {
              widget.onLoadFinished!();
            }
          },
          onWebResourceError: (WebResourceError error) {
            // setState(() {
            //   _hasError = true;
            //   _errorMessage = 'An error occurred: ${error.description}';
            // });
            // debugPrint('Console Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // Platform-specific settings
    if (!kIsWeb && controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
    jsBridge.registerBridge(controller, context, _cookieManager);

    // Listen to the 'refresh' event
    NotificationService().forEvent('refresh_${widget.pageTitle}').listen((_) {
      // Reload the web page when 'refresh_${widget.pageTitle}' is triggered
      if (mounted) {
        _controller.reload();
      }
    });
    // Listen to the 'refresh' event
    NotificationService().forEvent('refresh_all').listen((_) {
      // Reload the web page when 'refresh_${widget.pageTitle}' is triggered
      if (mounted) {
        _controller.reload();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    NotificationService().dispose('refresh_${widget.pageTitle}');
    _refreshIconController.dispose();
    _refreshIconOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebScreenAppBar(
        logo: widget.logo,
        pageTitle: widget.pageTitle,
        hasPageTitle: widget.hasPageTitle,
        buttons: widget.buttons ?? [],
        action: widget.action,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: widget.isLoading,
          builder: (context, loading, child) {
            return Container(
              color: Colors.white,
              child: Stack(
                children: [
                  if (!_hasError) ...[
                    RefreshIndicator(
                      onRefresh: () async {
                        _controller.reload();
                      },
                      child: Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: (_) {
                          finishedTouchingScreen = false;
                        },
                        onPointerUp: (_) {
                          finishedTouchingScreen = true;
                          if (canRefresh) {
                            canRefresh = false;
                            _controller.reload();
                          }
                        },
                        child: WebViewWidget(
                          controller: _controller,
                          gestureRecognizers: _buildGestureRecognizers(),
                        ),
                      ),
                    ),
                    // Custom refresh icon
                    ValueListenableBuilder<double>(
                      valueListenable: _refreshIconOffset,
                      builder: (context, offset, child) {
                        return Positioned(
                          top: -50 + (offset * 2),
                          left: 0,
                          right: 0,
                          child: Center(
                            child: RotationTransition(
                              turns: _refreshIconController,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  if (loading && !_hasError)
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (_hasError)
                    ErrorPage(
                      errorMessage: _errorMessage,
                      onReload: () {
                        setState(() {
                          _hasError = false;
                          widget.isLoading.value = true;
                        });
                        _controller.reload();
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Set<Factory<OneSequenceGestureRecognizer>> _buildGestureRecognizers() {
    return Set()
      ..add(
        Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer()
              ..onDown = (DragDownDetails dragDownDetails) {
                _controller.setOnScrollPositionChange((value) async {
                  // Update refresh icon position based on scroll
                  if (value.y < 0) {
                    _refreshIconOffset.value =
                        -value.y * 0.3; // Scale factor to control movement
                    if (!_refreshIconController.isAnimating) {
                      _refreshIconController.repeat();
                    }
                  } else {
                    _refreshIconOffset.value = 0;
                    if (_refreshIconController.isAnimating) {
                      _refreshIconController.stop();
                      _refreshIconController.reset();
                    }
                  }

                  final scrollY = value.y;
                  if (scrollY <= -100) {
                    canRefresh = true;
                    final canVibrate = await Haptics.canVibrate();
                    if (canVibrate && !isHapticWorking) {
                      isHapticWorking = true;
                      await Haptics.vibrate(HapticsType.success);
                    }
                  } else {
                    canRefresh = false;
                    isHapticWorking = false;
                  }
                });
              }
            // ..onEnd = (DragEndDetails dragEndDetails) {
            //   if (canRefresh) {
            //     _controller.reload();
            //     canRefresh = false;
            //   }
            // },
            ),
      );
  }
}

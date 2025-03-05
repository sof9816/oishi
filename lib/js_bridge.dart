import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oishi/configuration.dart';
import 'utils/notification_service.dart';
import 'utils/app_preferences.dart';
import 'enums/bridge_command.dart';
import 'screens/web_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JsBridge {
  WebViewController? _controller;
  List<ButtonConfig>? buttons;
  // Register the JS bridge and set the WebViewController
  void registerBridge(WebViewController controller, BuildContext context,
      WebViewCookieManager cookieManager) {
    _controller = controller;
    controller.addJavaScriptChannel(
      'WebToFlutter',
      onMessageReceived: (jsMessage) {
        _handleJsMessage(jsMessage.message, context, cookieManager);
      },
    );
  }

  // Handle messages coming from the web
  Future<void> _handleJsMessage(String message, BuildContext context,
      WebViewCookieManager cookieManager) async {
    try {
      final Map<String, dynamic> params = jsonDecode(message);
      await sendToFlutter(params, context, cookieManager);
    } catch (e) {
      debugPrint("Failed to decode message: $e");
    }
  }

  // Process the commands from the web
  Future<void> sendToFlutter(
    Map<String, dynamic> params,
    BuildContext context,
    WebViewCookieManager cookieManager,
  ) async {
    try {
      final String bridgeName = params['bridgeName'];
      final Map<String, dynamic> bridgeParams = params['params'] ?? {};
      final BridgeCommand command = BridgeCommand.fromString(bridgeName);
      switch (command) {
        case BridgeCommand.pop:
          _pop(context);
          break;
        case BridgeCommand.popRoot:
          _popToRoot(context);
          break;
        case BridgeCommand.push:
          _push(context, bridgeParams);
          break;
        case BridgeCommand.popAndPush:
          _popAndPush(context, bridgeParams);
          break;
        case BridgeCommand.popRootAndPush:
          _popRootAndPush(context, bridgeParams);
          break;
        case BridgeCommand.closeAndAlert:
          _handleAlert(context, bridgeParams);
          break;
        case BridgeCommand.getToken:
          await _getToken();
          break;
        case BridgeCommand.setToken:
          await _setToken(bridgeParams);
          break;
        case BridgeCommand.deleteToken:
          await _deleteToken();
          break;
        case BridgeCommand.refresh:
          _handleRefresh(bridgeParams);
          break;
        case BridgeCommand.saveLocally:
          await _saveLocally(bridgeParams);
          break;
        case BridgeCommand.getLocally:
          await _getLocally(bridgeParams);
          break;
        case BridgeCommand.deleteLocally:
          await _deleteLocally(bridgeParams);
          break;
        case BridgeCommand.clearAll:
          await _clearAll();
          break;
        case BridgeCommand.unknown:
        default:
          debugPrint("Unknown bridge command: $bridgeName");
      }
    } catch (e) {
      debugPrint("Error processing message: $e");
    }
  }

  // Function to send data back to the web

  void _sendToWeb(Map<String, dynamic> data) {
    _controller?.runJavaScript(
        'window.postMessage(JSON.stringify(${jsonEncode(data)}))');
  }

  // Navigation and UI helper methods
  void _pop(BuildContext context) => Navigator.pop(context);

  void _popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _push(BuildContext context, Map<String, dynamic> params) {
    final String url = params["url"] ?? '';
    final String pageTitle = params["pageTitle"] ?? '';
    final bool fullscreenDialog = params["fullscreenDialog"] ?? false;
    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: fullscreenDialog,
        builder: (BuildContext context) => WebScreen(
          url: url,
          pageTitle: pageTitle,
          buttons: buttons,
        ),
      ),
    );
  }

  void _popAndPush(BuildContext context, Map<String, dynamic> params) {
    Navigator.pop(context);
    _push(context, params);
  }

  void _popRootAndPush(BuildContext context, Map<String, dynamic> params) {
    _popToRoot(context);
    _push(context, params);
  }

  void _handleAlert(BuildContext context, Map<String, dynamic> bridgeParams) {
    var title = bridgeParams['title'] ?? 'تحذير';
    var message = bridgeParams['message'] ?? 'Alert';
    var doneButton = bridgeParams['done'] ?? 'حسنا';
    _showAlert(context, title, message, doneButton);
  }

  Future<void> _getToken() async {
    final String? token =
        await AppPreferences.getValue(PreferenceKey.token.keyString);
    if (token != null) {
      _sendToWeb({'token': token});
    }
  }

  Future<void> _setToken(Map<String, dynamic> bridgeParams) async {
    var token = bridgeParams['token'] ?? 'تحذير';
    await AppPreferences.saveValue(PreferenceKey.token.keyString, token);
  }

  Future<void> _deleteToken() async {
    await AppPreferences.removeValue(PreferenceKey.token.keyString);
  }

  void _handleRefresh(Map<String, dynamic> bridgeParams) {
    final String eventName = bridgeParams["eventName"] ?? "";
    Future.delayed(const Duration(seconds: 1), () {
      if (eventName.isNotEmpty) {
        NotificationService().post(eventName);
      } else {
        NotificationService().postGlobalRefresh();
      }
    });
  }

  Future<void> _saveLocally(Map<String, dynamic> bridgeParams) async {
    String value = bridgeParams['value'] ?? '';
    String preferenceKey = bridgeParams['key'] ?? 'تحذير';
    await AppPreferences.saveValue(preferenceKey, value);
  }

  Future<void> _getLocally(Map<String, dynamic> bridgeParams) async {
    var preferenceKey = bridgeParams['key'] ?? 'تحذير';
    String? value = await AppPreferences.getValue(preferenceKey);
    if (value == null) return;
    _sendToWeb({preferenceKey: value});
  }

  Future<void> _deleteLocally(Map<String, dynamic> bridgeParams) async {
    var preferenceKey = bridgeParams['key'] ?? 'تحذير';
    await AppPreferences.removeValue(preferenceKey);
  }

  Future<void> _clearAll() async {
    await AppPreferences.clearAll();
  }

  void _showAlert(
      BuildContext context, String title, String message, String doneButton) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(doneButton),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

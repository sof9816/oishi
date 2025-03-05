import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final Map<String, StreamController<dynamic>> _eventListeners = {};

  // Listen to a specific event
  Stream<dynamic> forEvent(String eventName) {
    if (!_eventListeners.containsKey(eventName)) {
      _eventListeners[eventName] = StreamController.broadcast();
    }
    return _eventListeners[eventName]!.stream;
  }

  // Post (broadcast) an event by name, supporting exact matches
  void post(String eventName, [dynamic data]) {
    if (_eventListeners.containsKey(eventName)) {
      _eventListeners[eventName]!.add(data);
    }
  }

  // Post a global refresh, triggering all events with 'refresh' in their name
  void postGlobalRefresh([dynamic data]) {
    _eventListeners["refresh_all"]!.add(data);
  }

  // Dispose the event listeners
  void dispose(String eventName) {
    _eventListeners[eventName]?.close();
    _eventListeners.remove(eventName);
  }
}

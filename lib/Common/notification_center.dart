// Copyright (c) 2024 Aikyuichi <aikyu.sama@gmail.com>
// All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

/// A simple notification center.
/// A notification dispatch mechanism that enables the broadcast of information to registered observers.
library notification_center;

import 'dart:async';
import '../Data/Functions.dart';

import 'notification_subscriber.dart';

export 'notification_subscriber.dart' show NotificationSubscription;

/// A singleton. It takes care of subscribe observers, and post notifications.
class NotificationCenter {
  final _notifications = <String, List<NotificationSubscriber>>{};

  static final NotificationCenter _instance = NotificationCenter.internal();

  factory NotificationCenter() => _instance;

  NotificationCenter.internal();

  /// Adds to the center a subscriber for [notificationId].
  ///
  /// The returned [NotificationSubscription] can be used to pause/resume or cancel the subscription.
  NotificationSubscription subscribe<T>(
      String notificationId, void Function(T) callback) {
    if (notificationId.contains("Unknown")) {
      printDebug(notificationId);
    }
    _notifications[notificationId] = [];
    final subscriber = NotificationSubscriber<T>(callback);
    subscriber.onCancel = () {
      _notifications[notificationId]?.remove(subscriber);
    };
    _notifications[notificationId]?.add(subscriber);
    // for(String notiID in _notifications.keys.toList()) {
    //   printDebug("Sub notify: $notiID");
    // }
    return subscriber;
  }

  /// Remove from the center the subscribers of [notificationId].
  Future<void> unsubscribe(String notificationId) async {
    if (_notifications.containsKey(notificationId)) {
      final subscribers = _notifications[notificationId]!;
      printDebug("UnNotify $notificationId");
      for (var subscriber in subscribers) {
        subscriber.onCancel = null;
        await subscriber.cancel();
      }
      _notifications.remove(notificationId);
    } else if (notificationId.isNotEmpty && _notifications.isNotEmpty) {
      for(String notiID in _notifications.keys.toList()) {
        if (notiID.endsWith(notificationId)) {
          final subscribers = _notifications[notiID]!;
          printDebug("UnNotify sub $notiID");
          for (var subscriber in subscribers) {
            subscriber.onCancel = null;
            await subscriber.cancel();
          }
        }
      }
    }
  }

  Future<void> unsubscribePrefix(String notificationId) async {
    if (notificationId.isNotEmpty && _notifications.isNotEmpty) {
      for(String notiId in _notifications.keys.toList()) {
        if (notiId.startsWith(notificationId)) {
          final subscribers = _notifications[notiId]!;
          printDebug("UnNotify sub $notiId");
          for (var subscriber in subscribers) {
            subscriber.onCancel = null;
            await subscriber.cancel();
          }
        }
      }
    }
  }

  /// Pause all the subscribers of [notificationId]
  void pause(String notificationId) {
    if (_notifications.containsKey(notificationId)) {
      final subscribers = _notifications[notificationId]!;
      for (var subscriber in subscribers) {
        subscriber.pause();
      }
    }
  }

  /// Resumes all the subscribers of [notificationId] after a pause.
  void resume(String notificationId) {
    if (_notifications.containsKey(notificationId)) {
      final subscribers = _notifications[notificationId]!;
      for (var subscriber in subscribers) {
        subscriber.resume();
      }
    }
  }

  /// Whether all the subscribers of [notificationId] are currently paused.
  bool isPaused(String notificationId) {
    if (_notifications.containsKey(notificationId)) {
      final subscribers = _notifications[notificationId]!;
      return subscribers
          .map((e) => e.isPaused)
          .reduce((value, element) => value && element);
    }
    return false;
  }

  /// Posts a given notification.
  void notify<T>(String notificationId, {T? data}) {
    if (notificationId.isNotEmpty && _notifications.isNotEmpty) {
      for(String notiID in _notifications.keys.toList()) {
        if (notiID.endsWith(notificationId)) {
          final subscribers = _notifications[notiID]!;
          printDebug("Notify sub $notiID");
          for (var subscriber in subscribers) {
            subscriber.add(data);
          }
        }
      }
    }
  }
}

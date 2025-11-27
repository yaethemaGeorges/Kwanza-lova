// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';

class FirestoreListenerManagerGlobal {
  static final FirestoreListenerManagerGlobal _instance =
      FirestoreListenerManagerGlobal._internal();

  factory FirestoreListenerManagerGlobal() => _instance;

  FirestoreListenerManagerGlobal._internal();

  final Map<String, StreamSubscription> _activeListeners = {};
  final Map<String, DateTime> _listenerCreationTimes = {};

  static const int MAX_LISTENERS = 45000;
  static const Duration LISTENER_TIMEOUT = Duration(hours: 2);

  int get activeCount => _activeListeners.length;

  void addListener(String key, StreamSubscription subscription) {
    if (_activeListeners.length >= MAX_LISTENERS) {
      print('🚨 ALERTE CRITIQUE: Limite de listeners atteinte!');
      _cleanupOldListeners();
    }

    removeListener(key);

    _activeListeners[key] = subscription;
    _listenerCreationTimes[key] = DateTime.now();

    if (kDebugMode) {
      print('📊 Listener ajouté: $key | Total: ${_activeListeners.length}');
    }

    if (_activeListeners.length > MAX_LISTENERS * 0.9) {
      print('⚠️ ALERTE: ${_activeListeners.length} listeners actifs!');
    }
  }

  void removeListener(String key) {
    final sub = _activeListeners.remove(key);
    _listenerCreationTimes.remove(key);

    sub?.cancel();

    if (kDebugMode) {
      print('🗑️ Listener supprimé: $key | Total: ${_activeListeners.length}');
    }
  }

  void removeListenersByPattern(String pattern) {
    final keysToRemove =
        _activeListeners.keys.where((key) => key.contains(pattern)).toList();

    for (final key in keysToRemove) {
      removeListener(key);
    }

    if (kDebugMode) {
      print(
          '🧹 ${keysToRemove.length} listeners supprimés (pattern: $pattern)');
    }
  }

  void _cleanupOldListeners() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _listenerCreationTimes.forEach((key, creationTime) {
      if (now.difference(creationTime) > LISTENER_TIMEOUT) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      removeListener(key);
    }

    if (kDebugMode) {
      print('🧹 ${keysToRemove.length} listeners expirés nettoyés');
    }
  }

  void clearAll() {
    for (var sub in _activeListeners.values) {
      sub.cancel();
    }
    _activeListeners.clear();
    _listenerCreationTimes.clear();

    if (kDebugMode) {
      print('🧹 Tous les listeners nettoyés');
    }
  }

  void printStats() {
    print('''
╔════════════════════════════════════════╗
║   FIRESTORE LISTENER MANAGER STATS     ║
╠════════════════════════════════════════╣
║ Total actifs: ${_activeListeners.length.toString().padLeft(28)}║
║ Limite max: ${MAX_LISTENERS.toString().padLeft(30)}║
║ Utilisation: ${((_activeListeners.length / MAX_LISTENERS) * 100).toStringAsFixed(1).padLeft(27)}%║
╚════════════════════════════════════════╝
    ''');
  }
}

// Cette fonction est requise mais vide car on utilise seulement la classe
Future<void> firestoreListenerManagerGlobal() async {
  // Fonction vide requise par FlutterFlow
}

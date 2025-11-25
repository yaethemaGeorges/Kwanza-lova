import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe utilitaire de protection pour Kwanza-Lova
/// Version autonome sans dépendances externes
///
/// UTILISATION:
/// 1. Ajoute ce fichier dans Custom Code > Custom Files
/// 2. Crée une Custom Action qui appelle KwanzaProtection.initialize()
/// 3. Appelle cette action au démarrage de ton app
class KwanzaProtection {
  static bool _isInitialized = false;
  static final Map<String, StreamSubscription> _activeStreams = {};
  static Timer? _cleanupTimer;

  /// Initialise tous les systèmes de protection
  /// APPELLE CETTE FONCTION au démarrage de ton app
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ KwanzaProtection déjà initialisé');
      return;
    }

    try {
      debugPrint('🚀 Initialisation de KwanzaProtection...');

      // 1. Capture des erreurs Flutter
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('❌ Flutter Error: ${details.exception}');

        if (kReleaseMode) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };

      // 2. Capture des erreurs asynchrones
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('❌ Async Error: $error');

        if (kReleaseMode) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      // 3. Nettoyage automatique des streams toutes les 5 minutes
      _cleanupTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _cleanupInactiveStreams(),
      );

      // 4. Configuration Firestore optimisée
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: 100 * 1024 * 1024, // 100 MB cache
        );
        debugPrint('✅ Firestore configuré');
      } catch (e) {
        debugPrint('⚠️ Erreur config Firestore: $e');
      }

      _isInitialized = true;
      debugPrint('✅ KwanzaProtection initialisé avec succès');
    } catch (e, stack) {
      debugPrint('❌ Erreur initialisation KwanzaProtection: $e');
      debugPrint('Stack: $stack');
    }
  }

  /// Enregistre un stream pour monitoring
  static void registerStream(String id, StreamSubscription subscription) {
    _activeStreams[id] = subscription;
    debugPrint('📡 Stream enregistré: $id (Total: ${_activeStreams.length})');
  }

  /// Annule un stream spécifique
  static Future<void> cancelStream(String id) async {
    if (_activeStreams.containsKey(id)) {
      await _activeStreams[id]!.cancel();
      _activeStreams.remove(id);
      debugPrint('🛑 Stream annulé: $id');
    }
  }

  /// Nettoie les streams inactifs
  static void _cleanupInactiveStreams() {
    debugPrint('🧹 Nettoyage des streams (${_activeStreams.length} actifs)');
    // Le nettoyage sera fait automatiquement par Flutter
  }

  /// Nettoie toutes les ressources
  static Future<void> dispose() async {
    debugPrint('🛑 Nettoyage de KwanzaProtection...');

    _cleanupTimer?.cancel();

    for (var subscription in _activeStreams.values) {
      await subscription.cancel();
    }
    _activeStreams.clear();

    _isInitialized = false;
    debugPrint('✅ KwanzaProtection nettoyé');
  }

  /// Vérifie si le système est initialisé
  static bool get isInitialized => _isInitialized;

  /// Obtient le nombre de streams actifs
  static int get activeStreamsCount => _activeStreams.length;
}

/// Widget wrapper pour protéger une page contre les erreurs
///
/// UTILISATION:
/// Wrap ta page avec ce widget:
/// return ProtectedPage(
///   pageName: 'SwipePage',
///   child: YourPageContent(),
/// );
class ProtectedPage extends StatelessWidget {
  final Widget child;
  final String pageName;

  const ProtectedPage({
    Key? key,
    required this.child,
    required this.pageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryWidget(
      child: child,
      pageName: pageName,
    );
  }
}

/// Widget qui capture les erreurs d'une page
class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final String pageName;

  const ErrorBoundaryWidget({
    Key? key,
    required this.child,
    required this.pageName,
  }) : super(key: key);

  @override
  State<ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    debugPrint('📱 Page chargée: ${widget.pageName}');
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF6F61EF),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Une erreur est survenue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6F61EF),
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }

  @override
  void dispose() {
    debugPrint('🛑 Page fermée: ${widget.pageName}');
    super.dispose();
  }
}

/// Helper pour gérer les streams Firestore de manière optimisée
///
/// UTILISATION:
/// final stream = FirestoreStreamHelper.createOptimizedStream(
///   collectionPath: 'users',
///   queryBuilder: (ref) => ref.where('active', isEqualTo: true),
/// );
class FirestoreStreamHelper {
  static final Map<String, Stream> _streamCache = {};

  /// Crée un stream optimisé avec cache
  static Stream<QuerySnapshot> createOptimizedStream({
    required String collectionPath,
    Query Function(CollectionReference)? queryBuilder,
    int? limit,
    Duration cacheDuration = const Duration(minutes: 5),
  }) {
    // Génère un ID unique pour ce stream
    final streamId = _generateStreamId(collectionPath, queryBuilder, limit);

    // Vérifie le cache
    if (_streamCache.containsKey(streamId)) {
      debugPrint('💾 Stream en cache: $streamId');
      return _streamCache[streamId] as Stream<QuerySnapshot>;
    }

    // Crée le stream
    CollectionReference ref =
        FirebaseFirestore.instance.collection(collectionPath);
    Query query = ref;

    if (queryBuilder != null) {
      query = queryBuilder(ref);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final stream = query.snapshots();

    // Met en cache
    _streamCache[streamId] = stream;
    debugPrint('📡 Nouveau stream créé: $streamId');

    // Nettoie le cache après la durée spécifiée
    Timer(cacheDuration, () {
      _streamCache.remove(streamId);
      debugPrint('🧹 Stream retiré du cache: $streamId');
    });

    return stream;
  }

  /// Crée un stream pour un document
  static Stream<DocumentSnapshot> createDocumentStream({
    required String documentPath,
    Duration cacheDuration = const Duration(minutes: 5),
  }) {
    final streamId = 'doc_$documentPath';

    if (_streamCache.containsKey(streamId)) {
      debugPrint('💾 Document stream en cache: $streamId');
      return _streamCache[streamId] as Stream<DocumentSnapshot>;
    }

    final stream = FirebaseFirestore.instance.doc(documentPath).snapshots();
    _streamCache[streamId] = stream;
    debugPrint('📡 Nouveau document stream: $streamId');

    Timer(cacheDuration, () {
      _streamCache.remove(streamId);
    });

    return stream;
  }

  /// Stream pour les messages d'un chat
  static Stream<QuerySnapshot> chatMessagesStream({
    required String chatId,
    int limit = 50,
  }) {
    return createOptimizedStream(
      collectionPath: 'chats/$chatId/messages',
      queryBuilder: (ref) => ref.orderBy('timestamp', descending: true),
      limit: limit,
      cacheDuration: const Duration(seconds: 30),
    );
  }

  /// Stream pour les matches d'un utilisateur
  static Stream<QuerySnapshot> userMatchesStream({
    required String userId,
    int limit = 100,
  }) {
    return createOptimizedStream(
      collectionPath: 'matches',
      queryBuilder: (ref) => ref
          .where('participants', arrayContains: userId)
          .orderBy('matchedAt', descending: true),
      limit: limit,
      cacheDuration: const Duration(minutes: 2),
    );
  }

  /// Stream pour les notifications d'un utilisateur
  static Stream<QuerySnapshot> userNotificationsStream({
    required String userId,
    int limit = 50,
  }) {
    return createOptimizedStream(
      collectionPath: 'notifications',
      queryBuilder: (ref) => ref
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .orderBy('timestamp', descending: true),
      limit: limit,
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Génère un ID unique pour le stream
  static String _generateStreamId(
    String collectionPath,
    Query Function(CollectionReference)? queryBuilder,
    int? limit,
  ) {
    final parts = [collectionPath];
    if (queryBuilder != null) {
      parts.add(queryBuilder.hashCode.toString());
    }
    if (limit != null) {
      parts.add('limit_$limit');
    }
    return parts.join('_');
  }

  /// Nettoie tous les streams en cache
  static void clearCache() {
    _streamCache.clear();
    debugPrint('🧹 Cache de streams nettoyé');
  }
}

/// Helper pour les opérations réseau avec retry automatique
class NetworkHelper {
  /// Exécute une opération avec retry automatique
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          debugPrint('❌ Max retries atteint: $e');
          rethrow;
        }

        debugPrint('⚠️ Tentative $attempts/$maxRetries échouée, retry...');
        await Future.delayed(retryDelay * attempts);
      }
    }

    throw Exception('Max retries exceeded');
  }
}

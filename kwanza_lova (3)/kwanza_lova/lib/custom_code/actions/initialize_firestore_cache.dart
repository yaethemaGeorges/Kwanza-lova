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

import '/custom_code/actions/index.dart'; // Imports custom actions

import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 CUSTOM ACTION : GESTION INTELLIGENTE DU CACHE FIRESTORE

/// Configure les paramètres de cache Firestore pour optimiser les performances
Future<void> initializeFirestoreCache() async {
  try {
    // Active le cache persistant avec taille illimitée
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    print('✅ Cache Firestore initialisé avec succès');
  } catch (e) {
    print('⚠️ Erreur initialisation cache: $e');
  }
}

/// Récupère des documents depuis le cache en priorité, puis depuis le serveur
///
/// [collectionPath] : Chemin de la collection Firestore
/// [whereField] : Champ pour le filtre where (optionnel)
/// [whereValue] : Valeur pour le filtre where (optionnel)
/// [orderByField] : Champ pour le tri (optionnel)
/// [descending] : Tri décroissant (défaut: true)
/// [limitCount] : Nombre maximum de documents (défaut: 20)
Future<List<DocumentSnapshot>> getCachedDocuments({
  required String collectionPath,
  String? whereField,
  dynamic whereValue,
  String? orderByField,
  bool descending = true,
  int limitCount = 20,
}) async {
  try {
    print('📥 Tentative chargement depuis cache: $collectionPath');

    // Construit la requête
    Query query = FirebaseFirestore.instance.collection(collectionPath);

    // Ajoute le filtre where si fourni
    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }

    // Ajoute le tri si fourni
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    // Limite le nombre de résultats
    query = query.limit(limitCount);

    // Essaie de charger depuis le cache d'abord
    try {
      final cachedSnapshot = await query.get(
        const GetOptions(source: Source.cache),
      );

      if (cachedSnapshot.docs.isNotEmpty) {
        print(
            '✅ ${cachedSnapshot.docs.length} documents chargés depuis le cache');
        return cachedSnapshot.docs;
      }
    } catch (cacheError) {
      print('⚠️ Cache vide ou expiré pour $collectionPath');
    }

    // Si pas de cache, charge depuis le serveur
    print('🌐 Chargement depuis le serveur: $collectionPath');
    final serverSnapshot = await query.get(
      const GetOptions(source: Source.server),
    );

    print(
        '✅ ${serverSnapshot.docs.length} documents chargés depuis le serveur');
    return serverSnapshot.docs;
  } catch (e) {
    print('❌ Erreur getCachedDocuments: $e');
    return [];
  }
}

/// Récupère des utilisateurs avec cache intelligent
/// Spécifique pour la collection 'users'
Future<List<DocumentSnapshot>> getCachedUsers({
  String? currentUserId,
  bool showInSwipeOnly = true,
  int limitCount = 20,
}) async {
  try {
    Query query = FirebaseFirestore.instance.collection('users');

    // Filtre pour le swipe
    if (showInSwipeOnly) {
      query = query.where('show_in_swipe', isEqualTo: true);
    }

    // Exclut l'utilisateur actuel
    if (currentUserId != null && currentUserId.isNotEmpty) {
      query = query.where(FieldPath.documentId, isNotEqualTo: currentUserId);
    }

    // Limite
    query = query.limit(limitCount);

    // Essaie le cache
    try {
      final cachedSnapshot = await query.get(
        const GetOptions(source: Source.cache),
      );

      if (cachedSnapshot.docs.isNotEmpty) {
        print('✅ ${cachedSnapshot.docs.length} utilisateurs depuis le cache');
        return cachedSnapshot.docs;
      }
    } catch (_) {
      print('⚠️ Cache utilisateurs vide');
    }

    // Fallback serveur
    final serverSnapshot = await query.get();
    print('✅ ${serverSnapshot.docs.length} utilisateurs depuis le serveur');
    return serverSnapshot.docs;
  } catch (e) {
    print('❌ Erreur getCachedUsers: $e');
    return [];
  }
}

/// Récupère des matches avec cache intelligent
Future<List<DocumentSnapshot>> getCachedMatches({
  required String currentUserId,
  bool activeOnly = true,
  int limitCount = 50,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('user_matches')
        .doc(currentUserId)
        .collection('matches');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    query = query.orderBy('matchedAt', descending: true).limit(limitCount);

    // Essaie le cache
    try {
      final cachedSnapshot = await query.get(
        const GetOptions(source: Source.cache),
      );

      if (cachedSnapshot.docs.isNotEmpty) {
        print('✅ ${cachedSnapshot.docs.length} matches depuis le cache');
        return cachedSnapshot.docs;
      }
    } catch (_) {
      print('⚠️ Cache matches vide');
    }

    // Fallback serveur
    final serverSnapshot = await query.get();
    print('✅ ${serverSnapshot.docs.length} matches depuis le serveur');
    return serverSnapshot.docs;
  } catch (e) {
    print('❌ Erreur getCachedMatches: $e');
    return [];
  }
}

/// Récupère des notifications avec cache intelligent
Future<List<DocumentSnapshot>> getCachedNotifications({
  required String currentUserId,
  bool unreadOnly = false,
  int limitCount = 30,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: currentUserId);

    if (unreadOnly) {
      query = query.where('is_read', isEqualTo: false);
    }

    query = query.orderBy('created_at', descending: true).limit(limitCount);

    // Essaie le cache
    try {
      final cachedSnapshot = await query.get(
        const GetOptions(source: Source.cache),
      );

      if (cachedSnapshot.docs.isNotEmpty) {
        print('✅ ${cachedSnapshot.docs.length} notifications depuis le cache');
        return cachedSnapshot.docs;
      }
    } catch (_) {
      print('⚠️ Cache notifications vide');
    }

    // Fallback serveur
    final serverSnapshot = await query.get();
    print('✅ ${serverSnapshot.docs.length} notifications depuis le serveur');
    return serverSnapshot.docs;
  } catch (e) {
    print('❌ Erreur getCachedNotifications: $e');
    return [];
  }
}

/// Récupère des conversations avec cache intelligent
Future<List<DocumentSnapshot>> getCachedConversations({
  required String currentUserId,
  int limitCount = 30,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('conversations')
        .where('participant_ids', arrayContains: currentUserId)
        .where('isActive', isEqualTo: true)
        .orderBy('last_message_time', descending: true)
        .limit(limitCount);

    // Essaie le cache
    try {
      final cachedSnapshot = await query.get(
        const GetOptions(source: Source.cache),
      );

      if (cachedSnapshot.docs.isNotEmpty) {
        print('✅ ${cachedSnapshot.docs.length} conversations depuis le cache');
        return cachedSnapshot.docs;
      }
    } catch (_) {
      print('⚠️ Cache conversations vide');
    }

    // Fallback serveur
    final serverSnapshot = await query.get();
    print('✅ ${serverSnapshot.docs.length} conversations depuis le serveur');
    return serverSnapshot.docs;
  } catch (e) {
    print('❌ Erreur getCachedConversations: $e');
    return [];
  }
}

/// Vide le cache Firestore (à utiliser en cas de problème)
Future<void> clearFirestoreCache() async {
  try {
    await FirebaseFirestore.instance.clearPersistence();
    print('✅ Cache Firestore vidé avec succès');

    // Réinitialise le cache
    await initializeFirestoreCache();
  } catch (e) {
    print('❌ Erreur clearFirestoreCache: $e');
  }
}

/// Force le rechargement d'une collection depuis le serveur
Future<List<DocumentSnapshot>> forceReloadFromServer({
  required String collectionPath,
  String? whereField,
  dynamic whereValue,
  String? orderByField,
  bool descending = true,
  int limitCount = 20,
}) async {
  try {
    print('🔄 Force rechargement depuis serveur: $collectionPath');

    Query query = FirebaseFirestore.instance.collection(collectionPath);

    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    query = query.limit(limitCount);

    final snapshot = await query.get(
      const GetOptions(source: Source.server),
    );

    print('✅ ${snapshot.docs.length} documents rechargés depuis le serveur');
    return snapshot.docs;
  } catch (e) {
    print('❌ Erreur forceReloadFromServer: $e');
    return [];
  }
}

/// Vérifie la taille du cache actuel (en MB)
/// Vérifie la taille du cache actuel (en MB)
Future<String> getCacheSize() async {
  try {
    // Note: Cette fonction est approximative car Firestore ne fournit pas
    // directement la taille du cache
    final settings = FirebaseFirestore.instance.settings;

    if (settings.cacheSizeBytes == Settings.CACHE_SIZE_UNLIMITED) {
      return 'Cache: Illimité';
    } else {
      final cacheBytes = settings.cacheSizeBytes;
      if (cacheBytes != null) {
        final sizeMB = (cacheBytes / (1024 * 1024)).toStringAsFixed(2);
        return 'Cache: $sizeMB MB';
      } else {
        return 'Cache: Non configuré';
      }
    }
  } catch (e) {
    print('❌ Erreur getCacheSize: $e');
    return 'Cache: Inconnu';
  }
}

/// Précharge les données essentielles dans le cache au démarrage
Future<void> preloadEssentialData(String currentUserId) async {
  try {
    print('🚀 Préchargement des données essentielles...');

    // Initialise le cache
    await initializeFirestoreCache();

    // Précharge en parallèle
    await Future.wait([
      getCachedUsers(currentUserId: currentUserId, limitCount: 30),
      getCachedMatches(currentUserId: currentUserId, limitCount: 50),
      getCachedNotifications(currentUserId: currentUserId, limitCount: 20),
      getCachedConversations(currentUserId: currentUserId, limitCount: 20),
    ]);

    print('✅ Préchargement terminé avec succès');
  } catch (e) {
    print('❌ Erreur préchargement: $e');
  }
}

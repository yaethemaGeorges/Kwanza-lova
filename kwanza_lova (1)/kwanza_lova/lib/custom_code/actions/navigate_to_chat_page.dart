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

import '/custom_code/actions/index.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔥 CUSTOM ACTION - Navigation vers ChatPage
/// Cette action gère toute la navigation vers le chat avec récupération du display_name
///
/// Paramètres:
/// - chatId: L'ID du chat/match
/// - otherUserId: L'ID de l'autre utilisateur
/// - otherUserName: Le nom de l'autre utilisateur (fallback)
/// - currentUserId: L'ID de l'utilisateur actuel
Future navigateToChatPage(
  BuildContext context,
  String chatId,
  String otherUserId,
  String otherUserName,
  String currentUserId,
) async {
  print('🔥 Custom Action: navigateToChatPage');
  print('   chatId: $chatId');
  print('   otherUserId: $otherUserId');
  print('   otherUserName: $otherUserName');
  print('   currentUserId: $currentUserId');

  // Vérifications de sécurité
  if (chatId.isEmpty || otherUserId.isEmpty || currentUserId.isEmpty) {
    print('❌ Paramètres invalides');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erreur: Paramètres manquants'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (otherUserId == currentUserId) {
    print('❌ Tentative d\'ouvrir un chat avec soi-même');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erreur: Impossible d\'ouvrir un chat avec vous-même'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // 🔥 Récupérer le display_name depuis Firestore
  String finalUserName = otherUserName;
  try {
    print('🔍 Récupération du display_name depuis Firestore...');
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data()!;
      finalUserName = userData['display_name'] ??
          userData['displayName'] ??
          userData['name'] ??
          userData['username'] ??
          otherUserName;
      print('✅ Display name récupéré: $finalUserName');
    } else {
      print('⚠️ Document utilisateur non trouvé, utilisation du fallback');
    }
  } catch (e) {
    print('❌ Erreur récupération display_name: $e');
    // On continue avec otherUserName en fallback
  }

  // 🔥 Navigation vers ChatPage
  try {
    print('🚀 Navigation vers ChatPage...');
    print('   Paramètres finaux:');
    print('   - chatId: $chatId');
    print('   - otherUserId: $otherUserId');
    print('   - otherUserName: $finalUserName');
    print('   - currentUserId: $currentUserId');

    context.pushNamed(
      'Chatpage', // ← CORRECT, tout en minuscule
      queryParameters: {
        'chatId': chatId,
        'otherUserId': otherUserId,
        'otherUserName': finalUserName,
        'currentUserId': currentUserId,
      },
    );

    print('✅ Navigation réussie');
  } catch (e) {
    print('❌ Erreur navigation: $e');

    // Afficher un message d'erreur détaillé
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: Impossible d\'ouvrir le chat\n${e.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );

    // Suggestions de débogage
    print('');
    print('🔍 DÉBOGAGE - Vérifiez que:');
    print(
        '   1. La page s\'appelle exactement "ChatPage" (sensible à la casse)');
    print(
        '   2. ChatPage accepte les paramètres: chatId, otherUserId, otherUserName, currentUserId');
    print('   3. Tous les paramètres sont de type String');
    print('   4. ChatPage est bien dans votre projet FlutterFlow');
  }
}

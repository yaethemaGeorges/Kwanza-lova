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

/// 🔥 CUSTOM ACTION POUR LA NAVIGATION
///
/// Cette action évite l'erreur CSP en utilisant Navigator standard
/// au lieu de context.pushNamed()
///
/// UTILISATION DANS FLUTTERFLOW :
/// 1. Créez cette action dans Custom Code > Actions
/// 2. Dans MatchesWidget, ajoutez le callback onChatTap
/// 3. Configurez onChatTap pour appeler cette action
/// 4. Mappez les paramètres correctement

Future navigateToChatPageSafe(
  BuildContext context,
  String chatId,
  String otherUserId,
  String otherUserName,
  String currentUserId,
) async {
  print('═══════════════════════════════════════════════════════════');
  print('🚀 navigateToChatPageSafe - Navigation sécurisée');
  print('═══════════════════════════════════════════════════════════');
  print('📥 Paramètres :');
  print('  ├─ chatId: "$chatId"');
  print('  ├─ otherUserId: "$otherUserId"');
  print('  ├─ otherUserName: "$otherUserName"');
  print('  └─ currentUserId: "$currentUserId"');
  print('───────────────────────────────────────────────────────────');

  // Validation
  if (chatId.isEmpty || otherUserId.isEmpty || currentUserId.isEmpty) {
    print('❌ Paramètres invalides');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erreur : paramètres manquants'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    print('📱 Méthode 1 : context.pushNamed avec queryParameters');

    // Essayer d'abord la méthode FlutterFlow standard
    context.pushNamed(
      'chatpage',
      queryParameters: {
        'chatId': chatId,
        'otherUserId': otherUserId,
        'otherUserName': otherUserName,
        'currentUserId': currentUserId,
      },
    );

    print('✅ Navigation réussie avec context.pushNamed');
    print('═══════════════════════════════════════════════════════════');
  } catch (e) {
    print('❌ Échec méthode 1: $e');
    print('📱 Méthode 2 : Navigator.of(context).pushNamed avec arguments');

    try {
      // Fallback: utiliser Navigator standard
      Navigator.of(context).pushNamed(
        '/chatpage',
        arguments: {
          'chatId': chatId,
          'otherUserId': otherUserId,
          'otherUserName': otherUserName,
          'currentUserId': currentUserId,
        },
      );

      print('✅ Navigation réussie avec Navigator');
      print('═══════════════════════════════════════════════════════════');
    } catch (e2) {
      print('❌ Échec méthode 2: $e2');
      print('📱 Méthode 3 : Navigator sans slash');

      try {
        Navigator.of(context).pushNamed(
          'chatpage',
          arguments: {
            'chatId': chatId,
            'otherUserId': otherUserId,
            'otherUserName': otherUserName,
            'currentUserId': currentUserId,
          },
        );

        print('✅ Navigation réussie');
        print('═══════════════════════════════════════════════════════════');
      } catch (e3) {
        print('❌ Toutes les méthodes ont échoué');
        print('   Erreur 1: $e');
        print('   Erreur 2: $e2');
        print('   Erreur 3: $e3');
        print('═══════════════════════════════════════════════════════════');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

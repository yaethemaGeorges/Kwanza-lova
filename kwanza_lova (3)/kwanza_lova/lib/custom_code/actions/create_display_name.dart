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

import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

Future<void> createDisplayName(
  String firstName,
  String lastName,
) async {
  try {
    print('🔄 Création du display_name...');

    final userId = currentUserUid;

    if (userId == null || userId.isEmpty) {
      print('❌ Erreur: Utilisateur non connecté');
      return;
    }

    print('   User ID: $userId');
    print('   FirstName: "$firstName"');
    print('   LastName: "$lastName"');

    final cleanFirstName = firstName.trim();
    final cleanLastName = lastName.trim();

    String displayName = '';

    if (cleanFirstName.isNotEmpty && cleanLastName.isNotEmpty) {
      displayName = '$cleanFirstName $cleanLastName';
      print('   ✅ display_name créé: "$displayName"');
    } else if (cleanFirstName.isNotEmpty) {
      displayName = cleanFirstName;
      print('   ⚠️ Seulement firstName: "$displayName"');
    } else if (cleanLastName.isNotEmpty) {
      displayName = cleanLastName;
      print('   ⚠️ Seulement lastName: "$displayName"');
    } else {
      print('   ❌ Aucun nom fourni');
      return;
    }

    // 🔥 CRÉE display_name (avec underscore)
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'display_name': displayName, // ← AVEC underscore
    });

    print('   ✅ display_name enregistré dans Firestore');
  } catch (e) {
    print('❌ Erreur createDisplayName: $e');
  }
}

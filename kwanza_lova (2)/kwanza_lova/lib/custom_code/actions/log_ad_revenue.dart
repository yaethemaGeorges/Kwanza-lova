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

// Custom Action: logAdRevenue
// Path: /lib/custom_code/actions/log_ad_revenue.dart

import '/custom_code/actions/index.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> logAdRevenue(
  String adType,
  double revenue,
  String platform,
) async {
  try {
    print('╔═══════════════════════════════════════════════════╗');
    print('║         ENREGISTREMENT REVENU PUB                 ║');
    print('╚═══════════════════════════════════════════════════╝');

    // Récupérer l'utilisateur actuel
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ Utilisateur non connecté');
      return false;
    }

    final userId = user.uid;
    print('👤 UserId: $userId');
    print('💰 Revenu: $revenue\$');
    print('📺 Type: $adType');
    print('📱 Platform: $platform');

    // Créer l'entrée de log
    await FirebaseFirestore.instance.collection('ad_revenue_logs').add({
      'userId': userId,
      'adType': adType, // 'interstitial' | 'rewarded' | 'banner'
      'revenue': revenue,
      'platform': platform, // 'android' | 'ios'
      'timestamp': FieldValue.serverTimestamp(),
      'processed': false,
    });

    print('✅ Revenu publicitaire enregistré');
    print('╚═══════════════════════════════════════════════════╝');

    return true;
  } catch (e, stackTrace) {
    print('❌ ERREUR logAdRevenue: $e');
    print('Stack: $stackTrace');
    return false;
  }
}

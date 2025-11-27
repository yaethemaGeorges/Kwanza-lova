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

Future checkSwipeActions(BuildContext context) async {
  final action = FFAppState().lastSwipeAction;
  final profileId = FFAppState().lastSwipeProfileId;

  print('Action détectée: $action pour profil: $profileId');

  // Gestion des actions
  if (action.startsWith('like_MATCH_')) {
    // C'est un match !
    // Naviguer vers la page de match ou afficher une notification
    context.pushNamed('MatchPage');
  } else if (action.startsWith('superlike_MATCH_')) {
    // Super Like match
    context.pushNamed('MatchPage');
  } else if (action.startsWith('open_chat_')) {
    // Ouvrir le chat
    final matchId = action.replaceAll('open_chat_', '');
    context.pushNamed('ChatPage', extra: {'matchId': matchId});
  } else if (action.startsWith('show_subscription_')) {
    // Afficher la page d'abonnement
    context.pushNamed('SubscriptionPage');
  } else if (action.startsWith('notification_match_')) {
    // Match depuis notification
    context.pushNamed('MatchPage');
  }

  // Réinitialiser
  FFAppState().update(() {
    FFAppState().lastSwipeAction = '';
    FFAppState().lastSwipeProfileId = '';
  });
}

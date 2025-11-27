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

Future<String> processPaymentSimple1(
  String paymentMethod,
  String paymentData,
  double amount,
  String transactionId,
) async {
  print('💳 Traitement du paiement:');
  print('   Méthode: $paymentMethod');
  print('   Données: $paymentData');
  print('   Montant: $amount');
  print('   Transaction ID: $transactionId');

  // Simule un délai de traitement
  await Future.delayed(Duration(seconds: 2));

  // Validation basique
  if (paymentData.isEmpty) {
    return 'ERROR|Données de paiement manquantes';
  }

  if (amount <= 0) {
    return 'ERROR|Montant invalide';
  }

  // Validation par méthode
  if (paymentMethod == 'mpesa' ||
      paymentMethod == 'orange_money' ||
      paymentMethod == 'airtel_money') {
    final phoneRegex = RegExp(r'^\+?\d{8,15}$');
    if (!phoneRegex.hasMatch(paymentData.replaceAll(' ', ''))) {
      return 'ERROR|Numéro de téléphone invalide';
    }
  } else if (paymentMethod == 'paypal') {
    if (!paymentData.contains('@') || !paymentData.contains('.')) {
      return 'ERROR|Email PayPal invalide';
    }
  }

  // Enregistre la transaction dans Firestore
  try {
    await FirebaseFirestore.instance.collection('transactions').add({
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'paymentData': paymentData.length > 4
          ? paymentData.substring(0, 4) + '****'
          : '****',
    });

    print('✅ Transaction enregistrée: $transactionId');
  } catch (e) {
    print('⚠️ Erreur enregistrement: $e');
  }

  // Simule un succès (à remplacer par vraie API en production)
  return 'SUCCESS|Paiement de \$$amount traité avec succès via $paymentMethod';
}

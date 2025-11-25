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

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> processPaymentSimple(
  String paymentMethod,
  String paymentData,
  double amount,
  String transactionId,
) async {
  // Add your function code here!

  print('💳 Traitement paiement réel via API');

  try {
    // 🔥 EXEMPLE FLUTTERWAVE (Mobile Money Afrique)
    if (paymentMethod == 'mpesa' ||
        paymentMethod == 'orange_money' ||
        paymentMethod == 'airtel_money') {
      final response = await http.post(
        Uri.parse(
            'https://api.flutterwave.com/v3/charges?type=mobile_money_uganda'),
        headers: {
          'Authorization': 'Bearer VOTRE_CLE_SECRETE_FLUTTERWAVE',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tx_ref': transactionId,
          'amount': amount.toString(),
          'currency': 'USD',
          'email': 'customer@example.com',
          'phone_number': paymentData,
          'network': _getNetworkCode(paymentMethod),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Enregistre dans Firestore
        await _saveTransaction(transactionId, paymentMethod, amount, 'success');
        return 'SUCCESS|${responseData['message']}';
      } else {
        await _saveTransaction(transactionId, paymentMethod, amount, 'failed');
        return 'ERROR|${responseData['message']}';
      }
    }

    // 🔥 EXEMPLE PAYPAL
    else if (paymentMethod == 'paypal') {
      // Intégrer PayPal SDK
      return 'ERROR|PayPal nécessite le SDK (voir documentation)';
    }

    // Méthode non supportée
    else {
      return 'ERROR|Méthode de paiement non supportée: $paymentMethod';
    }
  } catch (e) {
    print('❌ Erreur API: $e');
    await _saveTransaction(transactionId, paymentMethod, amount, 'error');
    return 'ERROR|Erreur de connexion à l\'API: $e';
  }
}

// Helper pour mapper les méthodes aux codes réseau
String _getNetworkCode(String paymentMethod) {
  switch (paymentMethod) {
    case 'mpesa':
      return 'VODAFONE';
    case 'orange_money':
      return 'ORANGE';
    case 'airtel_money':
      return 'AIRTEL';
    default:
      return 'VODAFONE';
  }
}

// Sauvegarde la transaction dans Firestore
Future<void> _saveTransaction(
  String transactionId,
  String paymentMethod,
  double amount,
  String status,
) async {
  try {
    await FirebaseFirestore.instance.collection('transactions').add({
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('⚠️ Erreur sauvegarde transaction: $e');
  }
}

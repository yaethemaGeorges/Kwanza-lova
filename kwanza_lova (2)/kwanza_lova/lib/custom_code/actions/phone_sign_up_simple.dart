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

// Custom Action: phoneSignUpSimple (VERSION CORRIGÉE)
// Path: /lib/custom_code/actions/phone_sign_up_simple.dart

import '/custom_code/actions/index.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> phoneSignUpSimple(
  String phoneNumber,
  String password,
  String confirmPassword,
) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    print('╔═══════════════════════════════════════════════════╗');
    print('║      INSCRIPTION SIMPLE PAR TÉLÉPHONE            ║');
    print('╚═══════════════════════════════════════════════════╝');
    print('📱 Téléphone: $phoneNumber');

    // Validation 1: Vérifier que les mots de passe correspondent
    if (password != confirmPassword) {
      print('❌ Mots de passe différents');
      return 'ERROR:Les mots de passe ne correspondent pas';
    }

    // Validation 2: Longueur du mot de passe
    if (password.length < 6) {
      print('❌ Mot de passe trop court');
      return 'ERROR:Le mot de passe doit contenir au moins 6 caractères';
    }

    // Validation 3: Format du numéro de téléphone
    if (!phoneNumber.startsWith('+')) {
      print('❌ Numéro de téléphone invalide');
      return 'ERROR:Le numéro doit commencer par +';
    }

    // Étape 1: Vérifier si le numéro existe déjà
    print('\n🔍 Vérification existence utilisateur...');

    final existingUser = await _firestore
        .collection('users')
        .where('phone_number', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (existingUser.docs.isNotEmpty) {
      print('⚠️ Numéro déjà utilisé');
      return 'ERROR:Ce numéro de téléphone est déjà utilisé';
    }

    print('✅ Numéro disponible');

    // Étape 2: Créer un email temporaire VALIDE
    // Format: +243900000001 → 243900000001@kwanza-lova.com
    // Enlever tous les caractères non numériques
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final tempEmail = '${cleanNumber}@kwanza-lova.com';

    print('\n📧 Email temporaire: $tempEmail');

    // Étape 3: Vérifier si cet email existe déjà dans Firebase Auth
    try {
      final signInMethods = await _auth.fetchSignInMethodsForEmail(tempEmail);
      if (signInMethods.isNotEmpty) {
        print('⚠️ Email temporaire déjà utilisé');
        return 'ERROR:Ce compte existe déjà. Veuillez vous connecter.';
      }
    } catch (e) {
      print('⚠️ Erreur vérification email: $e');
      // Continue quand même
    }

    // Étape 4: Créer le compte Firebase Auth
    print('\n🔐 Création du compte Firebase Auth...');

    UserCredential? userCredential;

    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: tempEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur Firebase Auth: ${e.code}');

      if (e.code == 'email-already-in-use') {
        return 'ERROR:Ce numéro est déjà utilisé';
      } else if (e.code == 'weak-password') {
        return 'ERROR:Mot de passe trop faible (minimum 6 caractères)';
      } else if (e.code == 'invalid-email') {
        return 'ERROR:Format de numéro invalide';
      } else {
        return 'ERROR:${e.message ?? "Erreur d\'inscription"}';
      }
    }

    final user = userCredential.user;

    if (user == null) {
      print('❌ Échec création compte');
      return 'ERROR:Échec de la création du compte';
    }

    print('✅ Compte Firebase créé');
    print('   └─ UID: ${user.uid}');

    // Étape 5: Créer le document utilisateur dans Firestore
    print('\n📝 Création du profil Firestore...');

    await _firestore.collection('users').doc(user.uid).set({
      'uId': user.uid,
      'phone_number': phoneNumber,
      'email': tempEmail, // Email temporaire
      'created_time': FieldValue.serverTimestamp(),
      'photo_url': '',
      'gender': '',
      'Bio': '',
      'firstname': '',
      'lastname': '',
      'display_name': '',
      'age': 0,
      'location': '',
      'relationshiptype': '',
      'referralCode': '', // Sera rempli plus tard via popup
      'referralInfluencerId': '',
      'isVerified': false,
      'accountStatus': 'pending',
      'profileCompleted': false,
    });

    print('✅ Profil Firestore créé');
    print('\n✅ INSCRIPTION TERMINÉE AVEC SUCCÈS');

    return 'SUCCESS:${user.uid}';
  } catch (e, stackTrace) {
    print('❌ ERREUR CRITIQUE: $e');
    print('Stack: $stackTrace');
    return 'ERROR:Une erreur est survenue: $e';
  }
}

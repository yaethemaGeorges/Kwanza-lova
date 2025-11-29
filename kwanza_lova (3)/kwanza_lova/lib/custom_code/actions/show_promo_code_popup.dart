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

// Custom Action: showPromoCodePopup (VERSION CORRIGÉE)
// Path: /lib/custom_code/actions/show_promo_code_popup.dart

import '/custom_code/actions/index.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> showPromoCodePopup(BuildContext context) async {
  final TextEditingController promoController = TextEditingController();
  bool? result = false;

  result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return _PromoCodeDialog(promoController: promoController);
    },
  );

  promoController.dispose();
  return result ?? false;
}

class _PromoCodeDialog extends StatefulWidget {
  final TextEditingController promoController;

  const _PromoCodeDialog({required this.promoController});

  @override
  _PromoCodeDialogState createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<_PromoCodeDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _submitPromo() async {
    final code = widget.promoController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un code promo';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      print('╔═══════════════════════════════════════════════════╗');
      print('║          VALIDATION CODE PROMO                    ║');
      print('╚═══════════════════════════════════════════════════╝');
      print('🔍 Code: $code');

      // Récupérer l'utilisateur actuel
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Utilisateur non connecté');
        setState(() {
          _errorMessage = 'Vous devez être connecté';
          _isLoading = false;
        });
        return;
      }

      print('👤 UserId: ${user.uid}');

      // Vérifier que l'utilisateur n'a pas déjà un code promo
      print('🔍 Vérification code existant...');

      DocumentSnapshot userDoc;
      try {
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
      } catch (e) {
        print('❌ Erreur lecture document utilisateur: $e');
        setState(() {
          _errorMessage =
              'Erreur d\'accès aux données. Vérifiez vos permissions Firestore.';
          _isLoading = false;
        });
        return;
      }

      if (userDoc.exists) {
        final existingCode = userDoc.data() is Map
            ? (userDoc.data() as Map<String, dynamic>)['referralCode'] ?? ''
            : '';

        if (existingCode.isNotEmpty) {
          print('⚠️ Code promo déjà utilisé: $existingCode');
          setState(() {
            _errorMessage = 'Vous avez déjà utilisé le code: $existingCode';
            _isLoading = false;
          });
          return;
        }
      }

      // Chercher le code promo dans Firestore
      print('🔍 Recherche du code promo dans Firestore...');

      QuerySnapshot promoQuery;
      try {
        promoQuery = await FirebaseFirestore.instance
            .collection('influencers')
            .where('promoCode', isEqualTo: code)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();
      } catch (e) {
        print('❌ Erreur recherche code promo: $e');
        setState(() {
          _errorMessage =
              'Erreur de recherche. Vérifiez vos permissions Firestore.';
          _isLoading = false;
        });
        return;
      }

      if (promoQuery.docs.isEmpty) {
        print('❌ Code promo introuvable');
        setState(() {
          _errorMessage = 'Code promo invalide ou inexistant';
          _isLoading = false;
        });
        return;
      }

      final promoDoc = promoQuery.docs.first;
      final promoData = promoDoc.data() as Map<String, dynamic>;
      final influencerId = promoDoc.id;

      print('✅ Code promo trouvé');
      print('   └─ InfluencerId: $influencerId');

      // Vérifier l'expiration
      final expiresAt = (promoData['codeExpiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        print('❌ Code promo expiré');
        setState(() {
          _errorMessage = 'Code promo expiré';
          _isLoading = false;
        });
        return;
      }

      print('✅ Code promo valide et actif');

      // Mettre à jour le document utilisateur
      print('📝 Mise à jour du document utilisateur...');
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'referralCode': code,
          'referralInfluencerId': influencerId,
        });
        print('✅ Document utilisateur mis à jour');
      } catch (e) {
        print('❌ Erreur mise à jour utilisateur: $e');
        setState(() {
          _errorMessage =
              'Erreur de mise à jour. Vérifiez vos permissions Firestore.';
          _isLoading = false;
        });
        return;
      }

      // Créer l'entrée de tracking
      print('📊 Création du tracking promo...');
      try {
        await FirebaseFirestore.instance.collection('promo_signups').add({
          'userId': user.uid,
          'promoCode': code,
          'influencerId': influencerId,
          'signupDate': FieldValue.serverTimestamp(),
          'isActive': false,
          'userStatus': 'pending',
          'lastActiveDate': FieldValue.serverTimestamp(),
          'adRevenueGenerated': 0.0,
          'isPremium': false,
          'premiumStartDate': null,
          'location': '',
          'verifiedAt': null,
          'totalAdsWatched': 0,
          'lastAdRevenue': 0.0,
          'lastAdType': '',
          'lastAdPlatform': '',
        });
        print('✅ Tracking promo créé avec succès');
      } catch (e) {
        print('❌ Erreur création tracking: $e');
        // Continue quand même, l'essentiel est fait
      }

      print('╚═══════════════════════════════════════════════════╝');

      setState(() {
        _successMessage = '🎉 Code promo appliqué avec succès !';
        _isLoading = false;
      });

      // Attendre 2 secondes puis fermer le popup
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      print('❌ ERREUR CRITIQUE: $e');
      print('Stack: $stackTrace');
      setState(() {
        _errorMessage = 'Erreur inattendue: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _skip() {
    print('⏭️ Utilisateur a passé le code promo');
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Détecter le thème (clair ou sombre)
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6F61EF),
              Color(0xFF39D2C0),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            const Text(
              'Code Promo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            const Text(
              'Avez-vous un code promo d\'un influenceur ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // 🎨 CHAMP DE SAISIE ADAPTATIF
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.promoController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: Color(0xFF6F61EF), // Violet pour le texte
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'INFLUENCE2024',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                    letterSpacing: 1,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                enabled: !_isLoading,
                onSubmitted: (_) => _submitPromo(),
              ),
            ),

            // Message d'erreur
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Message de succès
            if (_successMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _skip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Passer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6F61EF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6F61EF),
                              ),
                            ),
                          )
                        : const Text(
                            'Valider',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

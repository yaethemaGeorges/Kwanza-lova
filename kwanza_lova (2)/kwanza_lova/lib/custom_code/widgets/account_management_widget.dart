// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:firebase_auth/firebase_auth.dart';

class _ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double value(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  static double fontSize(BuildContext context, double base) {
    if (isDesktop(context)) return base * 1.2;
    if (isTablet(context)) return base * 1.1;
    return base;
  }
}

// ✅ À ajouter en haut de chaque widget custom, avant la classe principale
class _FirestoreListenerManager {
  static final Map<String, StreamSubscription> _activeListeners = {};
  static int _listenerCount = 0;

  static void addListener(String key, StreamSubscription subscription) {
    // Annuler l'ancien listener s'il existe
    _activeListeners[key]?.cancel();

    _activeListeners[key] = subscription;
    _listenerCount++;

    print('📊 Listeners actifs: $_listenerCount');

    // ✅ Alerte si trop de listeners
    if (_listenerCount > 50) {
      print(
          '⚠️ ALERTE: ${_listenerCount} listeners actifs! Risque de dépassement.');
    }
  }

  static void removeListener(String key) {
    _activeListeners[key]?.cancel();
    _activeListeners.remove(key);
    _listenerCount--;

    print('📊 Listeners actifs: $_listenerCount');
  }

  static void clearAll() {
    for (var sub in _activeListeners.values) {
      sub.cancel();
    }
    _activeListeners.clear();
    _listenerCount = 0;

    print('🧹 Tous les listeners nettoyés');
  }

  static int get activeCount => _listenerCount;
}

// 🔥 VERSION OPTIMISÉE AVEC FIREBASE ET THÈME KWANZA-LOVA

class AccountManagementWidget extends StatefulWidget {
  const AccountManagementWidget({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<AccountManagementWidget> createState() =>
      _AccountManagementWidgetState();
}

class _AccountManagementWidgetState extends State<AccountManagementWidget> {
  // 🎨 Thème Kwanza-Lova
  static const Color primaryColor = Color(0xFF6F61EF);
  static const Color secondaryColor = Color(0xFF39D2C0);
  static const Color tertiaryColor = Color(0xFFEE8B60);
  static const Color textColor = Color(0xFF15161E);
  static const Color textSecondaryColor = Color(0xFF606A85);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color dangerColor = Color(0xFFD32F2F);

  // Variables d'état
  String accountStatus = 'active'; // 'active', 'deactivated', 'deleted'
  String? showConfirmation; // 'delete' ou 'deactivate'
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? userData;

  // Contrôleur pour la vérification du mot de passe
  TextEditingController passwordController = TextEditingController();
  bool showPasswordField = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  // ✅ Charge les données utilisateur
  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data();
          accountStatus = userData?['account_status'] ?? 'active';
        });
      }
    } catch (e) {
      print('❌ Erreur chargement utilisateur: $e');
      _showErrorSnackBar('Impossible de charger les données du compte');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: dangerColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: secondaryColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✅ SUPPRESSION COMPLÈTE DU COMPTE
  Future<void> handleDeleteAccount() async {
    if (widget.currentUserId.isEmpty) {
      _showErrorSnackBar('Utilisateur non identifié');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final batch = FirebaseFirestore.instance.batch();

      print('🗑️ Début suppression compte: ${widget.currentUserId}');

      // 1. Marque le compte comme supprimé
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);

      batch.update(userRef, {
        'account_status': 'deleted',
        'deleted_at': FieldValue.serverTimestamp(),
        'email': '${widget.currentUserId}@deleted.user',
        'display_name': 'Compte supprimé',
        'photo_url': '',
      });

      // 2. Désactive tous les matches
      final matchesSnapshot = await FirebaseFirestore.instance
          .collection('user_matches')
          .doc(widget.currentUserId)
          .collection('matches')
          .get();

      for (var matchDoc in matchesSnapshot.docs) {
        batch.update(matchDoc.reference, {
          'isActive': false,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. Désactive les conversations
      final conversationsSnapshot = await FirebaseFirestore.instance
          .collection('conversations')
          .where('participant_ids', arrayContains: widget.currentUserId)
          .get();

      for (var convDoc in conversationsSnapshot.docs) {
        batch.update(convDoc.reference, {
          'isActive': false,
          'deletedBy': FieldValue.arrayUnion([widget.currentUserId]),
        });
      }

      // 4. Supprime les likes donnés et reçus
      final likesGivenSnapshot = await FirebaseFirestore.instance
          .collection('likes')
          .where('liker_id', isEqualTo: widget.currentUserId)
          .get();

      for (var likeDoc in likesGivenSnapshot.docs) {
        batch.delete(likeDoc.reference);
      }

      final likesReceivedSnapshot = await FirebaseFirestore.instance
          .collection('likes')
          .where('liked_id', isEqualTo: widget.currentUserId)
          .get();

      for (var likeDoc in likesReceivedSnapshot.docs) {
        batch.delete(likeDoc.reference);
      }

      // 5. Annule les abonnements actifs
      final subscriptionsSnapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('user_id', isEqualTo: widget.currentUserId)
          .where('status', isEqualTo: 'active')
          .get();

      for (var subDoc in subscriptionsSnapshot.docs) {
        batch.update(subDoc.reference, {
          'status': 'cancelled',
          'cancelled_at': FieldValue.serverTimestamp(),
          'cancellation_reason': 'Account deleted',
        });
      }

      // 6. Archive les notifications
      final notificationsSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('user_id', isEqualTo: widget.currentUserId)
          .get();

      for (var notifDoc in notificationsSnapshot.docs) {
        batch.delete(notifDoc.reference);
      }

      // Commit toutes les modifications
      await batch.commit();

      // 7. Supprime l'authentification Firebase
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.uid == widget.currentUserId) {
          await user.delete();
          print('✅ Compte Firebase Auth supprimé');
        }
      } catch (authError) {
        print('⚠️ Erreur suppression Firebase Auth: $authError');
        // Continue même si la suppression Auth échoue
      }

      setState(() {
        accountStatus = 'deleted';
        showConfirmation = null;
        isLoading = false;
      });

      _showSuccessSnackBar('Compte supprimé avec succès');
      print('✅ Suppression compte terminée');

      // Redirection après 3 secondes
      await Future.delayed(Duration(seconds: 3));

      // Navigation vers la page d'inscription
      if (mounted) {
        context.goNamedAuth('SignUpPage', context.mounted);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors de la suppression: ${e.toString()}';
      });
      _showErrorSnackBar('Impossible de supprimer le compte');
      print('❌ Erreur suppression compte: $e');
    }
  }

// ✅ NOUVELLE FONCTION : Désactivation des matches par lots
  Future<void> _disableMatchesInBatches(String userId) async {
    print('📦 Désactivation des matches par lots...');

    int processedCount = 0;
    DocumentSnapshot? lastDoc;

    while (true) {
      Query query = FirebaseFirestore.instance
          .collection('user_matches')
          .doc(userId)
          .collection('matches')
          .limit(100);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) break;

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      processedCount += snapshot.docs.length;
      lastDoc = snapshot.docs.last;

      print('   ├─ $processedCount matches désactivés');

      if (snapshot.docs.length < 100) break;
    }

    print('✅ $processedCount matches désactivés au total');
  }

// ✅ NOUVELLE FONCTION : Désactivation des conversations
  Future<void> _disableConversationsInBatches(String userId) async {
    print('📦 Désactivation des conversations...');

    final snapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .where('participant_ids', arrayContains: userId)
        .limit(100)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isActive': false,
        'deletedBy': FieldValue.arrayUnion([userId]),
      });
    }

    await batch.commit();
    print('✅ ${snapshot.docs.length} conversations désactivées');
  }

// ✅ NOUVELLE FONCTION : Suppression des likes
  Future<void> _deleteLikesInBatches(String userId) async {
    print('📦 Suppression des likes...');

    final likesGivenSnapshot = await FirebaseFirestore.instance
        .collection('likes')
        .where('liker_id', isEqualTo: userId)
        .limit(500)
        .get();

    if (likesGivenSnapshot.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in likesGivenSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('   ├─ ${likesGivenSnapshot.docs.length} likes donnés supprimés');
    }

    final likesReceivedSnapshot = await FirebaseFirestore.instance
        .collection('likes')
        .where('liked_id', isEqualTo: userId)
        .limit(500)
        .get();

    if (likesReceivedSnapshot.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in likesReceivedSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('   ├─ ${likesReceivedSnapshot.docs.length} likes reçus supprimés');
    }
  }

  // ✅ DÉSACTIVATION DU COMPTE
  Future<void> handleDeactivateAccount() async {
    if (widget.currentUserId.isEmpty) {
      _showErrorSnackBar('Utilisateur non identifié');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final batch = FirebaseFirestore.instance.batch();

      print('🔒 Début désactivation compte: ${widget.currentUserId}');

      // 1. Marque le compte comme désactivé
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);

      batch.update(userRef, {
        'account_status': 'deactivated',
        'deactivated_at': FieldValue.serverTimestamp(),
        'is_visible': false,
      });

      // 2. Cache le profil dans les recherches
      batch.update(userRef, {
        'searchable': false,
        'show_in_swipe': false,
      });

      // 3. Désactive temporairement les matches
      // 2. Désactive les matches avec PAGINATION
      await _disableMatchesInBatches(widget.currentUserId);

      // 3. Désactive les conversations avec PAGINATION
      await _disableConversationsInBatches(widget.currentUserId);

      // 4. Supprime les likes avec PAGINATION
      await _deleteLikesInBatches(widget.currentUserId);

      await batch.commit();

      setState(() {
        accountStatus = 'deactivated';
        showConfirmation = null;
        isLoading = false;
      });

      _showSuccessSnackBar('Compte désactivé avec succès');
      print('✅ Désactivation compte terminée');
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors de la désactivation: ${e.toString()}';
      });
      _showErrorSnackBar('Impossible de désactiver le compte');
      print('❌ Erreur désactivation compte: $e');
    }
  }

  // ✅ RÉACTIVATION DU COMPTE
  Future<void> handleActivateAccount() async {
    if (widget.currentUserId.isEmpty) {
      _showErrorSnackBar('Utilisateur non identifié');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final batch = FirebaseFirestore.instance.batch();

      print('✅ Début réactivation compte: ${widget.currentUserId}');

      // 1. Réactive le compte
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);

      batch.update(userRef, {
        'account_status': 'active',
        'reactivated_at': FieldValue.serverTimestamp(),
        'is_visible': true,
        'searchable': true,
        'show_in_swipe': true,
      });

      // 2. Réactive les matches
      final matchesSnapshot = await FirebaseFirestore.instance
          .collection('user_matches')
          .doc(widget.currentUserId)
          .collection('matches')
          .where('isActive', isEqualTo: false)
          .where('deactivatedAt', isNotEqualTo: null)
          .get();

      for (var matchDoc in matchesSnapshot.docs) {
        batch.update(matchDoc.reference, {
          'isActive': true,
          'reactivatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      setState(() {
        accountStatus = 'active';
        isLoading = false;
      });

      _showSuccessSnackBar('Compte réactivé avec succès ! 🎉');
      print('✅ Réactivation compte terminée');
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors de la réactivation: ${e.toString()}';
      });
      _showErrorSnackBar('Impossible de réactiver le compte');
      print('❌ Erreur réactivation compte: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      constraints: BoxConstraints(
        maxWidth: _ResponsiveHelper.value(
          context,
          mobile: 400,
          tablet: 600,
          desktop: 800,
        ),
      ),
      margin: EdgeInsets.all(
        _ResponsiveHelper.value(context, mobile: 16, tablet: 24, desktop: 32),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(
        _ResponsiveHelper.value(context, mobile: 24, tablet: 32, desktop: 40),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    // Écran de confirmation
    if (showConfirmation != null) {
      return _buildConfirmationScreen();
    }

    // Écran après suppression
    if (accountStatus == 'deleted') {
      return _buildDeletedScreen();
    }

    // Interface principale
    return _buildMainInterface();
  }

  Widget _buildConfirmationScreen() {
    bool isDelete = showConfirmation == 'delete';

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône
          Container(
            width: _ResponsiveHelper.value(context,
                mobile: 80, tablet: 90, desktop: 100),
            height: _ResponsiveHelper.value(context,
                mobile: 80, tablet: 90, desktop: 100),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isDelete
                  ? dangerColor.withOpacity(0.1)
                  : warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: isDelete ? dangerColor : warningColor,
                width: 2,
              ),
            ),
            child: Icon(
              isDelete
                  ? Icons.delete_forever_outlined
                  : Icons.pause_circle_outlined,
              size: 40,
              color: isDelete ? dangerColor : warningColor,
            ),
          ),

          // Titre
          Text(
            isDelete ? 'Supprimer mon compte' : 'Désactiver mon compte',
            style: TextStyle(
              fontSize: _ResponsiveHelper.fontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Message d'avertissement
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDelete
                    ? dangerColor.withOpacity(0.3)
                    : warningColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isDelete ? Icons.warning_amber_rounded : Icons.info_outline,
                  size: 32,
                  color: isDelete ? dangerColor : warningColor,
                ),
                const SizedBox(height: 12),
                Text(
                  isDelete ? 'Action irréversible ⚠️' : 'Pause temporaire 💤',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isDelete
                      ? 'Toutes vos données seront définitivement supprimées :\n• Messages et conversations\n• Matchs et likes\n• Abonnements\n• Photos et profil'
                      : 'Votre profil sera caché mais vos données restent sauvegardées :\n• Profil invisible\n• Matchs en pause\n• Réactivation facile',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Message d'erreur
          if (errorMessage != null) ...[
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dangerColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: dangerColor, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: dangerColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Boutons
          Column(
            children: [
              // Bouton principal (danger)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : (isDelete
                          ? handleDeleteAccount
                          : handleDeactivateAccount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDelete ? dangerColor : warningColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('Traitement en cours...'),
                          ],
                        )
                      : Text(
                          isDelete
                              ? 'Oui, supprimer définitivement'
                              : 'Oui, désactiver temporairement',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Bouton annuler
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            showConfirmation = null;
                            errorMessage = null;
                          });
                        },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: textSecondaryColor.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: dangerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: dangerColor, width: 2),
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 40,
            color: dangerColor,
          ),
        ),
        Text(
          'Compte supprimé',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Votre compte a été définitivement supprimé.',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Redirection en cours...',
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ],
    );
  }

  Widget _buildMainInterface() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.manage_accounts_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),

          Text(
            'Gestion du compte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Gérez la visibilité et les paramètres de votre profil',
            style: TextStyle(
              fontSize: 14,
              color: textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          if (accountStatus == 'active') ...[
            // Statut actif
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: successColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: successColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: successColor.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Compte actif',
                    style: TextStyle(
                      color: successColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Option Désactiver
            _buildActionCard(
              icon: Icons.pause_circle_outlined,
              iconColor: warningColor,
              backgroundColor: warningColor.withOpacity(0.05),
              borderColor: warningColor.withOpacity(0.3),
              title: 'Désactiver mon compte 🔒',
              subtitle:
                  'Pause temporaire. Vos données sont conservées en sécurité.',
              buttonText: 'Désactiver temporairement',
              buttonColor: warningColor,
              onTap: () {
                setState(() {
                  showConfirmation = 'deactivate';
                });
              },
            ),

            const SizedBox(height: 16),

            // Option Supprimer
            _buildActionCard(
              icon: Icons.delete_forever_outlined,
              iconColor: dangerColor,
              backgroundColor: dangerColor.withOpacity(0.05),
              borderColor: dangerColor.withOpacity(0.3),
              title: 'Supprimer mon compte ❌',
              subtitle: 'Action définitive. Toutes vos données seront perdues.',
              buttonText: 'Supprimer définitivement',
              buttonColor: dangerColor,
              onTap: () {
                setState(() {
                  showConfirmation = 'delete';
                });
              },
            ),
          ],

          if (accountStatus == 'deactivated') ...[
            Container(
              width: _ResponsiveHelper.value(context,
                  mobile: 80, tablet: 90, desktop: 100),
              height: _ResponsiveHelper.value(context,
                  mobile: 80, tablet: 90, desktop: 100),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: warningColor, width: 2),
              ),
              child: Icon(
                Icons.pause_circle_outlined,
                size: 40,
                color: warningColor,
              ),
            ),
            Text(
              'Compte désactivé',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: warningColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: warningColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Votre profil n\'est plus visible 🔒',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vos données sont conservées en sécurité.\nRéactivez quand vous voulez !',
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : handleActivateAccount,
                icon: Icon(
                  isLoading ? Icons.hourglass_empty : Icons.favorite_outline,
                  size: 20,
                ),
                label: Text(
                  isLoading ? 'Réactivation...' : 'Réactiver mon compte',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

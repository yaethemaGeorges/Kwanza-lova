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

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:intl/intl.dart';

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

// 🎨 PALETTE DE COULEURS DE L'APP
const Color primaryColor = Color(0xFF6F61EF);
const Color secondaryColor = Color(0xFF39D2C0);
const Color tertiaryColor = Color(0xFFEE8B60);
const Color textColor = Color(0xFF15161E);
const Color textSecondaryColor = Color(0xFF606A85);

class SubscriptionManagementWidget extends StatefulWidget {
  const SubscriptionManagementWidget({
    Key? key,
    this.width,
    this.height,
    required this.currentUserId,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  _SubscriptionManagementWidgetState createState() =>
      _SubscriptionManagementWidgetState();
}

class _SubscriptionManagementWidgetState
    extends State<SubscriptionManagementWidget> {
  bool isLoading = true;
  bool autoRenewEnabled = true;
  bool notificationsEnabled = true;
  Map<String, dynamic>? subscriptionData;
  List<Map<String, dynamic>> referralHistory = [];
  String? errorMessage;
  String? myReferralCode;
  int totalReferrals = 0;

  TextEditingController promoCodeController = TextEditingController();

  final Map<String, Map<String, dynamic>> planDetails = {
    'classic': {
      'name': 'Classique',
      'emoji': '⭐',
      'color': secondaryColor,
      'features': [
        'Swipes illimités',
        'Messages texte illimités',
        'Profil vérifié',
        'Support client prioritaire',
      ],
    },
    'premium': {
      'name': 'Premium',
      'emoji': '💎',
      'color': primaryColor,
      'features': [
        'Boost 48h (2x plus de vues)',
        'Priorité dans les suggestions',
        'Badge premium sur votre profil',
        'Voir qui vous a liké',
        'Messages vocaux',
        'Appels audio',
      ],
    },
    'platinum': {
      'name': 'Platinum',
      'emoji': '🥇',
      'color': tertiaryColor,
      'features': [
        'Boost 7 jours (5x plus de vues)',
        'Badge Gold exclusif',
        'Appels vidéo illimités',
        'Super likes illimités',
        'Rewind illimité',
        'Passeport mondial',
        'Support VIP 24/7',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptionData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      if (!userDoc.exists) {
        throw Exception('Utilisateur non trouvé');
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        subscriptionData = {
          'isUserSubscribed': userData['isUserSubscribed'] ?? false,
          'userSubscriptionPlan': userData['userSubscriptionPlan'] ?? '',
          'subscriptionType': userData['subscriptionType'] ?? '',
          'subscriptionPrice': userData['subscriptionPrice'] ?? 0.0,
          'subscriptionCurrency': userData['subscriptionCurrency'] ?? 'USD',
          'subscriptionExpiry': userData['subscriptionExpiry'],
          'subscriptionActivatedAt': userData['subscriptionActivatedAt'],
          'autoRenew': userData['autoRenew'] ?? true,
          'notificationsEnabled': userData['notificationsEnabled'] ?? true,
        };
        autoRenewEnabled = subscriptionData!['autoRenew'] as bool;
        notificationsEnabled =
            subscriptionData!['notificationsEnabled'] as bool;
        myReferralCode = userData['referralCode'] ?? _generateReferralCode();
      });

      await Future.wait([
        _loadReferralHistory(),
        _checkAndScheduleNotifications(),
      ]);

      if (userData['referralCode'] == null) {
        await _saveReferralCode(myReferralCode!);
      }

      setState(() {
        isLoading = false;
      });

      print(
          '✅ Abonnement chargé: ${subscriptionData!['userSubscriptionPlan']}');
      print('🎁 Code parrainage: $myReferralCode');
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de chargement: $e';
      });
      print('❌ Erreur chargement: $e');
    }
  }

  Future<void> _loadReferralHistory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('referrals')
          .where('referrerId', isEqualTo: widget.currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> history = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        history.add({
          'id': doc.id,
          'referredUserId': data['referredUserId'],
          'referredUserName': data['referredUserName'],
          'status': data['status'],
          'reward': data['reward'],
          'createdAt': data['createdAt'],
        });
      }

      setState(() {
        referralHistory = history;
        totalReferrals = history.length;
      });

      print('🎁 ${totalReferrals} parrainages chargés');
    } catch (e) {
      print('⚠️ Erreur chargement parrainages: $e');
    }
  }

  String _generateReferralCode() {
    final random = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final numbers = '0123456789';

    String code = '';
    for (int i = 0; i < 3; i++) {
      code += letters[random.nextInt(letters.length)];
    }
    for (int i = 0; i < 3; i++) {
      code += numbers[random.nextInt(numbers.length)];
    }

    return code;
  }

  Future<void> _saveReferralCode(String code) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({'referralCode': code});

      await FirebaseFirestore.instance
          .collection('referral_codes')
          .doc(code)
          .set({
        'userId': widget.currentUserId,
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      print('✅ Code parrainage sauvegardé: $code');
    } catch (e) {
      print('❌ Erreur sauvegarde code: $e');
    }
  }

  Future<void> _applyPromoCode() async {
    final code = promoCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showErrorSnackBar('Veuillez entrer un code');
      return;
    }

    if (code == myReferralCode) {
      _showErrorSnackBar('Vous ne pouvez pas utiliser votre propre code');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final codeDoc = await FirebaseFirestore.instance
          .collection('referral_codes')
          .doc(code)
          .get();

      if (!codeDoc.exists) {
        throw Exception('Code invalide');
      }

      final codeData = codeDoc.data() as Map<String, dynamic>;
      final referrerId = codeData['userId'] as String;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['usedReferralCode'] != null) {
        throw Exception('Vous avez déjà utilisé un code de parrainage');
      }

      await FirebaseFirestore.instance.collection('referrals').add({
        'referrerId': referrerId,
        'referredUserId': widget.currentUserId,
        'referredUserName': userData['display_name'] ?? 'Utilisateur',
        'code': code,
        'status': 'pending',
        'reward': 5.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({
        'usedReferralCode': code,
        'referralDiscount': 5.0,
      });

      setState(() {
        isLoading = false;
      });

      promoCodeController.clear();
      _showSuccessDialog(
        '🎉 Code validé !',
        'Vous avez reçu 5€ de réduction sur votre prochain abonnement. Le parrain recevra aussi une récompense après votre premier paiement.',
      );

      await _loadSubscriptionData();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
      print('❌ Erreur code promo: $e');
    }
  }

  void _shareReferralCode() {
    if (myReferralCode == null) return;

    Clipboard.setData(ClipboardData(text: myReferralCode!));
    _showSuccessSnackBar('Code copié : $myReferralCode');

    print('📤 Partage code: $myReferralCode');
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({'notificationsEnabled': value});

      if (value) {
        await _scheduleExpiryNotifications();
      } else {
        await _cancelScheduledNotifications();
      }

      setState(() {
        notificationsEnabled = value;
        if (subscriptionData != null) {
          subscriptionData!['notificationsEnabled'] = value;
        }
        isLoading = false;
      });

      _showSuccessSnackBar(
          value ? 'Notifications activées' : 'Notifications désactivées');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erreur lors de la modification');
    }
  }

  Future<void> _checkAndScheduleNotifications() async {
    if (!notificationsEnabled) return;

    final expiryTimestamp = subscriptionData?['subscriptionExpiry'];
    if (expiryTimestamp == null) return;

    final expiryDate = (expiryTimestamp as Timestamp).toDate();
    final now = DateTime.now();
    final daysRemaining = expiryDate.difference(now).inDays;

    if (daysRemaining <= 7 && daysRemaining > 0) {
      await _scheduleExpiryNotifications();
    }
  }

  Future<void> _scheduleExpiryNotifications() async {
    try {
      final expiryTimestamp = subscriptionData?['subscriptionExpiry'];
      if (expiryTimestamp == null) return;

      final expiryDate = (expiryTimestamp as Timestamp).toDate();

      final notifications = [
        {
          'userId': widget.currentUserId,
          'type': 'subscription_expiry_warning',
          'title': 'Votre abonnement expire dans 7 jours',
          'body':
              'Renouvelez maintenant pour continuer à profiter des avantages premium',
          'scheduledFor': expiryDate.subtract(Duration(days: 7)),
          'status': 'scheduled',
        },
        {
          'userId': widget.currentUserId,
          'type': 'subscription_expiry_warning',
          'title': 'Votre abonnement expire dans 3 jours',
          'body':
              'Ne perdez pas vos avantages premium ! Renouvelez dès maintenant.',
          'scheduledFor': expiryDate.subtract(Duration(days: 3)),
          'status': 'scheduled',
        },
        {
          'userId': widget.currentUserId,
          'type': 'subscription_expiry_urgent',
          'title': 'Votre abonnement expire demain !',
          'body': 'Dernière chance de renouveler et garder tous vos avantages.',
          'scheduledFor': expiryDate.subtract(Duration(days: 1)),
          'status': 'scheduled',
        },
      ];

      for (var notification in notifications) {
        await FirebaseFirestore.instance
            .collection('scheduled_notifications')
            .add(notification);
      }

      print('🔔 Notifications programmées');
    } catch (e) {
      print('❌ Erreur programmation notifications: $e');
    }
  }

  Future<void> _cancelScheduledNotifications() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('scheduled_notifications')
          .where('userId', isEqualTo: widget.currentUserId)
          .where('status', isEqualTo: 'scheduled')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('🔕 Notifications annulées');
    } catch (e) {
      print('❌ Erreur annulation notifications: $e');
    }
  }

  Future<void> _toggleAutoRenew(bool value) async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({'autoRenew': value});

      setState(() {
        autoRenewEnabled = value;
        if (subscriptionData != null) {
          subscriptionData!['autoRenew'] = value;
        }
        isLoading = false;
      });

      _showSuccessSnackBar(value
          ? 'Renouvellement automatique activé'
          : 'Renouvellement automatique désactivé');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erreur lors de la modification');
    }
  }

  Future<void> _cancelSubscription() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Annuler l\'abonnement ?',
            style: TextStyle(
                color: _getAdaptiveTextColor(), fontWeight: FontWeight.bold)),
        content: Text(
          'Vous perdrez tous les avantages premium. Votre abonnement restera actif jusqu\'à la date d\'expiration.',
          style: TextStyle(color: _getAdaptiveTextSecondaryColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Non', style: TextStyle(color: textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({
        'autoRenew': false,
        'subscriptionCancelledAt': FieldValue.serverTimestamp(),
      });

      await _loadSubscriptionData();
      _showSuccessSnackBar('Abonnement annulé. Actif jusqu\'à expiration.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erreur lors de l\'annulation');
    }
  }

  Future<void> _navigateToSubscriptionWidget() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionWidget(
            currentUserId: widget.currentUserId,
            currency: subscriptionData?['subscriptionCurrency'] ?? 'USD',
          ),
        ),
      );

      if (result == true) {
        print('✅ Retour de SubscriptionWidget - Rechargement...');
        await _loadSubscriptionData();
        _showSuccessSnackBar('Abonnement mis à jour !');
      }
    } catch (e) {
      print('❌ Erreur navigation: $e');
      _showErrorSnackBar('Erreur lors de la navigation');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: TextStyle(
                color: _getAdaptiveTextColor(), fontWeight: FontWeight.bold)),
        content: Text(message,
            style: TextStyle(color: _getAdaptiveTextSecondaryColor())),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getAdaptiveTextColor() {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : textColor;
  }

  Color _getAdaptiveTextSecondaryColor() {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white70 : textSecondaryColor;
  }

  Color _getAdaptiveCardColor() {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.grey[850]! : Colors.white;
  }

  Color _getAdaptiveBackgroundColor() {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[50]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: _getAdaptiveBackgroundColor(),
      child: isLoading
          ? _buildLoadingState()
          : errorMessage != null
              ? _buildErrorState()
              : subscriptionData!['isUserSubscribed'] as bool
                  ? _buildActiveSubscription()
                  : _buildNoSubscription(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 16),
          Text('Chargement...',
              style: TextStyle(color: _getAdaptiveTextSecondaryColor())),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Erreur de chargement',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getAdaptiveTextColor())),
            SizedBox(height: 8),
            Text(errorMessage!,
                style: TextStyle(color: _getAdaptiveTextSecondaryColor()),
                textAlign: TextAlign.center),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSubscriptionData,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSubscription() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _getAdaptiveCardColor(),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.diamond, size: 40, color: primaryColor),
                ),
                SizedBox(height: 24),
                Text('Aucun abonnement actif',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getAdaptiveTextColor())),
                SizedBox(height: 12),
                Text(
                  'Débloquez toutes les fonctionnalités premium pour maximiser vos chances de trouver l\'amour !',
                  style: TextStyle(
                      fontSize: 16, color: _getAdaptiveTextSecondaryColor()),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToSubscriptionWidget,
                    icon: Icon(Icons.star, size: 24),
                    label: Text('Voir les abonnements',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildPromoCodeSection(),
          SizedBox(height: 24),
          _buildFeaturesList(),
        ],
      ),
    );
  }

  Widget _buildActiveSubscription() {
    final planId = subscriptionData!['userSubscriptionPlan'] as String;
    final plan = planDetails[planId] ?? planDetails['classic']!;
    final expiryTimestamp = subscriptionData!['subscriptionExpiry'];
    final DateTime? expiryDate = expiryTimestamp != null
        ? (expiryTimestamp as Timestamp).toDate()
        : null;
    final daysRemaining =
        expiryDate != null ? expiryDate.difference(DateTime.now()).inDays : 0;
    final isExpiringSoon = daysRemaining <= 7 && daysRemaining > 0;
    final isExpired = daysRemaining < 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte d'abonnement principal
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  plan['color'] as Color,
                  (plan['color'] as Color).withOpacity(0.7)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: (plan['color'] as Color).withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 8))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mon Abonnement',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500)),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? Colors.red
                            : isExpiringSoon
                                ? Colors.orange
                                : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isExpired
                            ? 'EXPIRÉ'
                            : isExpiringSoon
                                ? 'EXPIRE BIENTÔT'
                                : 'ACTIF',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(plan['emoji'] as String,
                        style: TextStyle(fontSize: 48)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan['name'] as String,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text(
                              '${subscriptionData!['subscriptionPrice']} ${subscriptionData!['subscriptionCurrency']}',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expire le',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 4),
                          Text(
                            expiryDate != null
                                ? DateFormat('dd/MM/yyyy').format(expiryDate)
                                : 'Non défini',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Jours restants',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 4),
                          Text(
                            isExpired
                                ? 'Expiré'
                                : daysRemaining > 0
                                    ? '$daysRemaining jours'
                                    : 'Aujourd\'hui',
                            style: TextStyle(
                                color: isExpired
                                    ? Colors.red[300]
                                    : isExpiringSoon
                                        ? Colors.orange[300]
                                        : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Notifications
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getAdaptiveCardColor(),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notificationsEnabled
                        ? primaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: notificationsEnabled
                        ? primaryColor
                        : textSecondaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notifications d\'expiration',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getAdaptiveTextColor())),
                      SizedBox(height: 4),
                      Text(
                        notificationsEnabled
                            ? 'Rappels à J-7, J-3 et J-1'
                            : 'Désactivé - Aucun rappel',
                        style: TextStyle(
                            fontSize: 13,
                            color: _getAdaptiveTextSecondaryColor()),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: isLoading ? null : _toggleNotifications,
                  activeColor: primaryColor,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Renouvellement automatique
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getAdaptiveCardColor(),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: autoRenewEnabled
                        ? secondaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    autoRenewEnabled ? Icons.autorenew : Icons.pause_circle,
                    color:
                        autoRenewEnabled ? secondaryColor : textSecondaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Renouvellement automatique',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getAdaptiveTextColor())),
                      SizedBox(height: 4),
                      Text(
                        autoRenewEnabled
                            ? 'Activé - Votre abonnement sera renouvelé'
                            : 'Désactivé - Pensez à renouveler',
                        style: TextStyle(
                            fontSize: 13,
                            color: _getAdaptiveTextSecondaryColor()),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: autoRenewEnabled,
                  onChanged: isLoading ? null : _toggleAutoRenew,
                  activeColor: secondaryColor,
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          _buildMyReferralCodeSection(),

          SizedBox(height: 24),

          // Fonctionnalités incluses
          Text('Fonctionnalités incluses',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getAdaptiveTextColor())),
          SizedBox(height: 16),
          ...(plan['features'] as List<String>).map((feature) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getAdaptiveCardColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: (plan['color'] as Color).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: plan['color'] as Color, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text(feature,
                          style: TextStyle(color: _getAdaptiveTextColor()))),
                ],
              ),
            );
          }).toList(),

          SizedBox(height: 24),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : _cancelSubscription,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Annuler',
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _navigateToSubscriptionWidget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plan['color'] as Color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Changer',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          if (referralHistory.isNotEmpty) ...[
            SizedBox(height: 32),
            _buildReferralHistorySection(),
          ],
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getAdaptiveCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tertiaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2))
        ],
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
                  color: tertiaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.card_giftcard, color: tertiaryColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Code promo ou parrainage',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getAdaptiveTextColor())),
                    Text('Obtenez 5€ de réduction',
                        style: TextStyle(
                            fontSize: 13,
                            color: _getAdaptiveTextSecondaryColor())),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: promoCodeController,
                  decoration: InputDecoration(
                    hintText: 'Entrez le code',
                    hintStyle:
                        TextStyle(color: _getAdaptiveTextSecondaryColor()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: _getAdaptiveBackgroundColor(),
                    prefixIcon: Icon(Icons.local_offer, color: tertiaryColor),
                  ),
                  style: TextStyle(
                      color: _getAdaptiveTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: isLoading ? null : _applyPromoCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tertiaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyReferralCodeSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tertiaryColor.withOpacity(0.2),
            tertiaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tertiaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: tertiaryColor, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mon code de parrainage',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getAdaptiveTextColor())),
                    Text('Partagez et gagnez ensemble',
                        style: TextStyle(
                            fontSize: 13,
                            color: _getAdaptiveTextSecondaryColor())),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAdaptiveCardColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Votre code',
                        style: TextStyle(
                            fontSize: 12,
                            color: _getAdaptiveTextSecondaryColor())),
                    SizedBox(height: 4),
                    Text(
                      myReferralCode ?? 'ABC123',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: tertiaryColor),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _shareReferralCode,
                  icon: Icon(Icons.share, color: tertiaryColor, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: tertiaryColor.withOpacity(0.1),
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.people, color: secondaryColor, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$totalReferrals ami(s) parrainé(s)',
                    style: TextStyle(
                        color: _getAdaptiveTextColor(),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes parrainages',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getAdaptiveTextColor())),
        SizedBox(height: 16),
        ...referralHistory.take(5).map((referral) {
          final timestamp = referral['createdAt'] as Timestamp?;
          final date = timestamp != null ? timestamp.toDate() : DateTime.now();
          final status = referral['status'] as String;
          final reward = referral['reward'] ?? 0.0;

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAdaptiveCardColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tertiaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.person_add, color: tertiaryColor, size: 24),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(referral['referredUserName'] ?? 'Utilisateur',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getAdaptiveTextColor())),
                      SizedBox(height: 4),
                      Text(DateFormat('dd/MM/yyyy').format(date),
                          style: TextStyle(
                              fontSize: 12,
                              color: _getAdaptiveTextSecondaryColor())),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'completed'
                        ? secondaryColor.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'completed' ? '+${reward}€' : 'En attente',
                    style: TextStyle(
                        color: status == 'completed'
                            ? secondaryColor
                            : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.favorite,
        'title': 'Swipes illimités',
        'desc': 'Plus de limite quotidienne'
      },
      {
        'icon': Icons.star,
        'title': 'Super Likes',
        'desc': 'Démarquez-vous des autres'
      },
      {
        'icon': Icons.flash_on,
        'title': 'Boost profil',
        'desc': 'Soyez vu par plus de monde'
      },
      {
        'icon': Icons.visibility,
        'title': 'Voir les likes',
        'desc': 'Qui vous a liké en premier'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avantages Premium',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getAdaptiveTextColor())),
        SizedBox(height: 16),
        ...features.map((feature) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAdaptiveCardColor(),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: primaryColor.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(feature['icon'] as IconData,
                      color: primaryColor, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feature['title'] as String,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getAdaptiveTextColor())),
                      Text(feature['desc'] as String,
                          style: TextStyle(
                              fontSize: 13,
                              color: _getAdaptiveTextSecondaryColor())),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📝 VERSION SIMPLIFIÉE - ABONNEMENT ACTUEL UNIQUEMENT
// ═══════════════════════════════════════════════════════════════
/*

✅ SUPPRIMÉ :
- Historique des transactions
- Statistiques de dépenses
- Filtres par période
- Bouton télécharger facture

✅ CONSERVÉ :
- Affichage de l'abonnement actuel
- Date d'expiration
- Jours restants
- Fonctionnalités incluses
- Renouvellement automatique
- Notifications d'expiration
- Code de parrainage
- Navigation vers SubscriptionWidget

🎯 FOCUS : L'utilisateur voit uniquement son abonnement en cours,
sans aucune information sur ses dépenses passées.

*/

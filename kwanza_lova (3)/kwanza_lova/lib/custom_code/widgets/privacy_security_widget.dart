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

// Après : import 'dart:async';
// AJOUTER CECI :

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

// 🔥 VERSION OPTIMISÉE AVEC INDEX FIRESTORE ET AMÉLIORATIONS

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

class PrivacySecurityWidget extends StatefulWidget {
  const PrivacySecurityWidget({
    Key? key,
    this.width,
    this.height,
    required this.currentUserId,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  _PrivacySecurityWidgetState createState() => _PrivacySecurityWidgetState();
}

class _PrivacySecurityWidgetState extends State<PrivacySecurityWidget> {
  static const Color primaryColor = Color(0xFF6F61EF);
  static const Color secondaryColor = Color(0xFF39D2C0);
  static const Color tertiaryColor = Color(0xFFEE8B60);
  static const Color textColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF666666);

  bool isInvisibleMode = false;
  bool isLoading = false;
  String selectedSection = 'main';
  String? selectedMatchToReport;
  String? selectedReportType;
  TextEditingController reportDetailsController = TextEditingController();

  List<DocumentReference> blockedContactsRefs = [];

  // ✅ AJOUT CRITIQUE : Cache pour contacts bloqués
  List<DocumentReference> _cachedBlockedContacts = [];
  DateTime? _lastBlockedContactsUpdate;

  List<Map<String, dynamic>> availableMatchesData = [];
  String? errorMessage;
// ✅ AJOUT CRITIQUE : Gestion du StreamSubscription
  StreamSubscription<QuerySnapshot>? _blockedContactsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupBlockedContactsListener(); // ✅ AJOUT
  }

  // ✅ NOUVELLE MÉTHODE : Écoute en temps réel des contacts bloqués
  void _setupBlockedContactsListener() {
    _blockedContactsSubscription = FirebaseFirestore.instance
        .collection('blocked_contacts')
        .where('blocker_id', isEqualTo: widget.currentUserId)
        .orderBy('blocked_date', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          blockedContactsRefs =
              snapshot.docs.map((doc) => doc.reference).toList();
          _cachedBlockedContacts = blockedContactsRefs;
          _lastBlockedContactsUpdate = DateTime.now();
        });
      }
    }, onError: (error) {
      print('❌ Erreur listener contacts bloqués: $error');

      // Fallback sans index si nécessaire
      if (error.toString().contains('index')) {
        _loadBlockedContacts(); // Utilise la méthode existante
      }
    });
  }

  @override
  void dispose() {
    reportDetailsController.dispose();
    _blockedContactsSubscription?.cancel(); // ✅ CRITIQUE : Annuler le listener
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await Future.wait([
        _loadUserSettings(),
        _loadBlockedContacts(),
        _loadAvailableMatches(),
      ]);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de chargement: ${e.toString()}';
      });
      _showErrorSnackBar('Impossible de charger les données');
      print('❌ Erreur initialisation: $e');
    }
  }

  Future<void> _loadUserSettings() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          isInvisibleMode = data?['invisible_mode'] ?? false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement paramètres: $e');
    }
  }

  // ✅ CORRECTION : Avec index Firestore + gestion d'erreur
  Future<void> _loadBlockedContacts() async {
    // ✅ AJOUT CRITIQUE : Vérification du cache (5 minutes)
    if (_lastBlockedContactsUpdate != null &&
        DateTime.now().difference(_lastBlockedContactsUpdate!).inMinutes < 5) {
      print('📦 Utilisation du cache pour contacts bloqués');
      setState(() {
        blockedContactsRefs = _cachedBlockedContacts;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('blocked_contacts')
          .where('blocker_id', isEqualTo: widget.currentUserId)
          .orderBy('blocked_date', descending: true)
          .limit(50)
          .get();

      setState(() {
        blockedContactsRefs =
            snapshot.docs.map((doc) => doc.reference).toList();
        // ✅ Mise en cache
        _cachedBlockedContacts = blockedContactsRefs;
        _lastBlockedContactsUpdate = DateTime.now();
      });

      print(
          '✅ ${blockedContactsRefs.length} contacts bloqués chargés (max 50)');
    } catch (e) {
      print('❌ Erreur chargement contacts bloqués: $e');

      // ✅ CORRECTION CRITIQUE : Fallback sans index
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('blocked_contacts')
            .where('blocker_id', isEqualTo: widget.currentUserId)
            .limit(50)
            .get();

        // Tri manuel
        final docs = snapshot.docs.toList();
        docs.sort((a, b) {
          final aDate = (a.data()['blocked_date'] as Timestamp?)?.toDate();
          final bDate = (b.data()['blocked_date'] as Timestamp?)?.toDate();
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });

        setState(() {
          blockedContactsRefs = docs.map((doc) => doc.reference).toList();
          _cachedBlockedContacts = blockedContactsRefs;
          _lastBlockedContactsUpdate = DateTime.now();
        });

        print('⚠️ Contacts bloqués chargés sans index (tri manuel, max 50)');
      } catch (e2) {
        print('❌ Erreur critique chargement contacts bloqués: $e2');
        _showErrorSnackBar('Impossible de charger les contacts bloqués');
      }
    }
  }

  // ✅ CORRECTION : Validation et gestion d'erreurs améliorée
  Future<void> _loadAvailableMatches() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_matches')
          .doc(widget.currentUserId)
          .collection('matches')
          .where('isActive', isEqualTo: true)
          .orderBy('matchedAt', descending: true)
          .get();

      final List<Map<String, dynamic>> matches = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final matchedUserId = data['userId'] as String?;

        // ✅ Validation
        if (matchedUserId == null || matchedUserId.isEmpty) {
          print('⚠️ Match sans userId: ${doc.id}');
          continue;
        }

        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(matchedUserId)
              .get();

          if (!userDoc.exists) {
            print('⚠️ Utilisateur introuvable: $matchedUserId');
            continue;
          }

          final userData = userDoc.data() as Map<String, dynamic>?;

          matches.add({
            'id': doc.id,
            'matchId': data['matchId'] ?? '',
            'userId': matchedUserId,
            'userName':
                data['userName'] ?? userData?['display_name'] ?? 'Utilisateur',
            'userPhotoUrl':
                data['userPhotoUrl'] ?? userData?['photo_url'] ?? '',
            'userAge': userData?['age'] ?? 25,
            'matchedAt': data['matchedAt'],
            'isActive': data['isActive'] ?? true,
          });
        } catch (e) {
          print('❌ Erreur chargement user $matchedUserId: $e');
        }
      }

      setState(() {
        availableMatchesData = matches;
      });

      print('✅ ${matches.length} matches actifs chargés');
    } catch (e) {
      print('❌ Erreur chargement matches: $e');
    }
  }

  // ✅ NOUVELLE MÉTHODE : Charge les détails des contacts bloqués
  Future<List<Map<String, dynamic>>> _loadBlockedContactsDetails() async {
    List<Map<String, dynamic>> contacts = [];

    for (var ref in blockedContactsRefs) {
      try {
        final doc = await ref.get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          data['ref'] = ref; // Garde la référence pour le déblocage
          contacts.add(data);
        }
      } catch (e) {
        print('❌ Erreur chargement contact bloqué: $e');
      }
    }

    return contacts;
  }

  String _formatTimestamp(dynamic date) {
    if (date == null) return 'Date inconnue';

    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate();
    } else if (date is DateTime) {
      dt = date;
    } else {
      return 'Date inconnue';
    }

    return '${dt.day.toString().padLeft(2, '0')} ${_getMonthName(dt.month)} ${dt.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return months[month - 1];
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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

  Future<void> toggleInvisibleMode(bool value) async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({'invisible_mode': value});

      setState(() {
        isInvisibleMode = value;
        isLoading = false;
      });

      _showSuccessSnackBar(
          value ? 'Mode invisible activé 👻' : 'Mode invisible désactivé');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du changement de mode');
      print('❌ Erreur toggle invisible: $e');
    }
  }

  // ✅ OPTIMISATION : Ajout de timestamps et validation
  Future<void> blockContact(String matchDocId, String matchId, String userId,
      String userName, String userPhotoUrl, String reason) async {
    // ✅ Validation des paramètres
    if (userId.isEmpty || matchDocId.isEmpty) {
      _showErrorSnackBar('Données invalides pour le blocage');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final batch = FirebaseFirestore.instance.batch();

      // 1. Crée le document de blocage
      final blockedRef =
          FirebaseFirestore.instance.collection('blocked_contacts').doc();

      batch.set(blockedRef, {
        'blocker_id': widget.currentUserId,
        'blocked_user_id': userId,
        'blocked_user_name': userName,
        'blocked_user_avatar': userPhotoUrl,
        'blocked_date': FieldValue.serverTimestamp(),
        'reason': reason,
        'match_id': matchId,
      });

      // 2. Désactive le match pour l'utilisateur 1
      final user1MatchRef = FirebaseFirestore.instance
          .collection('user_matches')
          .doc(widget.currentUserId)
          .collection('matches')
          .doc(matchDocId);

      batch.update(user1MatchRef, {
        'isActive': false,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      // 3. Désactive le match pour l'utilisateur 2
      final user2MatchRef = FirebaseFirestore.instance
          .collection('user_matches')
          .doc(userId)
          .collection('matches')
          .doc(widget.currentUserId);

      batch.update(user2MatchRef, {
        'isActive': false,
        'blockedBy': widget.currentUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      // 4. Désactive le match principal
      if (matchId.isNotEmpty) {
        final mainMatchRef =
            FirebaseFirestore.instance.collection('matches').doc(matchId);

        batch.update(mainMatchRef, {
          'isActive': false,
          'blockedAt': FieldValue.serverTimestamp(),
          'blockedBy': widget.currentUserId,
        });
      }

      await batch.commit();

      // Recharge les données
      await Future.wait([
        _loadBlockedContacts(),
        _loadAvailableMatches(),
      ]);

      setState(() {
        isLoading = false;
        selectedSection = 'blocked';
      });

      _showSuccessSnackBar('$userName a été bloqué(e)');
      print('✅ Match bloqué: $userName ($userId)');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du blocage: ${e.toString()}');
      print('❌ Erreur blocage: $e');
    }
  }

  // ✅ OPTIMISATION : Avec confirmation et validation
  Future<void> unblockContact(DocumentReference blockedRef) async {
    try {
      final blockedDoc = await blockedRef.get();

      if (!blockedDoc.exists) {
        _showErrorSnackBar('Contact bloqué introuvable');
        return;
      }

      final blockedData = blockedDoc.data() as Map<String, dynamic>?;

      if (blockedData == null) {
        _showErrorSnackBar('Données invalides');
        return;
      }

      final blockedName = blockedData['blocked_user_name'] ?? 'Utilisateur';
      final blockedUserId = blockedData['blocked_user_id'] as String?;
      final matchId = blockedData['match_id'] as String?;

      if (blockedUserId == null || blockedUserId.isEmpty) {
        _showErrorSnackBar('ID utilisateur invalide');
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Débloquer $blockedName ?',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Cette personne pourra à nouveau vous voir et vous contacter.',
              style: TextStyle(color: textSecondaryColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annuler',
                    style: TextStyle(color: textSecondaryColor)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Débloquer'),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      setState(() {
        isLoading = true;
      });

      final batch = FirebaseFirestore.instance.batch();

      // Supprime le document de blocage
      batch.delete(blockedRef);

      // Réactive le match pour l'utilisateur 1
      final user1MatchRef = FirebaseFirestore.instance
          .collection('user_matches')
          .doc(widget.currentUserId)
          .collection('matches')
          .doc(blockedUserId);

      batch.update(user1MatchRef, {
        'isActive': true,
        'unblockedAt': FieldValue.serverTimestamp(),
      });

      // Réactive le match pour l'utilisateur 2
      final user2MatchRef = FirebaseFirestore.instance
          .collection('user_matches')
          .doc(blockedUserId)
          .collection('matches')
          .doc(widget.currentUserId);

      batch.update(user2MatchRef, {
        'isActive': true,
        'unblockedAt': FieldValue.serverTimestamp(),
      });

      // Réactive le match principal
      if (matchId != null && matchId.isNotEmpty) {
        final mainMatchRef =
            FirebaseFirestore.instance.collection('matches').doc(matchId);

        batch.update(mainMatchRef, {
          'isActive': true,
          'unblockedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      await Future.wait([
        _loadBlockedContacts(),
        _loadAvailableMatches(),
      ]);

      setState(() {
        isLoading = false;
      });

      _showSuccessSnackBar('$blockedName a été débloqué(e)');
      print('✅ Match débloqué: $blockedName ($blockedUserId)');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du déblocage: ${e.toString()}');
      print('❌ Erreur déblocage: $e');
    }
  }

  // ✅ OPTIMISATION : Validation complète
  Future<void> submitReport() async {
    if (selectedMatchToReport == null || selectedReportType == null) {
      _showErrorSnackBar(
          'Veuillez sélectionner un match et un type de signalement');
      return;
    }

    if (reportDetailsController.text.trim().isEmpty) {
      _showErrorSnackBar('Veuillez ajouter des détails à votre signalement');
      return;
    }

    if (reportDetailsController.text.trim().length < 10) {
      _showErrorSnackBar(
          'Veuillez fournir plus de détails (minimum 10 caractères)');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final match = availableMatchesData.firstWhere(
        (m) => m['id'] == selectedMatchToReport,
        orElse: () => {},
      );

      if (match.isEmpty) {
        throw Exception('Match introuvable');
      }

      await FirebaseFirestore.instance.collection('reports').add({
        'reporter_id': widget.currentUserId,
        'reported_user_id': match['userId'],
        'reported_user_name': match['userName'],
        'report_type': selectedReportType,
        'details': reportDetailsController.text.trim(),
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'match_id': match['matchId'],
      });

      setState(() {
        isLoading = false;
        selectedSection = 'main';
        selectedMatchToReport = null;
        selectedReportType = null;
        reportDetailsController.clear();
      });

      _showSuccessSnackBar('Signalement envoyé. Notre équipe va l\'examiner.');
      print('✅ Signalement envoyé pour: ${match['userName']}');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Erreur lors de l\'envoi: ${e.toString()}');
      print('❌ Erreur signalement: $e');
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
      child: errorMessage != null
          ? buildErrorState()
          : isLoading && selectedSection == 'main'
              ? buildLoadingState()
              : buildContent(),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: tertiaryColor),
          SizedBox(height: 16),
          Text('Erreur de chargement',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(errorMessage!,
                style: TextStyle(color: textSecondaryColor, fontSize: 14),
                textAlign: TextAlign.center),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeData,
            icon: Icon(Icons.refresh),
            label: Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 16),
          Text('Chargement...', style: TextStyle(color: textSecondaryColor)),
        ],
      ),
    );
  }

  Widget buildContent() {
    if (selectedSection == 'blocked') {
      return buildBlockedContactsList();
    } else if (selectedSection == 'report') {
      return buildReportSection();
    } else if (selectedSection == 'selectMatch') {
      return buildSelectMatchToBlock();
    } else if (selectedSection == 'selectMatchToReport') {
      return buildSelectMatchToReport();
    }
    return buildMainInterface();
  }

  Widget buildMainInterface() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: _ResponsiveHelper.value(context,
                  mobile: 64, tablet: 72, desktop: 80),
              height: _ResponsiveHelper.value(context,
                  mobile: 64, tablet: 72, desktop: 80),
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
              child: Icon(Icons.security, size: 32, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confidentialité & Sécurité',
                      style: TextStyle(
                          fontSize: _ResponsiveHelper.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  Text('Gérez vos paramètres de sécurité',
                      style: TextStyle(
                        fontSize: _ResponsiveHelper.fontSize(context, 14),
                        color: textSecondaryColor,
                      )),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 32),
        buildFeatureCard(
          icon: isInvisibleMode ? Icons.visibility_off : Icons.visibility,
          iconColor: isInvisibleMode ? secondaryColor : textSecondaryColor,
          title: 'Mode invisible 👻',
          subtitle: isInvisibleMode
              ? 'Activé - Vous êtes invisible'
              : 'Désactivé - Vous êtes visible',
          hasSwitch: true,
          switchValue: isInvisibleMode,
          backgroundColor: isInvisibleMode
              ? secondaryColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.9),
        ),
        SizedBox(height: 16),
        buildFeatureCard(
          icon: Icons.block,
          iconColor: tertiaryColor,
          title: 'Matches bloqués',
          subtitle: '${blockedContactsRefs.length} match(s) bloqué(s)',
          hasArrow: true,
          onTap: () => setState(() => selectedSection = 'blocked'),
          backgroundColor: Colors.white.withOpacity(0.9),
        ),
        SizedBox(height: 16),
        buildFeatureCard(
          icon: Icons.report_problem,
          iconColor: Color(0xFFFF9800),
          title: 'Signalement & Assistance',
          subtitle: 'Signaler un match ou demander de l\'aide',
          hasArrow: true,
          onTap: () => setState(() => selectedSection = 'report'),
          backgroundColor: Colors.white.withOpacity(0.9),
        ),
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: secondaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: secondaryColor, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text('Votre compte est sécurisé',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ OPTIMISATION : StreamBuilder avec gestion d'erreur d'index
  Widget buildBlockedContactsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => selectedSection = 'main'),
              icon: Icon(Icons.arrow_back, color: textColor),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: CircleBorder(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Matches bloqués',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  Text('${blockedContactsRefs.length} match(s)',
                      style:
                          TextStyle(fontSize: 14, color: textSecondaryColor)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),

        // ✅ UTILISER FutureBuilder AU LIEU DE StreamBuilder
        if (blockedContactsRefs.isEmpty) ...[
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.block, size: 48, color: textSecondaryColor),
                SizedBox(height: 16),
                Text('Aucun match bloqué',
                    style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('Vous n\'avez bloqué aucun de vos matches.',
                    style: TextStyle(fontSize: 14, color: textSecondaryColor),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ] else ...[
          Container(
            constraints: BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadBlockedContactsDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: tertiaryColor),
                          SizedBox(height: 8),
                          Text('Erreur de chargement',
                              style: TextStyle(color: textColor)),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {}),
                            child: Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Aucun contact bloqué',
                          style: TextStyle(color: textSecondaryColor)),
                    ),
                  );
                }

                final blockedContacts = snapshot.data!;

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: blockedContacts.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = blockedContacts[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tertiaryColor,
                        child: Text(
                          (contact['blocked_user_name'] ?? 'U')
                              .toString()
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(contact['blocked_user_name'] ?? 'Utilisateur',
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Bloqué: ${_formatTimestamp(contact['blocked_date'])}',
                              style: TextStyle(
                                  color: textSecondaryColor, fontSize: 12)),
                          Text(contact['reason'] ?? 'Non spécifié',
                              style: TextStyle(color: textColor, fontSize: 12)),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () => unblockContact(contact['ref']),
                        style: TextButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Débloquer'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: availableMatchesData.isEmpty
                ? null
                : () => setState(() => selectedSection = 'selectMatch'),
            icon: Icon(Icons.add_circle_outline, size: 20),
            label: Text('Bloquer un match',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  availableMatchesData.isEmpty ? Colors.grey : tertiaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSelectMatchToBlock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => selectedSection = 'blocked'),
              icon: Icon(Icons.arrow_back, color: textColor),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: CircleBorder(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bloquer un match',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  Text('Sélectionnez le match à bloquer',
                      style:
                          TextStyle(fontSize: 14, color: textSecondaryColor)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        if (availableMatchesData.isEmpty) ...[
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.favorite_outline,
                    size: 48, color: textSecondaryColor),
                SizedBox(height: 16),
                Text('Aucun match disponible',
                    style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('Tous vos matches ont déjà été bloqués.',
                    style: TextStyle(fontSize: 14, color: textSecondaryColor),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ] else ...[
          Container(
            constraints: BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: availableMatchesData.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final match = availableMatchesData[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor,
                    backgroundImage: match['userPhotoUrl'] != null &&
                            match['userPhotoUrl'].toString().isNotEmpty
                        ? NetworkImage(match['userPhotoUrl'])
                        : null,
                    child: match['userPhotoUrl'] == null ||
                            match['userPhotoUrl'].toString().isEmpty
                        ? Text(
                            (match['userName'] ?? 'U')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                  title: Text('${match['userName']} (${match['userAge']} ans)',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      'Match: ${_formatTimestamp(match['matchedAt'])}',
                      style:
                          TextStyle(color: textSecondaryColor, fontSize: 12)),
                  trailing: TextButton(
                    onPressed: () => _showBlockDialog(match),
                    style: TextButton.styleFrom(
                      backgroundColor: tertiaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Bloquer'),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget buildSelectMatchToReport() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => selectedSection = 'report'),
              icon: Icon(Icons.arrow_back, color: textColor),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: CircleBorder(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sélectionner un match',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  Text('Choisissez le match à signaler',
                      style:
                          TextStyle(fontSize: 14, color: textSecondaryColor)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        Container(
          constraints: BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: availableMatchesData.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final match = availableMatchesData[index];
              final isSelected = selectedMatchToReport == match['id'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isSelected ? primaryColor : textSecondaryColor,
                  backgroundImage: match['userPhotoUrl'] != null &&
                          match['userPhotoUrl'].toString().isNotEmpty
                      ? NetworkImage(match['userPhotoUrl'])
                      : null,
                  child: match['userPhotoUrl'] == null ||
                          match['userPhotoUrl'].toString().isEmpty
                      ? Text(
                          (match['userName'] ?? 'U')
                              .toString()
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))
                      : null,
                ),
                title: Text('${match['userName']} (${match['userAge']} ans)',
                    style: TextStyle(
                        color: textColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600)),
                subtitle: Text('Match: ${_formatTimestamp(match['matchedAt'])}',
                    style: TextStyle(color: textSecondaryColor, fontSize: 12)),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: primaryColor, size: 20)
                    : null,
                tileColor: isSelected ? primaryColor.withOpacity(0.1) : null,
                onTap: () {
                  setState(() {
                    selectedMatchToReport = match['id'];
                    selectedSection = 'report';
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildReportSection() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => selectedSection = 'main'),
                icon: Icon(Icons.arrow_back, color: textColor),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  shape: CircleBorder(),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Signalement',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    Text('Aidez-nous à maintenir une communauté sûre',
                        style:
                            TextStyle(fontSize: 12, color: textSecondaryColor)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selectedMatchToReport != null
                  ? primaryColor.withOpacity(0.1)
                  : Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedMatchToReport != null
                    ? primaryColor
                    : Color(0xFFE0E0E0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Sélectionner le match',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: textColor)),
                SizedBox(height: 8),
                selectedMatchToReport == null
                    ? TextButton(
                        onPressed: () => setState(
                            () => selectedSection = 'selectMatchToReport'),
                        style: TextButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Choisir un match'),
                      )
                    : Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primaryColor,
                            radius: 16,
                            child: Text('M',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ),
                          SizedBox(width: 12),
                          Text('Match sélectionné',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600)),
                          Spacer(),
                          TextButton(
                            onPressed: () => setState(
                                () => selectedSection = 'selectMatchToReport'),
                            child: Text('Changer',
                                style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2. Type de signalement',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: textColor)),
                SizedBox(height: 16),
                buildReportOption(
                  value: 'inappropriate',
                  title: 'Comportement inapproprié',
                  subtitle: 'Harcèlement, menaces',
                  enabled: selectedMatchToReport != null,
                ),
                SizedBox(height: 8),
                buildReportOption(
                  value: 'spam',
                  title: 'Spam ou arnaque',
                  subtitle: 'Messages indésirables',
                  enabled: selectedMatchToReport != null,
                ),
                SizedBox(height: 8),
                buildReportOption(
                  value: 'fake',
                  title: 'Profil faux',
                  subtitle: 'Usurpation d\'identité',
                  enabled: selectedMatchToReport != null,
                ),
                SizedBox(height: 8),
                buildReportOption(
                  value: 'offensive',
                  title: 'Contenu offensant',
                  subtitle: 'Photos ou messages offensants',
                  enabled: selectedMatchToReport != null,
                ),
                SizedBox(height: 16),
                Text('3. Détails (requis)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: textColor)),
                SizedBox(height: 8),
                TextField(
                  controller: reportDetailsController,
                  enabled: selectedMatchToReport != null &&
                      selectedReportType != null,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText:
                        'Décrivez la situation en détail (minimum 10 caractères)...',
                    hintStyle: TextStyle(color: textSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: textSecondaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: textSecondaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: textColor),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (selectedMatchToReport == null ||
                            selectedReportType == null ||
                            isLoading ||
                            reportDetailsController.text.trim().isEmpty)
                        ? null
                        : () => submitReport(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (selectedMatchToReport != null &&
                              selectedReportType != null &&
                              reportDetailsController.text.trim().isNotEmpty)
                          ? primaryColor
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Envoyer le signalement',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: secondaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.mail_outline, color: secondaryColor, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Besoin d\'aide ?',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: textColor)),
                      Text('support@kwanza-lova.com',
                          style: TextStyle(
                              color: textSecondaryColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    bool hasSwitch = false,
    bool switchValue = false,
    bool hasArrow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                hasSwitch && switchValue ? secondaryColor : Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: textColor)),
                  SizedBox(height: 4),
                  Text(subtitle,
                      style:
                          TextStyle(color: textSecondaryColor, fontSize: 14)),
                ],
              ),
            ),
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: isLoading ? null : toggleInvisibleMode,
                activeColor: secondaryColor,
              ),
            if (hasArrow)
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: textSecondaryColor),
          ],
        ),
      ),
    );
  }

  Widget buildReportOption({
    required String value,
    required String title,
    required String subtitle,
    bool enabled = true,
  }) {
    final isSelected = selectedReportType == value;

    return GestureDetector(
      onTap: enabled
          ? () {
              setState(() {
                selectedReportType = value;
              });
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: enabled ? textColor : textSecondaryColor)),
                    Text(subtitle,
                        style: TextStyle(
                            color: enabled
                                ? textSecondaryColor
                                : textSecondaryColor.withOpacity(0.6),
                            fontSize: 12)),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? primaryColor : textSecondaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedReason = 'Comportement inapproprié';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Bloquer ${match['userName']} ?',
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Cette personne ne pourra plus vous voir ni vous contacter.',
                      style: TextStyle(color: textSecondaryColor)),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    decoration: InputDecoration(
                      labelText: 'Raison',
                      labelStyle: TextStyle(color: textSecondaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    items: [
                      'Comportement inapproprié',
                      'Spam de messages',
                      'Contenu offensant',
                      'Harcèlement',
                      'Profil faux',
                      'Autre'
                    ].map((String reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason, style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedReason = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler',
                      style: TextStyle(color: textSecondaryColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    blockContact(
                      match['id'],
                      match['matchId'] ?? '',
                      match['userId'],
                      match['userName'],
                      match['userPhotoUrl'] ?? '',
                      selectedReason,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tertiaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Bloquer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

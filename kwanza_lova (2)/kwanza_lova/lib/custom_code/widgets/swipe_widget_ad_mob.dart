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

import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import '/custom_code/actions/firestore_listener_manager_global.dart';

// ✅ CLASSE RESPONSIVE INTÉGRÉE
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

  static EdgeInsets padding(BuildContext context, {double base = 16}) {
    final multiplier =
        isDesktop(context) ? 2.0 : (isTablet(context) ? 1.5 : 1.0);
    return EdgeInsets.all(base * multiplier);
  }

  static double fontSize(BuildContext context, double base) {
    if (isDesktop(context)) return base * 1.2;
    if (isTablet(context)) return base * 1.1;
    return base;
  }
}

// Instance globale
final _listenerManager = FirestoreListenerManagerGlobal();

// Fonction safe update
void _safeUpdateFFAppState(Function() updates) {
  try {
    FFAppState().update(updates);
  } catch (e) {
    print('⚠️ FFAppState non disponible: $e');
  }
}

class SwipeWidgetAdMob extends StatefulWidget {
  const SwipeWidgetAdMob({
    Key? key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.profiles,
    required this.currentUserGender,
    required this.currentUserInterestedIn,
    this.swipedProfiles = const [],
    this.likedProfiles = const [],
    this.passedProfiles = const [],
    this.enableNotifications = true,
    this.currentUserName = '',
    this.currentUserPhotoUrl = '',
    this.showNotificationButton = true,
    this.autoMarkAsRead = true,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String currentUserId;
  final List<UsersRecord> profiles;
  final String currentUserGender;
  final String currentUserInterestedIn;
  final List<String> swipedProfiles;
  final List<String> likedProfiles;
  final List<String> passedProfiles;
  final bool enableNotifications;
  final String currentUserName;
  final String currentUserPhotoUrl;
  final bool showNotificationButton;
  final bool autoMarkAsRead;

  @override
  State<SwipeWidgetAdMob> createState() => _SwipeWidgetAdMobState();
}

class _SwipeWidgetAdMobState extends State<SwipeWidgetAdMob>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  List<Map<String, dynamic>> filteredProfiles = [];
  bool _isUserAuthenticated = false;
  String _effectiveUserId = '';
  late AnimationController _cardController;
  late AnimationController _superLikeController;
  late AnimationController _notificationController;
  late Animation<Offset> _cardAnimation;
  late Animation<double> _superLikeAnimation;
  late Animation<double> _notificationAnimation;
  int _pendingLikesCount = 0;
  bool _isLoadingNotifications = false;
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  static const String _adMobInterstitialIdAndroid =
      'ca-app-pub-6278778629682650/7835470050';
  static const String _adMobInterstitialIdIOS =
      'ca-app-pub-6278778629682650/9096580831';
  static const String _adMobRewardedIdAndroid =
      'ca-app-pub-6278778629682650/8413667516';
  static const String _adMobRewardedIdIOS =
      'ca-app-pub-6278778629682650/2666516817';
  static const String _testInterstitialIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIdIOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIdIOS =
      'ca-app-pub-3940256099942544/1712485313';
  static const bool _useTestAds = true;

  bool _isShowingAd = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;
  final Map<String, dynamic> _profileCache = {};
  Timer? _debounceTimer;
  bool _isProcessingSwipe = false;

  int _randomInt(int max) => math.Random().nextInt(max);

  bool get _isAndroid {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  bool get _isIOS {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _initializeWidget();
  }

  void _initializeWidget() {
    print('╔═══════════════════════════════════════╗');
    print('║  SWIPE WIDGET - VERSION RESPONSIVE    ║');
    print('╚═══════════════════════════════════════╝');

    _effectiveUserId = widget.currentUserId.isNotEmpty
        ? widget.currentUserId
        : (currentUserUid ?? '');
    if (_effectiveUserId.isEmpty) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) _effectiveUserId = firebaseUser.uid;
    }

    _isUserAuthenticated = _effectiveUserId.isNotEmpty;

    // ✅ AJOUT DEBUG
    print('🔐 Debug Authentification:');
    print('   widget.currentUserId: ${widget.currentUserId}');
    print('   currentUserUid: $currentUserUid');
    print(
        '   FirebaseAuth.currentUser?.uid: ${FirebaseAuth.instance.currentUser?.uid}');
    print('   _effectiveUserId: $_effectiveUserId');
    print('   _isUserAuthenticated: $_isUserAuthenticated');

    print(
        '🎯 État: ${_isUserAuthenticated ? "AUTHENTIFIÉ ✅" : "NON AUTHENTIFIÉ ❌"}');

    _setupOptimizedAnimations();
    _initializeAdMob();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await _filterProfilesMethod();
        if (filteredProfiles.isNotEmpty) setState(() {});
      }
    });

    if (widget.enableNotifications && _isUserAuthenticated) {
      _initializeNotificationSystem();
    }

    print('✅ Initialisation terminée');
  }

  void _setupOptimizedAnimations() {
    try {
      _cardController = AnimationController(
          duration: const Duration(milliseconds: 300), vsync: this);
      _cardAnimation =
          Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0))
              .animate(CurvedAnimation(
                  parent: _cardController, curve: Curves.easeOutCubic));

      _superLikeController = AnimationController(
          duration: const Duration(milliseconds: 600), vsync: this);
      _superLikeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: _superLikeController, curve: Curves.easeOutBack));

      _notificationController = AnimationController(
          duration: const Duration(milliseconds: 400), vsync: this);
      _notificationAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
          CurvedAnimation(
              parent: _notificationController, curve: Curves.easeInOut));

      print('🎬 Animations configurées');
    } catch (e) {
      print('❌ Erreur animations: $e');
    }
  }

  String _getAdUnitId(String adType) {
    if (_useTestAds) {
      if (adType == 'interstitial') {
        return _isAndroid ? _testInterstitialIdAndroid : _testInterstitialIdIOS;
      } else if (adType == 'rewarded') {
        return _isAndroid ? _testRewardedIdAndroid : _testRewardedIdIOS;
      }
    }

    if (adType == 'interstitial') {
      return _isAndroid ? _adMobInterstitialIdAndroid : _adMobInterstitialIdIOS;
    } else if (adType == 'rewarded') {
      return _isAndroid ? _adMobRewardedIdAndroid : _adMobRewardedIdIOS;
    }

    return '';
  }

  void _initializeAdMob() {
    print('📢 INITIALISATION ADMOB');
    if (kIsWeb) {
      print('⚠️ AdMob non disponible sur Web');
      return;
    }
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadInterstitialAd() {
    final adUnitId = _getAdUnitId('interstitial');
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('💰 Interstitial fermé - Enregistrement revenu');
              _logAdRevenueToFirestore(adType: 'interstitial', revenue: 0.02);
              ad.dispose();
              _isInterstitialAdReady = false;
              if (mounted) setState(() => _isShowingAd = false);
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              if (mounted) setState(() => _isShowingAd = false);
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted && !_isInterstitialAdReady) _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _loadRewardedAd() {
    final adUnitId = _getAdUnitId('rewarded');
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('💰 Rewarded fermé - Enregistrement revenu');
              _logAdRevenueToFirestore(adType: 'rewarded', revenue: 0.05);
              ad.dispose();
              _isRewardedAdReady = false;
              if (mounted) setState(() => _isShowingAd = false);
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              if (mounted) setState(() => _isShowingAd = false);
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted && !_isRewardedAdReady) _loadRewardedAd();
          });
        },
      ),
    );
  }

  Future<void> _logAdRevenueToFirestore({
    required String adType,
    required double revenue,
  }) async {
    try {
      if (!_isUserAuthenticated || _effectiveUserId.isEmpty) {
        print('⚠️ Auth pas prête, skip logging pour $adType');
        return;
      }

      String platform = 'unknown';
      if (!kIsWeb) {
        if (_isAndroid) {
          platform = 'android';
        } else if (_isIOS) {
          platform = 'ios';
        }
      }

      print(
          '💰 Log revenu: $_effectiveUserId | $adType | $revenue\$ | $platform');

      await FirebaseFirestore.instance.collection('ad_revenue_logs').add({
        'userId': _effectiveUserId,
        'adType': adType,
        'revenue': revenue,
        'platform': platform,
        'timestamp': FieldValue.serverTimestamp(),
        'processed': false,
      }).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ Timeout logging revenu - ignoré');
          throw TimeoutException('Timeout lors de l\'enregistrement du revenu');
        },
      );

      print('✅ Revenu enregistré');
    } on TimeoutException catch (e) {
      print('⏱️ Timeout revenu (ignoré): $e');
    } catch (e) {
      print('❌ Erreur log revenu (ignorée): $e');
    }
  }

  Future<void> _initializeNotificationSystem() async {
    try {
      await _loadPendingLikes();
      _setupNotificationListener();
      _updateFFAppStateNotifications();
    } catch (e) {
      print('❌ Erreur notifications: $e');
    }
  }

  Future<void> _loadPendingLikes() async {
    if (!widget.enableNotifications || !_isUserAuthenticated) return;
    try {
      setState(() => _isLoadingNotifications = true);
      final likesReceived = await FirebaseFirestore.instance
          .collection('likes_received')
          .where('receiverId', isEqualTo: _effectiveUserId)
          .where('isNotified', isEqualTo: false)
          .where('isMatched', isEqualTo: false)
          .get();
      if (mounted) {
        setState(() {
          _pendingLikesCount = likesReceived.docs.length;
          _isLoadingNotifications = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement likes: $e');
      if (mounted) setState(() => _isLoadingNotifications = false);
    }
  }

  void _setupNotificationListener() {
    if (!widget.enableNotifications || !_isUserAuthenticated) return;

    try {
      // ✅ CORRECTION CRITIQUE : Annuler l'ancien listener avant d'en créer un nouveau
      _notificationSubscription?.cancel();

      final subscription = FirebaseFirestore.instance
          .collection('likes_received')
          .where('receiverId', isEqualTo: _effectiveUserId)
          .where('isNotified', isEqualTo: false)
          .where('isMatched', isEqualTo: false)
          .limit(50)
          .snapshots()
          .listen(
        (snapshot) {
          if (!mounted) return;
          final newCount = snapshot.docs.length;
          if (newCount > _pendingLikesCount && _pendingLikesCount > 0) {
            _animateNewNotification();
          }
          setState(() => _pendingLikesCount = newCount);
          _updateFFAppStateNotifications();
        },
        onError: (error) {
          print('❌ Erreur listener notifications: $error');
        },
        cancelOnError: false,
      );

      _notificationSubscription = subscription;

      final key = 'swipe_notifications_$_effectiveUserId';
      _listenerManager.addListener(key, subscription);

      print('✅ Listener notifications enregistré: $key');
    } catch (e) {
      print('❌ Erreur setup listener: $e');
    }
  }

  void _updateFFAppStateNotifications() {
    _safeUpdateFFAppState(() {
      FFAppState().lastSwipeAction = 'notification_update_$_pendingLikesCount';
    });
  }

  void _animateNewNotification() {
    if (!mounted) return;
    _notificationController.forward().then((_) {
      if (mounted) _notificationController.reverse();
    });
  }

  Future<void> _filterProfilesMethod() async {
    try {
      print('🔍 DÉBUT FILTRAGE DES PROFILS');
      if (widget.profiles.isEmpty) {
        print('⚠️ widget.profiles est VIDE!');
        filteredProfiles = [];
        return;
      }

      final List<Map<String, dynamic>> allProfiles = [];
      for (var i = 0; i < widget.profiles.length; i++) {
        try {
          final userRecord = widget.profiles[i];
          final docSnapshot = await userRecord.reference.get();
          final docData = docSnapshot.data() as Map<String, dynamic>? ?? {};
          final displayNameValue = docData['display_name']?.toString() ??
              docData['displayName']?.toString() ??
              '';

          final Map<String, dynamic> profile = {
            'id': userRecord.reference.id,
            'uid': userRecord.reference.id,
            'display_name': displayNameValue,
            'displayName': displayNameValue,
            'name': displayNameValue,
            'photo_url': userRecord.photoUrl ?? '',
            'photoUrl': userRecord.photoUrl ?? '',
            'imageUrl': userRecord.photoUrl ?? '',
            'age': userRecord.age ?? 0,
            'bio': userRecord.bio ?? '',
            'gender': userRecord.gender ?? '',
            'location': userRecord.location ?? '',
            'city': userRecord.location ?? '',
          };
          allProfiles.add(profile);
        } catch (e) {
          print('   ❌ Erreur conversion profil ${i + 1}: $e');
        }
      }

      filteredProfiles = allProfiles.where((profile) {
        final profileId = profile['id']?.toString() ?? '';
        final profileGender = profile['gender']?.toString() ?? '';

        if (profileId == _effectiveUserId) return false;
        if (widget.swipedProfiles.contains(profileId)) return false;
        if (widget.likedProfiles.contains(profileId)) return false;
        if (widget.passedProfiles.contains(profileId)) return false;

        if (widget.currentUserInterestedIn.isNotEmpty &&
            widget.currentUserInterestedIn != 'all' &&
            widget.currentUserInterestedIn != 'tous') {
          if (profileGender.isNotEmpty &&
              profileGender.toLowerCase() !=
                  widget.currentUserInterestedIn.toLowerCase()) {
            return false;
          }
        }

        return true;
      }).toList();

      filteredProfiles.shuffle(math.Random());
      print('✅ PROFILS DISPONIBLES: ${filteredProfiles.length}');
    } catch (e, stackTrace) {
      print('❌ ERREUR FILTRAGE: $e');
      print('Stack: $stackTrace');
      filteredProfiles = [];
    }
  }

  Future<void> _handleSwipe(String action) async {
    print('🎯 SWIPE: $action');
    if (_isProcessingSwipe) {
      print('⏳ Swipe en cours, ignoré');
      return;
    }
    if (currentIndex >= filteredProfiles.length) {
      print('⚠️ Pas de profil disponible');
      return;
    }

    _isProcessingSwipe = true;
    final profile = filteredProfiles[currentIndex];
    final profileId =
        profile['id']?.toString() ?? profile['uid']?.toString() ?? '';

    try {
      if (action == 'superlike') {
        await _animateSuperLike();
      } else {
        await _animateSwipe();
      }

      if (action == 'like' || action == 'superlike') {
        await _handleLikeWithNotification(profileId, profile, action);
      } else {
        _handleSwipeAction(profileId, action);
      }

      if (mounted) {
        setState(() {
          currentIndex++;
        });
      }

      if (currentIndex % 5 == 0 && currentIndex > 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        _showFullScreenAd();
      }

      print('✅ Swipe traité');
    } catch (e) {
      print('❌ Erreur swipe: $e');
    } finally {
      _isProcessingSwipe = false;
    }
  }

  Future<void> _animateSwipe() async {
    if (!mounted) return;
    await _cardController.forward();
    if (mounted) _cardController.reset();
  }

  Future<void> _animateSuperLike() async {
    if (!mounted) return;
    await _superLikeController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _superLikeController.reset();
  }

  Future<void> _handleLikeWithNotification(
      String profileId, Map<String, dynamic> profile, String swipeType) async {
    if (!widget.enableNotifications) {
      _handleSwipeAction(profileId, swipeType);
      return;
    }
    if (_effectiveUserId.isEmpty || profileId.isEmpty) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ Utilisateur non authentifié - Abandon');
        _handleSwipeAction(profileId, swipeType);
        return;
      }

      print('✅ Utilisateur authentifié: ${currentUser.uid}');

      final timestamp = FieldValue.serverTimestamp();
      final currentUserName = widget.currentUserName.isNotEmpty
          ? widget.currentUserName
          : 'Utilisateur';

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 🔍 ÉTAPE 0 : Vérifier si like déjà existant (ANTI-DUPLICATION)
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      print('📝 ÉTAPE 0 : Vérification like déjà existant...');

      try {
        final existingOwnLike = await FirebaseFirestore.instance
            .collection('likes_given')
            .where('giverId', isEqualTo: _effectiveUserId)
            .where('receiverId', isEqualTo: profileId)
            .limit(1)
            .get();

        if (existingOwnLike.docs.isNotEmpty) {
          print('⚠️ Like déjà existant, abandon');

          if (mounted) {
            final profileName =
                profile['display_name'] ?? profile['name'] ?? 'cette personne';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vous avez déjà liké $profileName',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pas besoin de liker plusieurs fois le même profil. Si $profileName vous like aussi, vous serez notifié et pourrez discuter ensemble !',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFF6F61EF), // Violet primaire
                duration: Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            );
          }

          // Passer au profil suivant sans créer de like
          _handleSwipeAction(profileId, swipeType);
          return;
        }

        print('✅ ÉTAPE 0 : Aucun like existant, on continue');
      } catch (e) {
        print('⚠️ ÉTAPE 0 : Erreur vérification, on continue quand même: $e');
      }

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 🔍 ÉTAPE 1 : Créer likes_given
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      print('📝 ÉTAPE 1 : Tentative création likes_given...');

      try {
        final likeGivenRef =
            FirebaseFirestore.instance.collection('likes_given').doc();

        await likeGivenRef.set({
          'giverId': _effectiveUserId,
          'receiverId': profileId,
          'giverName': currentUserName,
          'giverPhotoUrl': widget.currentUserPhotoUrl,
          'likeType': swipeType,
          'timestamp': timestamp,
          'isMatched': false,
          'createdAt': timestamp,
        });

        print('✅ ÉTAPE 1 RÉUSSIE : likes_given créé: ${likeGivenRef.id}');
      } catch (e) {
        print('❌ ÉTAPE 1 ÉCHOUÉE : likes_given - $e');
        rethrow;
      }

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 🔍 ÉTAPE 2 : Vérifier match existant
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      print('📝 ÉTAPE 2 : Vérification match existant...');

      bool isMatch = false;
      try {
        final existingLikeSnapshot = await FirebaseFirestore.instance
            .collection('likes_given')
            .where('giverId', isEqualTo: profileId)
            .where('receiverId', isEqualTo: _effectiveUserId)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 5));

        isMatch = existingLikeSnapshot.docs.isNotEmpty;
        print('✅ ÉTAPE 2 RÉUSSIE : Match existant ? $isMatch');
      } catch (e) {
        print('❌ ÉTAPE 2 ÉCHOUÉE : Vérification match - $e');
        rethrow;
      }

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 🔍 ÉTAPE 3 : Créer likes_received
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      print('📝 ÉTAPE 3 : Tentative création likes_received...');

      try {
        final likeReceivedRef =
            FirebaseFirestore.instance.collection('likes_received').doc();

        await likeReceivedRef.set({
          'receiverId': profileId,
          'giverId': _effectiveUserId,
          'giverName': currentUserName,
          'giverPhotoUrl': widget.currentUserPhotoUrl,
          'likeType': swipeType,
          'timestamp': timestamp,
          'isNotified': false,
          'isMatched': isMatch,
          'isRead': false,
          'createdAt': timestamp,
        });

        print('✅ ÉTAPE 3 RÉUSSIE : likes_received créé: ${likeReceivedRef.id}');
      } catch (e) {
        print('❌ ÉTAPE 3 ÉCHOUÉE : likes_received - $e');
        rethrow;
      }

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 🔍 ÉTAPE 4 : Créer match + chat (si match)
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      if (isMatch) {
        print('📝 ÉTAPE 4 : Création du match...');

        final matchId = _generateMatchId(_effectiveUserId, profileId);
        final profileName =
            profile['display_name'] ?? profile['name'] ?? 'Utilisateur';
        final profilePhoto = profile['photo_url'] ?? profile['imageUrl'] ?? '';

        // 4A : Créer match
        try {
          print('📝 ÉTAPE 4A : Création document matches...');
          await FirebaseFirestore.instance
              .collection('matches')
              .doc(matchId)
              .set({
            'matchId': matchId,
            'user1Id': _effectiveUserId,
            'user2Id': profileId,
            'user1Name': currentUserName,
            'user2Name': profileName,
            'user1PhotoUrl': widget.currentUserPhotoUrl,
            'user2PhotoUrl': profilePhoto,
            'matchedAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'lastMessage': null,
            'lastMessageAt': null,
            'createdBy': _effectiveUserId,
            'matchType': swipeType,
          });
          print('✅ ÉTAPE 4A RÉUSSIE : Match créé');
        } catch (e) {
          print('❌ ÉTAPE 4A ÉCHOUÉE : matches - $e');
          rethrow;
        }

        // 4B : Créer chat
        try {
          print('📝 ÉTAPE 4B : Création document chats...');
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(matchId)
              .set({
            'participants': [_effectiveUserId, profileId],
            'createdAt': FieldValue.serverTimestamp(),
            'lastMessage': '',
            'lastMessageTime': FieldValue.serverTimestamp(),
            'lastMessageSenderId': '',
            'lastMessageType': 'text',
            'isActive': true,
            'matchId': matchId,
            'typingUserId': null,
            'lastTypingTime': null,
            'unreadCount_$_effectiveUserId': 0,
            'unreadCount_$profileId': 0,
            'isBlocked': false,
            'blockedBy': null,
          });
          print('✅ ÉTAPE 4B RÉUSSIE : Chat créé');
        } catch (e) {
          print('❌ ÉTAPE 4B ÉCHOUÉE : chats - $e');
          rethrow;
        }

        // 4C : Notification
        try {
          print('📝 ÉTAPE 4C : Création notification...');
          await FirebaseFirestore.instance
              .collection('match_notifications')
              .doc('${profileId}_$matchId')
              .set({
            'userId': profileId,
            'matchId': matchId,
            'matchedWithId': _effectiveUserId,
            'matchedWithName': currentUserName,
            'matchedWithPhotoUrl': widget.currentUserPhotoUrl,
            'notifiedAt': FieldValue.serverTimestamp(),
            'isRead': false,
            'matchType': swipeType,
          });
          print('✅ ÉTAPE 4C RÉUSSIE : Notification créée');
        } catch (e) {
          print('❌ ÉTAPE 4C ÉCHOUÉE : match_notifications - $e');
          rethrow;
        }

        print('✅ ÉTAPE 4 COMPLÈTE : Match créé avec succès');
      }

      print('✅✅✅ LIKE ENREGISTRÉ AVEC SUCCÈS ✅✅✅');

      if (isMatch) {
        _handleMatchCreated(profile);
      } else {
        _handleLikeSent(profileId, swipeType);
      }

      _updateFFAppStateWithLike(profileId, swipeType, isMatch);
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      _handleSwipeAction(profileId, swipeType);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le serveur met trop de temps à répondre'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on FirebaseException catch (e) {
      print('❌❌❌ ERREUR FIREBASE DÉTAILLÉE ❌❌❌');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Plugin: ${e.plugin}');
      print('   StackTrace: ${e.stackTrace}');

      _handleSwipeAction(profileId, swipeType);

      if (mounted) {
        String errorMessage = 'Erreur lors du like';
        if (e.code == 'permission-denied') {
          errorMessage =
              'Erreur de permissions. Vérifiez les règles Firestore.';
        } else if (e.code == 'unavailable') {
          errorMessage = 'Service temporairement indisponible';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌❌❌ ERREUR INATTENDUE ❌❌❌');
      print('   Type: ${e.runtimeType}');
      print('   Message: $e');
      print('   Stack: $stackTrace');
      _handleSwipeAction(profileId, swipeType);
    }
  }

  Future<void> _createMatchWithNotification(WriteBatch batch, String profileId,
      Map<String, dynamic> profile, String swipeType) async {
    final matchId = _generateMatchId(_effectiveUserId, profileId);
    final profileName =
        profile['display_name'] ?? profile['name'] ?? 'Utilisateur';
    final profilePhoto = profile['photo_url'] ?? profile['imageUrl'] ?? '';
    final currentUserName = widget.currentUserName.isNotEmpty
        ? widget.currentUserName
        : 'Utilisateur';

    print('✨ CRÉATION MATCH + CHAT: $matchId');

    final matchRef =
        FirebaseFirestore.instance.collection('matches').doc(matchId);
    batch.set(matchRef, {
      'matchId': matchId,
      'user1Id': _effectiveUserId,
      'user2Id': profileId,
      'user1Name': currentUserName,
      'user2Name': profileName,
      'user1PhotoUrl': widget.currentUserPhotoUrl,
      'user2PhotoUrl': profilePhoto,
      'matchedAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'lastMessage': null,
      'lastMessageAt': null,
      'createdBy': _effectiveUserId,
      'matchType': swipeType,
    });

    print('📝 Création du document chat: $matchId');
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(matchId);

    batch.set(
        chatRef,
        {
          'participants': [_effectiveUserId, profileId],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSenderId': '',
          'lastMessageType': 'text',
          'isActive': true,
          'matchId': matchId,
          'typingUserId': null,
          'lastTypingTime': null,
          'unreadCount_$_effectiveUserId': 0,
          'unreadCount_$profileId': 0,
          'isBlocked': false,
          'blockedBy': null,
        },
        SetOptions(merge: false));

    print('✅ Chat configuré dans le batch');

    final user1MatchRef = FirebaseFirestore.instance
        .collection('user_matches')
        .doc(_effectiveUserId)
        .collection('matches')
        .doc(profileId);
    batch.set(user1MatchRef, {
      'matchId': matchId,
      'userId': profileId,
      'userName': profileName,
      'userPhotoUrl': profilePhoto,
      'matchedAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'unreadCount': 0,
      'matchType': swipeType,
    });

    final user2MatchRef = FirebaseFirestore.instance
        .collection('user_matches')
        .doc(profileId)
        .collection('matches')
        .doc(_effectiveUserId);
    batch.set(user2MatchRef, {
      'matchId': matchId,
      'userId': _effectiveUserId,
      'userName': currentUserName,
      'userPhotoUrl': widget.currentUserPhotoUrl,
      'matchedAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'unreadCount': 0,
      'matchType': 'received',
    });

    final matchNotificationRef = FirebaseFirestore.instance
        .collection('match_notifications')
        .doc('${profileId}_$matchId');
    batch.set(matchNotificationRef, {
      'userId': profileId,
      'matchId': matchId,
      'matchedWithId': _effectiveUserId,
      'matchedWithName': currentUserName,
      'matchedWithPhotoUrl': widget.currentUserPhotoUrl,
      'notifiedAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'matchType': swipeType,
    });

    print('✅ Match + Chat + UserMatches + Notifications configurés');
  }

  String _generateMatchId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  void _handleMatchCreated(Map<String, dynamic> profile) {
    setState(() {});
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showMatchDialog(profile);
    });
  }

  void _handleLikeSent(String profileId, String swipeType) {
    _animateNewNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(swipeType == 'superlike' ? Icons.star : Icons.favorite,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(swipeType == 'superlike'
                  ? 'Super Like envoyé!'
                  : 'Like envoyé!'),
            ],
          ),
          backgroundColor:
              swipeType == 'superlike' ? Colors.blue : Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _updateFFAppStateWithLike(
      String profileId, String swipeType, bool isMatch) {
    _safeUpdateFFAppState(() {
      FFAppState().lastSwipeAction = isMatch
          ? '${swipeType}_MATCH_${_generateMatchId(_effectiveUserId, profileId)}'
          : swipeType;
      FFAppState().lastSwipeProfileId = profileId;
    });
  }

  void _handleSwipeAction(String profileId, String swipeType) {
    _safeUpdateFFAppState(() {
      FFAppState().lastSwipeAction = swipeType;
      FFAppState().lastSwipeProfileId = profileId;
    });
  }

  void _showFullScreenAd() {
    if (_isShowingAd || !mounted) return;
    setState(() => _isShowingAd = true);
    final random = _randomInt(100);
    if (random < 70) {
      _showInterstitialFullScreen();
    } else {
      _showRewardedFullScreen();
    }
  }

  void _showInterstitialFullScreen() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      if (mounted) setState(() => _isShowingAd = false);
    }
  }

  void _showRewardedFullScreen() {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎁 Récompense gagnée: ${reward.amount} ${reward.type}');
          _logAdRevenueToFirestore(
            adType: 'rewarded',
            revenue: 0.05,
          );
        },
      );
    } else {
      if (mounted) setState(() => _isShowingAd = false);
    }
  }

  void _showMatchDialog(Map<String, dynamic> profile) {
    if (!mounted) return;
    final profileName =
        profile['display_name'] ?? profile['name'] ?? 'Utilisateur';
    final profilePhoto = profile['photo_url'] ?? profile['imageUrl'] ?? '';

    // ✅ RESPONSIVE: Tailles adaptatives
    final dialogPadding = _ResponsiveHelper.value(
      context,
      mobile: 32,
      tablet: 40,
      desktop: 48,
    );

    final titleFontSize = _ResponsiveHelper.fontSize(context, 32);
    final imageSizeMultiplier = _ResponsiveHelper.value(
      context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.4,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(dialogPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_ResponsiveHelper.value(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            )),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink[400]!, Colors.purple[600]!],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Text(
                      "C'EST UN MATCH!",
                      style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  );
                },
              ),
              SizedBox(height: dialogPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMatchProfileImage(
                      widget.currentUserPhotoUrl, true, imageSizeMultiplier),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.4 * value),
                        child: Container(
                          width: 60 * imageSizeMultiplier,
                          height: 60 * imageSizeMultiplier,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.favorite,
                              color: Colors.red,
                              size: 30 * imageSizeMultiplier),
                        ),
                      );
                    },
                  ),
                  _buildMatchProfileImage(
                      profilePhoto, false, imageSizeMultiplier),
                ],
              ),
              SizedBox(
                  height: _ResponsiveHelper.value(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              )),
              Text(
                'Vous et $profileName vous plaisez mutuellement!',
                style: TextStyle(
                    fontSize: _ResponsiveHelper.fontSize(context, 18),
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: dialogPadding),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        padding: EdgeInsets.symmetric(
                          vertical: _ResponsiveHelper.value(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      child: Text('Continuer',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  _ResponsiveHelper.fontSize(context, 16))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openChatWithMatch(profile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        padding: EdgeInsets.symmetric(
                          vertical: _ResponsiveHelper.value(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      child: Text(
                        'Message',
                        style: TextStyle(
                            color: Colors.purple[600],
                            fontSize: _ResponsiveHelper.fontSize(context, 16),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchProfileImage(
      String imageUrl, bool isCurrentUser, double sizeMultiplier) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: isCurrentUser ? 600 : 800),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80 * sizeMultiplier,
            height: 80 * sizeMultiplier,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                    )
                  : _buildAvatarPlaceholder(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.person, color: Colors.grey, size: 40),
    );
  }

  void _openChatWithMatch(Map<String, dynamic> profile) {
    try {
      final profileId =
          profile['id']?.toString() ?? profile['uid']?.toString() ?? '';
      final profileName =
          profile['display_name'] ?? profile['name'] ?? 'Utilisateur';
      final matchId = _generateMatchId(_effectiveUserId, profileId);

      print('💬 Navigation vers chat: $matchId');

      _safeUpdateFFAppState(() {
        FFAppState().lastSwipeAction = 'OPEN_CHAT';
        FFAppState().lastSwipeProfileId = profileId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎉 Nouveau match !',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Vous pouvez maintenant discuter avec $profileName'),
                const SizedBox(height: 8),
                const Text('Rendez-vous dans l\'onglet Messages',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      print('✅ Notification affichée');
    } catch (e) {
      print('❌ Erreur navigation: $e');
    }
  }

  // Autres méthodes inchangées...
  Future<void> _handleLikeBack(String giverId, String likeId) async {
    if (!_isUserAuthenticated || _effectiveUserId.isEmpty) return;

    try {
      print('💕 Like en retour: $_effectiveUserId → $giverId');

      final batch = FirebaseFirestore.instance.batch();
      final matchId = _generateMatchId(_effectiveUserId, giverId);

      // 1. Créer le like en retour
      final likeGivenRef = FirebaseFirestore.instance
          .collection('likes_given')
          .doc(); // ID automatique

      batch.set(likeGivenRef, {
        'giverId': _effectiveUserId,
        'receiverId': giverId,
        'giverName': widget.currentUserName.isNotEmpty
            ? widget.currentUserName
            : 'Utilisateur',
        'giverPhotoUrl': widget.currentUserPhotoUrl,
        'likeType': 'like',
        'timestamp': FieldValue.serverTimestamp(),
        'isMatched': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Marquer les deux likes comme matched
      batch.update(
          FirebaseFirestore.instance.collection('likes_received').doc(likeId),
          {'isMatched': true, 'isNotified': true});

      final reciprocalLikeRef = FirebaseFirestore.instance
          .collection('likes_received')
          .doc('${_effectiveUserId}_$giverId');

      batch.set(
          reciprocalLikeRef,
          {
            'receiverId': _effectiveUserId,
            'giverId': giverId,
            'timestamp': FieldValue.serverTimestamp(),
            'isNotified': true,
            'isMatched': true,
            'isRead': true,
          },
          SetOptions(merge: true));

      // 3. Créer le match et le chat
      await _createMatchFromNotificationBatch(batch, matchId, giverId, likeId);

      // 4. Commit le batch
      await batch.commit();

      print('✅ Match créé: $matchId');

      // 5. Afficher la notification
      if (mounted) {
        setState(() {
          _pendingLikesCount = math.max(0, _pendingLikesCount - 1);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'C\'est un match! 🎉',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Vous pouvez maintenant discuter',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Message',
              textColor: Colors.white,
              onPressed: () {
                // Navigation vers le chat
                _safeUpdateFFAppState(() {
                  FFAppState().lastSwipeAction = 'OPEN_CHAT_FROM_NOTIFICATION';
                  FFAppState().lastSwipeProfileId = giverId;
                });
              },
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Erreur like back: $e');
      print('Stack: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Erreur lors du like')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createMatchFromNotificationBatch(
      WriteBatch batch, String matchId, String giverId, String likeId) async {
    try {
      // Récupérer les infos du giver
      final giverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(giverId)
          .get();

      final giverData = giverDoc.data() ?? {};
      final giverName = giverData['display_name'] ??
          giverData['displayName'] ??
          giverData['name'] ??
          'Utilisateur';
      final giverPhotoUrl =
          giverData['photo_url'] ?? giverData['photoUrl'] ?? '';

      print('📝 Création match + chat: $matchId');

      // 1. Créer le match
      final matchRef =
          FirebaseFirestore.instance.collection('matches').doc(matchId);
      batch.set(matchRef, {
        'matchId': matchId,
        'user1Id': _effectiveUserId,
        'user2Id': giverId,
        'user1Name': widget.currentUserName.isNotEmpty
            ? widget.currentUserName
            : 'Utilisateur',
        'user2Name': giverName,
        'user1PhotoUrl': widget.currentUserPhotoUrl,
        'user2PhotoUrl': giverPhotoUrl,
        'matchedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'lastMessage': null,
        'lastMessageAt': null,
        'createdBy': 'notification_response',
      });

      // 2. Créer le chat
      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(matchId);
      batch.set(
          chatRef,
          {
            'participants': [_effectiveUserId, giverId],
            'createdAt': FieldValue.serverTimestamp(),
            'lastMessage': '',
            'lastMessageTime': FieldValue.serverTimestamp(),
            'lastMessageSenderId': '',
            'lastMessageType': 'text',
            'isActive': true,
            'matchId': matchId,
            'typingUserId': null,
            'lastTypingTime': null,
            'unreadCount_$_effectiveUserId': 0,
            'unreadCount_$giverId': 0,
            'isBlocked': false,
            'blockedBy': null,
          },
          SetOptions(merge: false));

      // 3. User matches
      final user1MatchRef = FirebaseFirestore.instance
          .collection('user_matches')
          .doc(_effectiveUserId)
          .collection('matches')
          .doc(giverId);

      batch.set(user1MatchRef, {
        'matchId': matchId,
        'userId': giverId,
        'userName': giverName,
        'userPhotoUrl': giverPhotoUrl,
        'matchedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'unreadCount': 0,
      });

      final user2MatchRef = FirebaseFirestore.instance
          .collection('user_matches')
          .doc(giverId)
          .collection('matches')
          .doc(_effectiveUserId);

      batch.set(user2MatchRef, {
        'matchId': matchId,
        'userId': _effectiveUserId,
        'userName': widget.currentUserName.isNotEmpty
            ? widget.currentUserName
            : 'Utilisateur',
        'userPhotoUrl': widget.currentUserPhotoUrl,
        'matchedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'unreadCount': 0,
      });

      // 4. Notification pour l'autre utilisateur
      final matchNotificationRef = FirebaseFirestore.instance
          .collection('match_notifications')
          .doc('${giverId}_$matchId');

      batch.set(matchNotificationRef, {
        'userId': giverId,
        'matchId': matchId,
        'matchedWithId': _effectiveUserId,
        'matchedWithName': widget.currentUserName.isNotEmpty
            ? widget.currentUserName
            : 'Utilisateur',
        'matchedWithPhotoUrl': widget.currentUserPhotoUrl,
        'notifiedAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'matchType': 'like_back',
      });

      print('✅ Match + Chat + UserMatches configurés');
    } catch (e) {
      print('❌ Erreur création match: $e');
      rethrow;
    }
  }

  Future<void> _handlePassBack(String likeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('likes_received')
          .doc(likeId)
          .update({'isRead': true});
      setState(() => _pendingLikesCount = math.max(0, _pendingLikesCount - 1));
    } catch (e) {
      print('❌ Erreur pass: $e');
    }
  }

  void _showAuthenticationError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Erreur: Vous devez être connecté')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _markLikeAsRead(String likeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('likes_received')
          .doc(likeId)
          .update({
        'isRead': true,
        'isNotified': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('⚠️ Erreur marquage lu: $e');
    }
  }

  void _showReceivedLikes() {
    if (!_isUserAuthenticated || _effectiveUserId.isEmpty) {
      _showAuthenticationError();
      return;
    }

    print('🔍 DIAGNOSTIC LIKES REÇUS');
    print('   userId: $_effectiveUserId');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReceivedLikesModalDebug(
        currentUserId: _effectiveUserId,
        onLikeBack: _handleLikeBack,
        onPass: _handlePassBack,
        onProfileView: _showProfileDetails,
      ),
    );
  }

  Widget _buildLikeItem(Map<String, dynamic> likeData, String likeId) {
    final giverName = likeData['giverName'] ?? 'Utilisateur';
    final giverPhotoUrl = likeData['giverPhotoUrl'] ?? '';
    final likeType = likeData['likeType'] ?? 'like';
    final isRead = likeData['isRead'] ?? false;
    final giverId = likeData['giverId'] ?? '';

    if (!isRead && widget.autoMarkAsRead) {
      _markLikeAsRead(likeId);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.pink[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isRead ? Colors.grey[300]! : Colors.pink[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showProfileDetails(giverId),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: likeType == 'superlike'
                                ? Colors.blue
                                : Colors.pink,
                            width: 3),
                      ),
                      child: ClipOval(
                        child: giverPhotoUrl.isNotEmpty
                            ? Image.network(
                                giverPhotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarPlaceholder(),
                              )
                            : _buildAvatarPlaceholder(),
                      ),
                    ),
                    if (likeType == 'superlike')
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.star,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    if (!isRead)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        giverName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        likeType == 'superlike'
                            ? 'Vous a envoyé un Super Like!'
                            : 'Vous a liké!',
                        style: TextStyle(
                          color: likeType == 'superlike'
                              ? Colors.blue
                              : Colors.grey[600],
                          fontSize: 14,
                          fontWeight: likeType == 'superlike'
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text('Appuyez pour voir le profil',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3),
                                SizedBox(height: 20),
                                Text('Création du match...',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                    await _handleLikeBack(giverId, likeId);
                    if (mounted && Navigator.canPop(context))
                      Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                  icon: const Icon(Icons.favorite, size: 20),
                  label: const Text('Like',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Profil passé'),
                        ]),
                        backgroundColor: Colors.grey,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await _handlePassBack(likeId);
                  },
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('Passer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showProfileDetails(String userId) async {
    try {
      print('👤 Affichage profil: $userId');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profil introuvable'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      if (mounted) {
        _showProfileDialog(userData, userId);
      }
    } catch (e) {
      print('❌ Erreur profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement du profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProfileDialog(Map<String, dynamic> userData, String userId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final photoUrl = userData['photo_url'] ?? userData['photoUrl'];
    final displayName = userData['display_name'] ??
        userData['displayName'] ??
        userData['name'] ??
        'Utilisateur';
    final age = userData['age']?.toString() ?? '';
    final bio = userData['bio'] ?? userData['Bio'] ?? '';
    final location = userData['location'] ?? userData['ville'] ?? '';
    final gender = userData['gender'] ?? '';
    final interests = userData['interests'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final modalHeight = _ResponsiveHelper.value(
          context,
          mobile: MediaQuery.of(context).size.height * 0.90,
          tablet: MediaQuery.of(context).size.height * 0.85,
          desktop: MediaQuery.of(context).size.height * 0.80,
        );

        return Container(
          height: modalHeight,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Contenu scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo de profil
                      Container(
                        height: _ResponsiveHelper.value(
                          context,
                          mobile: 400,
                          tablet: 500,
                          desktop: 600,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF6F61EF).withOpacity(0.1),
                        ),
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  displayName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 120,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6F61EF),
                                  ),
                                ),
                              ),
                      ),

                      // Informations
                      Padding(
                        padding: EdgeInsets.all(_ResponsiveHelper.value(
                          context,
                          mobile: 24,
                          tablet: 32,
                          desktop: 40,
                        )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nom et âge
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 32),
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (age.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6F61EF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$age ans',
                                      style: TextStyle(
                                        fontSize: _ResponsiveHelper.fontSize(
                                            context, 18),
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6F61EF),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Localisation
                            if (location.isNotEmpty) ...[
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 20, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: TextStyle(
                                        fontSize: _ResponsiveHelper.fontSize(
                                            context, 16),
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Genre
                            if (gender.isNotEmpty) ...[
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 20, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    gender,
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 16),
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Bio
                            if (bio.isNotEmpty) ...[
                              SizedBox(height: 24),
                              Text(
                                'À propos',
                                style: TextStyle(
                                  fontSize:
                                      _ResponsiveHelper.fontSize(context, 20),
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                bio,
                                style: TextStyle(
                                  fontSize:
                                      _ResponsiveHelper.fontSize(context, 16),
                                  height: 1.6,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                              ),
                            ],

                            // Centres d'intérêt
                            if (interests.isNotEmpty) ...[
                              SizedBox(height: 24),
                              Text(
                                'Centres d\'intérêt',
                                style: TextStyle(
                                  fontSize:
                                      _ResponsiveHelper.fontSize(context, 20),
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: interests.map((interest) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF39D2C0).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            Color(0xFF39D2C0).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      interest.toString(),
                                      style: TextStyle(
                                        fontSize: _ResponsiveHelper.fontSize(
                                            context, 14),
                                        color: Color(0xFF39D2C0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            SizedBox(height: 100), // Espace pour le bouton fixe
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton de fermeture fixe
              Container(
                padding: EdgeInsets.all(_ResponsiveHelper.value(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
                )),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF2A2A2A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6F61EF),
                      minimumSize: Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Fermer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _ResponsiveHelper.fontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ BUILD PRINCIPAL AVEC RESPONSIVE
  @override
  Widget build(BuildContext context) {
    if (!mounted || !_isUserAuthenticated || _effectiveUserId.isEmpty) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: Colors.red[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: _ResponsiveHelper.value(
                    context,
                    mobile: 64,
                    tablet: 80,
                    desktop: 96,
                  ),
                  color: Colors.red),
              SizedBox(
                  height: _ResponsiveHelper.value(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              )),
              Text('Erreur d\'authentification',
                  style: TextStyle(
                      fontSize: _ResponsiveHelper.fontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              SizedBox(
                  height: _ResponsiveHelper.value(
                context,
                mobile: 10,
                tablet: 12,
                desktop: 16,
              )),
              Text('Veuillez vous connecter',
                  style: TextStyle(
                      fontSize: _ResponsiveHelper.fontSize(context, 16),
                      color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomOffset = screenHeight *
        (_ResponsiveHelper.isDesktop(context)
            ? 0.20
            : _ResponsiveHelper.isTablet(context)
                ? 0.18
                : 0.15);

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: Stack(
        children: [
          _buildProfileStack(),
          if (_superLikeController.isAnimating) _buildSuperLikeOverlay(),
          _buildActionButtons(bottomOffset),
          _buildCounters(),
          if (widget.enableNotifications && widget.showNotificationButton)
            _buildNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildProfileStack() {
    if (filteredProfiles.isEmpty || currentIndex >= filteredProfiles.length) {
      return _buildNoMoreProfiles();
    }

    return Stack(
      children: [
        if (currentIndex + 1 < filteredProfiles.length)
          _buildProfileCard(filteredProfiles[currentIndex + 1], isNext: true),
        SlideTransition(
            position: _cardAnimation,
            child: _buildProfileCard(filteredProfiles[currentIndex])),
      ],
    );
  }

  // ✅ PROFILE CARD RESPONSIVE
  Widget _buildProfileCard(Map<String, dynamic> profile,
      {bool isNext = false}) {
    final name = profile['display_name']?.toString() ?? 'Inconnu';
    final age = profile['age']?.toString() ?? '?';
    final bio = profile['bio']?.toString() ?? '';
    final location = profile['location']?.toString() ?? '';
    final imageUrl = profile['photo_url']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.all(_ResponsiveHelper.value(
        context,
        mobile: isNext ? 20 : 16,
        tablet: isNext ? 32 : 24,
        desktop: isNext ? 40 : 32,
      )),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_ResponsiveHelper.value(
          context,
          mobile: 24,
          tablet: 28,
          desktop: 32,
        )),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isNext ? 0.1 : 0.25),
            blurRadius: isNext ? 15 : 25,
            offset: Offset(0, isNext ? 5 : 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_ResponsiveHelper.value(
          context,
          mobile: 24,
          tablet: 28,
          desktop: 32,
        )),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage())
                : _buildPlaceholderImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8)
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    _ResponsiveHelper.value(
                      context,
                      mobile: 24,
                      tablet: 32,
                      desktop: 40,
                    ),
                    40,
                    _ResponsiveHelper.value(
                      context,
                      mobile: 24,
                      tablet: 32,
                      desktop: 40,
                    ),
                    MediaQuery.of(context).size.height * 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$name, $age ans',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: _ResponsiveHelper.fontSize(context, 28),
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (bio.isNotEmpty) ...[
                      SizedBox(
                          height: _ResponsiveHelper.value(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      )),
                      Text(bio,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  _ResponsiveHelper.fontSize(context, 15)),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                    ],
                    if (location.isNotEmpty) ...[
                      SizedBox(
                          height: _ResponsiveHelper.value(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      )),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.white,
                              size: _ResponsiveHelper.value(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              )),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(location,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 15)),
                                  maxLines: 1)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
          child: Icon(Icons.person,
              size: _ResponsiveHelper.value(
                context,
                mobile: 100,
                tablet: 120,
                desktop: 150,
              ),
              color: Colors.grey)),
    );
  }

  Widget _buildSuperLikeOverlay() {
    return Positioned.fill(
      child: ScaleTransition(
        scale: _superLikeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.4),
            borderRadius: BorderRadius.circular(_ResponsiveHelper.value(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            )),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star,
                    size: _ResponsiveHelper.value(
                      context,
                      mobile: 120,
                      tablet: 150,
                      desktop: 180,
                    ),
                    color: Colors.white),
                SizedBox(
                    height: _ResponsiveHelper.value(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                )),
                Text('SUPER LIKE!',
                    style: TextStyle(
                        fontSize: _ResponsiveHelper.fontSize(context, 32),
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ ACTION BUTTONS RESPONSIVE
  Widget _buildActionButtons(double bottomOffset) {
    return Positioned(
      bottom: bottomOffset,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
              icon: Icons.close,
              color: Colors.red,
              size: _ResponsiveHelper.value(
                context,
                mobile: 64,
                tablet: 72,
                desktop: 80,
              ),
              onPressed: () => _handleSwipe('pass')),
          _buildActionButton(
              icon: Icons.star,
              color: Colors.blue,
              size: _ResponsiveHelper.value(
                context,
                mobile: 56,
                tablet: 64,
                desktop: 72,
              ),
              onPressed: () => _handleSwipe('superlike')),
          _buildActionButton(
              icon: Icons.favorite,
              color: Colors.green,
              size: _ResponsiveHelper.value(
                context,
                mobile: 72,
                tablet: 80,
                desktop: 88,
              ),
              onPressed: () => _handleSwipe('like')),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 64,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }

  // ✅ COUNTERS RESPONSIVE
  Widget _buildCounters() {
    return Positioned(
      top: _ResponsiveHelper.value(
        context,
        mobile: 60,
        tablet: 80,
        desktop: 100,
      ),
      right: _ResponsiveHelper.value(
        context,
        mobile: 20,
        tablet: 30,
        desktop: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildCounter(
              'Profils: ${math.max(0, filteredProfiles.length - currentIndex)}',
              Colors.purple),
          if (widget.enableNotifications) ...[
            SizedBox(
                height: _ResponsiveHelper.value(
              context,
              mobile: 8,
              tablet: 10,
              desktop: 12,
            )),
            _buildCounter('💘 Likes: $_pendingLikesCount', Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildCounter(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _ResponsiveHelper.value(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        vertical: _ResponsiveHelper.value(
          context,
          mobile: 8,
          tablet: 10,
          desktop: 12,
        ),
      ),
      decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: Colors.white,
              fontSize: _ResponsiveHelper.fontSize(context, 12),
              fontWeight: FontWeight.bold)),
    );
  }

  // ✅ NOTIFICATION BUTTON RESPONSIVE
  Widget _buildNotificationButton() {
    return Positioned(
      top: _ResponsiveHelper.value(
        context,
        mobile: 60,
        tablet: 80,
        desktop: 100,
      ),
      left: _ResponsiveHelper.value(
        context,
        mobile: 20,
        tablet: 30,
        desktop: 40,
      ),
      child: ScaleTransition(
        scale: _notificationAnimation,
        child: GestureDetector(
          onTap: _showReceivedLikes,
          child: Container(
            padding: EdgeInsets.all(_ResponsiveHelper.value(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            )),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Stack(
              children: [
                Icon(Icons.favorite,
                    color: _pendingLikesCount > 0 ? Colors.red : Colors.grey,
                    size: _ResponsiveHelper.value(
                      context,
                      mobile: 28,
                      tablet: 32,
                      desktop: 36,
                    )),
                if (_pendingLikesCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          _pendingLikesCount > 9 ? '9+' : '$_pendingLikesCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoMoreProfiles() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉',
              style: TextStyle(
                  fontSize: _ResponsiveHelper.fontSize(context, 100))),
          SizedBox(
              height: _ResponsiveHelper.value(
            context,
            mobile: 24,
            tablet: 32,
            desktop: 40,
          )),
          Text('Plus de profils !',
              style: TextStyle(
                  fontSize: _ResponsiveHelper.fontSize(context, 28),
                  fontWeight: FontWeight.bold)),
          SizedBox(
              height: _ResponsiveHelper.value(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          )),
          Text('Vous avez tout vu pour le moment',
              style: TextStyle(
                  fontSize: _ResponsiveHelper.fontSize(context, 16),
                  color: Colors.grey[600])),
          if (widget.enableNotifications && _pendingLikesCount > 0) ...[
            SizedBox(
                height: _ResponsiveHelper.value(
              context,
              mobile: 32,
              tablet: 40,
              desktop: 48,
            )),
            ElevatedButton.icon(
              onPressed: _showReceivedLikes,
              icon: const Icon(Icons.favorite),
              label: Text('Voir $_pendingLikesCount likes reçus'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: _ResponsiveHelper.value(
                      context,
                      mobile: 32,
                      tablet: 40,
                      desktop: 48,
                    ),
                    vertical: _ResponsiveHelper.value(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    )),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
          SizedBox(
              height: _ResponsiveHelper.value(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          )),
          ElevatedButton.icon(
            onPressed: () {
              if (mounted) {
                setState(() => currentIndex = 0);
                _filterProfilesMethod();
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: _ResponsiveHelper.value(
                    context,
                    mobile: 32,
                    tablet: 40,
                    desktop: 48,
                  ),
                  vertical: _ResponsiveHelper.value(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  )),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('🧹 DÉBUT DISPOSE SwipeWidget');

    try {
      print('   ├─ Annulation listeners Firestore...');

      // ✅ CORRECTION CRITIQUE : Annuler le listener de notifications
      _notificationSubscription?.cancel();
      _notificationSubscription = null;

      // ✅ Nettoyage du gestionnaire global
      final key = 'swipe_notifications_$_effectiveUserId';
      if (_effectiveUserId.isNotEmpty) {
        print('   ├─ Nettoyage listener global: $key');
        _listenerManager.removeListener(key);
      }

      print('   ├─ Annulation timers...');
      _debounceTimer?.cancel();
      _debounceTimer = null;

      print('   ├─ Nettoyage cache (${_profileCache.length} entrées)...');
      _profileCache.clear();

      print('   ├─ Dispose animations...');
      _cardController.dispose();
      _superLikeController.dispose();
      _notificationController.dispose();

      print('   ├─ Dispose publicités...');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _rewardedAd?.dispose();
      _rewardedAd = null;

      print('✅ DISPOSE TERMINÉ');
    } catch (e, stackTrace) {
      print('❌ ERREUR DISPOSE: $e');
      print('Stack: $stackTrace');
    }

    super.dispose();
  }
}

// ========================================
// 🎯 MODAL DES LIKES REÇUS
// ========================================
class _ReceivedLikesModal extends StatefulWidget {
  final String currentUserId;
  final Function(String, String) onLikeBack;
  final Function(String) onPass;
  final Function(String) onProfileView;

  const _ReceivedLikesModal({
    required this.currentUserId,
    required this.onLikeBack,
    required this.onPass,
    required this.onProfileView,
  });

  @override
  State<_ReceivedLikesModal> createState() => _ReceivedLikesModalState();
}

class _ReceivedLikesModalState extends State<_ReceivedLikesModal> {
  StreamSubscription<QuerySnapshot>? _likesSubscription;
  Stream<QuerySnapshot>? _likesStream;

  @override
  void initState() {
    super.initState();
    // ✅ Créer le stream UNE SEULE FOIS
    _likesStream = FirebaseFirestore.instance
        .collection('likes_received')
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('isNotified', isEqualTo: false)
        .where('isMatched', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  @override
  void dispose() {
    _likesSubscription?.cancel();
    print('🧹 _ReceivedLikesModal disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final modalHeight = _ResponsiveHelper.value(
      context,
      mobile: MediaQuery.of(context).size.height * 0.90,
      tablet: MediaQuery.of(context).size.height * 0.85,
      desktop: MediaQuery.of(context).size.height * 0.80,
    );

    return Container(
      height: modalHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personnes qui vous ont aimé',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Liste des likes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (() {
                // ✅ WRAPPER pour capturer le listener
                _likesSubscription?.cancel();
                final stream = FirebaseFirestore.instance
                    .collection('likes_received')
                    .where('receiverId', isEqualTo: widget.currentUserId)
                    .where('isNotified', isEqualTo: false)
                    .where('isMatched', isEqualTo: false)
                    .orderBy('timestamp', descending: true)
                    .limit(50) // ✅ LIMITE CRITIQUE
                    .snapshots();

                _likesSubscription = stream.listen((_) {});
                return stream;
              })(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF6F61EF)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'Aucun like en attente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final giverId = data['giverId']?.toString() ?? '';
                    final giverName =
                        data['giverName']?.toString() ?? 'Utilisateur';
                    final giverPhotoUrl = data['giverPhotoUrl']?.toString();
                    final likeType = data['likeType']?.toString() ?? 'like';

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => widget.onProfileView(giverId),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage: giverPhotoUrl != null &&
                                            giverPhotoUrl.isNotEmpty
                                        ? NetworkImage(giverPhotoUrl)
                                        : null,
                                    child: giverPhotoUrl == null ||
                                            giverPhotoUrl.isEmpty
                                        ? Text(giverName[0].toUpperCase())
                                        : null,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          giverName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          likeType == 'superlike'
                                              ? 'Vous a envoyé un Super Like!'
                                              : 'Vous a aimé!',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        widget.onPass(doc.id);
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.close),
                                      label: Text('Passer'),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        widget.onLikeBack(giverId, doc.id);
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.favorite),
                                      label: Text('Liker aussi'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF6F61EF),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedLikesModalDebug extends StatefulWidget {
  final String currentUserId;
  final Function(String, String) onLikeBack;
  final Function(String) onPass;
  final Function(String) onProfileView;

  const _ReceivedLikesModalDebug({
    required this.currentUserId,
    required this.onLikeBack,
    required this.onPass,
    required this.onProfileView,
  });

  @override
  State<_ReceivedLikesModalDebug> createState() =>
      _ReceivedLikesModalDebugState();
}

class _ReceivedLikesModalDebugState extends State<_ReceivedLikesModalDebug> {
  StreamSubscription<QuerySnapshot>? _likesSubscription;
  Stream<QuerySnapshot>? _likesStream;

  @override
  void initState() {
    super.initState();
    print('🔍 Modal Likes Reçus ouverte');
    print('   currentUserId: ${widget.currentUserId}');

    // ✅ Créer le stream UNE SEULE FOIS
    _likesStream = FirebaseFirestore.instance
        .collection('likes_received')
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('isNotified', isEqualTo: false)
        .where('isMatched', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  @override
  void dispose() {
    _likesSubscription?.cancel();
    print('🧹 _ReceivedLikesModalDebug disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personnes qui vous ont aimé',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Liste avec StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _likesStream, // ✅ UTILISER LE STREAM CRÉÉ DANS INITSTATE
              builder: (context, snapshot) {
                print('📊 StreamBuilder Likes:');
                print('   connectionState: ${snapshot.connectionState}');
                print('   hasData: ${snapshot.hasData}');
                print('   hasError: ${snapshot.hasError}');

                if (snapshot.hasError) {
                  print('❌ ERREUR: ${snapshot.error}');

                  // ✅ VÉRIFIER SI C'EST UNE ERREUR D'INDEX
                  final errorMessage = snapshot.error.toString();
                  if (errorMessage.contains('requires an index')) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'Configuration requise',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Un index Firestore doit être créé.',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Vérifiez les logs pour le lien de création automatique.',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Autre type d'erreur
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 64),
                        SizedBox(height: 16),
                        Text('Erreur de chargement'),
                        SizedBox(height: 8),
                        Text(
                          errorMessage.length > 100
                              ? errorMessage.substring(0, 100) + '...'
                              : errorMessage,
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final likes = snapshot.data!.docs;
                print('✅ ${likes.length} likes trouvés');

                for (var i = 0; i < likes.length; i++) {
                  final data = likes[i].data() as Map<String, dynamic>;
                  print('   📄 Like ${i + 1}:');
                  print('      ID: ${likes[i].id}');
                  print('      giverId: ${data['giverId']}');
                  print('      giverName: ${data['giverName']}');
                }

                if (likes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'Aucun like en attente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: likes.length,
                  itemBuilder: (context, index) {
                    final doc = likes[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final giverId = data['giverId']?.toString() ?? '';
                    final giverName =
                        data['giverName']?.toString() ?? 'Utilisateur';
                    final giverPhotoUrl = data['giverPhotoUrl']?.toString();
                    final likeType = data['likeType']?.toString() ?? 'like';

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => widget.onProfileView(giverId),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage: giverPhotoUrl != null &&
                                            giverPhotoUrl.isNotEmpty
                                        ? NetworkImage(giverPhotoUrl)
                                        : null,
                                    child: giverPhotoUrl == null ||
                                            giverPhotoUrl.isEmpty
                                        ? Text(giverName[0].toUpperCase())
                                        : null,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          giverName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          likeType == 'superlike'
                                              ? 'Vous a envoyé un Super Like!'
                                              : 'Vous a aimé!',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        widget.onPass(doc.id);
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.close),
                                      label: Text('Passer'),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        widget.onLikeBack(giverId, doc.id);
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.favorite),
                                      label: Text('Liker aussi'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF6F61EF),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

// ========================================
// 🎨 RESPONSIVE HELPER
// ========================================
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

class NotificationsWidget1 extends StatefulWidget {
  const NotificationsWidget1({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<NotificationsWidget1> createState() => _NotificationsWidget1State();
}

class _NotificationsWidget1State extends State<NotificationsWidget1>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  String currentUserId = '';

  // ✅ StreamSubscriptions pour gestion manuelle
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _likesSubscription;
  StreamSubscription? _matchesSubscription;

  // Compteurs pour les badges
  int _messageCount = 0;
  int _likeCount = 0;
  int _matchCount = 0;

  static const primaryColor = Color(0xFF6F61EF);
  static const secondaryColor = Color(0xFF39D2C0);
  static const accentPink = Color(0xFFFF6B9D);
  static const accentPurple = Color(0xFFC239B3);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Animation pour le bouton "Tout marquer comme lu"
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _initializeUserId();
    _setupNotificationCounters();
  }

  void _initializeUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  void _setupNotificationCounters() {
    if (currentUserId.isEmpty) return;

    print('📡 Configuration des listeners de notifications');

    // ✅ 1. Messages non lus avec LIMITE
    _chatsSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .limit(50) // ✅ CORRECTION CRITIQUE
        .snapshots()
        .listen((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        count += (data['unreadCount_$currentUserId'] ?? 0) as int;
      }
      if (mounted) {
        setState(() {
          _messageCount = count;
        });
      }
    }, onError: (error) {
      print('❌ Erreur listener chats: $error');
    });

    // ✅ 2. Likes non lus avec LIMITE
    _likesSubscription = FirebaseFirestore.instance
        .collection('likes_received')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .limit(50) // ✅ CORRECTION CRITIQUE
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _likeCount = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      print('❌ Erreur listener likes: $error');
    });

    // ✅ 3. Matches non lus avec LIMITE
    _matchesSubscription = FirebaseFirestore.instance
        .collection('match_notifications')
        .where('userId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .limit(20) // ✅ CORRECTION CRITIQUE
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _matchCount = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      print('❌ Erreur listener matches: $error');
    });

    print('✅ 3 listeners de notifications configurés avec limites');
  }

  @override
  void dispose() {
    print('🧹 DÉBUT DISPOSE NotificationsWidget');

    // ✅ ANNULER TOUS LES STREAMSUBSCRIPTIONS
    _chatsSubscription?.cancel();
    _likesSubscription?.cancel();
    _matchesSubscription?.cancel();

    // ✅ DISPOSE DES CONTROLLERS
    _tabController.dispose();
    _fabAnimationController.dispose();

    print('✅ NotificationsWidget dispose terminé - 3 listeners annulés');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUserId.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6F61EF), Color(0xFF39D2C0)],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    final totalNotifications = _messageCount + _likeCount + _matchCount;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1A1A) : Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _ResponsiveHelper.value(
                context,
                mobile: 160,
                tablet: 200,
                desktop: 240,
              ),
              floating: false,
              pinned: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xFF6F61EF),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6F61EF), Color(0xFF6F61EF)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        _ResponsiveHelper.value(context,
                            mobile: 20, tablet: 28, desktop: 36),
                        _ResponsiveHelper.value(context,
                            mobile: 20, tablet: 28, desktop: 36),
                        _ResponsiveHelper.value(context,
                            mobile: 20, tablet: 28, desktop: 36),
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Notifications',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        _ResponsiveHelper.fontSize(context, 28),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Badge total
                              if (totalNotifications > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _ResponsiveHelper.value(context,
                                        mobile: 12, tablet: 14, desktop: 16),
                                    vertical: _ResponsiveHelper.value(context,
                                        mobile: 6, tablet: 7, desktop: 8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    totalNotifications > 99
                                        ? '99+'
                                        : '$totalNotifications',
                                    style: TextStyle(
                                      color: Color(0xFF6F61EF),
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 14),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            totalNotifications == 0
                                ? 'Vous êtes à jour !'
                                : totalNotifications == 1
                                    ? '1 nouvelle notification'
                                    : '$totalNotifications nouvelles notifications',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Color(0xFF6F61EF),
                    indicatorWeight: 3,
                    labelColor: Color(0xFF6F61EF),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Messages'),
                            if (_messageCount > 0) ...[
                              SizedBox(width: 6),
                              _buildTabBadge(_messageCount),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Likes'),
                            if (_likeCount > 0) ...[
                              SizedBox(width: 6),
                              _buildTabBadge(_likeCount),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Matches'),
                            if (_matchCount > 0) ...[
                              SizedBox(width: 6),
                              _buildTabBadge(_matchCount),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMessageNotifications(),
            _buildLikeNotifications(),
            _buildMatchNotifications(),
          ],
        ),
      ),
      floatingActionButton: totalNotifications > 0
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _fabAnimationController.forward().then((_) {
                    _markAllAsRead();
                    _fabAnimationController.reverse();
                  });
                },
                backgroundColor: Color(0xFF6F61EF),
                elevation: 4,
                icon: Icon(Icons.done_all, color: Colors.white),
                label: Text(
                  'Tout marquer comme lu',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTabBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            _ResponsiveHelper.value(context, mobile: 6, tablet: 7, desktop: 8),
        vertical:
            _ResponsiveHelper.value(context, mobile: 2, tablet: 3, desktop: 4),
      ),
      decoration: BoxDecoration(
        color: Color(0xFF6F61EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==================== NOTIFICATIONS DE MESSAGES ====================
  Widget _buildMessageNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Aucun message',
            subtitle: 'Les nouveaux messages apparaîtront ici',
            color: primaryColor,
          );
        }

        final unreadChats = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final unreadCount = data['unreadCount_$currentUserId'] ?? 0;
          return unreadCount > 0;
        }).toList();

        if (unreadChats.isEmpty) {
          return _buildEmptyState(
            icon: Icons.mark_chat_read_rounded,
            title: 'Tout est lu !',
            subtitle: 'Vous n\'avez aucun message non lu',
            color: Colors.green,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: unreadChats.length,
          itemBuilder: (context, index) {
            final chatDoc = unreadChats[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            return _buildMessageNotificationCard(chatDoc.id, chatData, index);
          },
        );
      },
    );
  }

  Widget _buildMessageNotificationCard(
    String chatId,
    Map<String, dynamic> chatData,
    int index,
  ) {
    final participants = List<String>.from(chatData['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return SizedBox.shrink();

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) return SizedBox.shrink();

        final unreadCount = chatData['unreadCount_$currentUserId'] ?? 0;
        final lastMessage = chatData['lastMessage'] ?? 'Nouveau message';
        final lastMessageTime =
            (chatData['lastMessageTime'] as Timestamp?)?.toDate();

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _navigateToChat(chatId, otherUserId, userData),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Photo avec badge de statut
                      Stack(
                        children: [
                          Hero(
                            tag: 'profile_$otherUserId',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: _ResponsiveHelper.value(
                                  context,
                                  mobile: 30,
                                  tablet: 36,
                                  desktop: 42,
                                ),
                                backgroundColor: Colors.grey[200],
                                backgroundImage: userData['photo_url'] != null
                                    ? CachedNetworkImageProvider(
                                        userData['photo_url'])
                                    : null,
                                child: userData['photo_url'] == null
                                    ? Icon(Icons.person,
                                        size: 32, color: Colors.grey[400])
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                ),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      // Contenu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userData['display_name'] ?? 'Utilisateur',
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (lastMessageTime != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _ResponsiveHelper.value(
                                          context,
                                          mobile: 8,
                                          tablet: 10,
                                          desktop: 12),
                                      vertical: _ResponsiveHelper.value(context,
                                          mobile: 4, tablet: 5, desktop: 6),
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _formatTimeAgo(lastMessageTime),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatLastMessage(lastMessage),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== NOTIFICATIONS DE LIKES ====================
  Widget _buildLikeNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('likes_received')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'Aucun nouveau like',
            subtitle: 'Les personnes qui vous likent apparaîtront ici',
            color: Colors.red,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final likeDoc = snapshot.data!.docs[index];
            final likeData = likeDoc.data() as Map<String, dynamic>;
            return _buildLikeNotificationCard(likeDoc.id, likeData, index);
          },
        );
      },
    );
  }

  Widget _buildLikeNotificationCard(
    String docId,
    Map<String, dynamic> likeData,
    int index,
  ) {
    final senderId =
        likeData['giverId'] as String? ?? likeData['senderId'] as String;
    final timestamp = (likeData['timestamp'] as Timestamp?)?.toDate();
    final isSuperLike = likeData['likeType'] == 'superlike';

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(senderId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return SizedBox.shrink();

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) return SizedBox.shrink();

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSuperLike
                    ? [Colors.blue.withOpacity(0.1), Colors.white]
                    : [accentPink.withOpacity(0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSuperLike
                    ? Colors.blue.withOpacity(0.3)
                    : accentPink.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isSuperLike ? Colors.blue : accentPink).withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () =>
                    _showProfileAndMarkAsRead(docId, senderId, userData),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Photo avec icône du type de like
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSuperLike ? Colors.blue : accentPink,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: _ResponsiveHelper.value(
                                context,
                                mobile: 30,
                                tablet: 36,
                                desktop: 42,
                              ),
                              backgroundColor: Colors.grey[200],
                              backgroundImage: userData['photo_url'] != null
                                  ? CachedNetworkImageProvider(
                                      userData['photo_url'])
                                  : null,
                              child: userData['photo_url'] == null
                                  ? Icon(Icons.person,
                                      size: 32, color: Colors.grey[400])
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSuperLike ? Colors.blue : accentPink,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                isSuperLike ? Icons.star : Icons.favorite,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      // Contenu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userData['display_name'] ?? 'Utilisateur',
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (timestamp != null)
                                  Text(
                                    _formatTimeAgo(timestamp),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _ResponsiveHelper.value(context,
                                    mobile: 10, tablet: 12, desktop: 14),
                                vertical: _ResponsiveHelper.value(context,
                                    mobile: 6, tablet: 7, desktop: 8),
                              ),
                              decoration: BoxDecoration(
                                color: (isSuperLike ? Colors.blue : accentPink)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSuperLike ? Icons.star : Icons.favorite,
                                    size: 14,
                                    color:
                                        isSuperLike ? Colors.blue : accentPink,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    isSuperLike
                                        ? 'Super Like !'
                                        : 'Vous a liké',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSuperLike
                                          ? Colors.blue
                                          : accentPink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== NOTIFICATIONS DE MATCHES ====================
  Widget _buildMatchNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('match_notifications')
          .where('userId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .orderBy('notifiedAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_rounded,
            title: 'Aucun nouveau match',
            subtitle: 'Vos matches apparaîtront ici',
            color: accentPink,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final matchDoc = snapshot.data!.docs[index];
            final matchData = matchDoc.data() as Map<String, dynamic>;
            return _buildMatchNotificationCard(matchDoc.id, matchData, index);
          },
        );
      },
    );
  }

  Widget _buildMatchNotificationCard(
    String docId,
    Map<String, dynamic> matchData,
    int index,
  ) {
    final matchId = matchData['matchId'] as String;
    final otherUserId = matchData['matchedWithId'] as String;
    final timestamp = (matchData['notifiedAt'] as Timestamp?)?.toDate();

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return SizedBox.shrink();

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) return SizedBox.shrink();

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 50)),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentPink, accentPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentPink.withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () =>
                    _navigateToMatchChat(docId, matchId, otherUserId, userData),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Photo avec effet spécial match
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: _ResponsiveHelper.value(
                                context,
                                mobile: 30,
                                tablet: 36,
                                desktop: 42,
                              ),
                              backgroundColor: Colors.grey[200],
                              backgroundImage: userData['photo_url'] != null
                                  ? CachedNetworkImageProvider(
                                      userData['photo_url'])
                                  : null,
                              child: userData['photo_url'] == null
                                  ? Icon(Icons.person,
                                      size: 36, color: Colors.white)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite,
                                size: 16,
                                color: accentPink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      // Contenu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.celebration_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    userData['display_name'] ?? 'Utilisateur',
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 18),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (timestamp != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _ResponsiveHelper.value(
                                          context,
                                          mobile: 8,
                                          tablet: 10,
                                          desktop: 12),
                                      vertical: _ResponsiveHelper.value(context,
                                          mobile: 4, tablet: 5, desktop: 6),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _formatTimeAgo(timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _ResponsiveHelper.value(context,
                                    mobile: 10, tablet: 12, desktop: 14),
                                vertical: _ResponsiveHelper.value(context,
                                    mobile: 6, tablet: 7, desktop: 8),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'C\'est un match ! Commencez à discuter',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
              ),
            ),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Chargement...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: color,
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  String _formatLastMessage(String message) {
    if (message.startsWith('📷')) return '📷 Photo';
    if (message.startsWith('🎤')) return '🎤 Message vocal';
    if (message.startsWith('📹')) return '📹 Vidéo';
    return message;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return 'À l\'instant';
    if (difference.inMinutes < 60) return '${difference.inMinutes}min';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}j';
    return '${dateTime.day}/${dateTime.month}';
  }

  void _navigateToChat(
    String chatId,
    String otherUserId,
    Map<String, dynamic> userData,
  ) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'unreadCount_$currentUserId': 0,
    });

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/chatPage',
      arguments: {
        'chatId': chatId,
        'otherUserId': otherUserId,
        'otherUserName': userData['display_name'] ?? 'Utilisateur',
        'otherUserPhoto': userData['photo_url'],
      },
    );
  }

  Future<void> _showProfileAndMarkAsRead(
    String docId,
    String userId,
    Map<String, dynamic> userData,
  ) async {
    await FirebaseFirestore.instance
        .collection('likes_received')
        .doc(docId)
        .update({'isRead': true});

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/profilePage',
      arguments: {
        'userId': userId,
        'userData': userData,
      },
    );
  }

  Future<void> _navigateToMatchChat(
    String docId,
    String matchId,
    String otherUserId,
    Map<String, dynamic> userData,
  ) async {
    await FirebaseFirestore.instance
        .collection('match_notifications')
        .doc(docId)
        .update({'isRead': true});

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/chatPage',
      arguments: {
        'chatId': matchId,
        'otherUserId': otherUserId,
        'otherUserName': userData['display_name'] ?? 'Utilisateur',
        'otherUserPhoto': userData['photo_url'],
      },
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Likes
      final likesQuery = await FirebaseFirestore.instance
          .collection('likes_received')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();
      for (var doc in likesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Matches
      final matchesQuery = await FirebaseFirestore.instance
          .collection('match_notifications')
          .where('userId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();
      for (var doc in matchesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Messages
      final chatsQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();
      for (var doc in chatsQuery.docs) {
        batch.update(doc.reference, {'unreadCount_$currentUserId': 0});
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Toutes les notifications sont marquées comme lues'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Erreur: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

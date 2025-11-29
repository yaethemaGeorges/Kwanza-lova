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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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

  static double maxWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 900;
    return double.infinity;
  }

  static EdgeInsets horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.symmetric(horizontal: 32);
    if (isTablet(context)) return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  static double avatarRadius(BuildContext context) {
    if (isDesktop(context)) return 40;
    if (isTablet(context)) return 36;
    return 28;
  }

  static double spacing(BuildContext context, double base) {
    if (isDesktop(context)) return base * 1.5;
    if (isTablet(context)) return base * 1.2;
    return base;
  }
}

class MatchesWidget extends StatefulWidget {
  const MatchesWidget({
    Key? key,
    this.width,
    this.height,
    required this.currentUserId,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<MatchesWidget> createState() => _MatchesWidgetState();
}

class _MatchesWidgetState extends State<MatchesWidget> {
  static const primaryColor = Color(0xFF6F61EF);
  static const secondaryColor = Color(0xFF39D2C0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: _getMatchesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }

          final allDocs = <DocumentSnapshot>[];
          for (var qs in snapshot.data!) {
            allDocs.addAll(qs.docs);
          }

          final uniqueDocs = <String, DocumentSnapshot>{};
          for (var doc in allDocs) {
            uniqueDocs[doc.id] = doc;
          }

          if (uniqueDocs.isEmpty) {
            return Center(
              child: Padding(
                padding: _ResponsiveHelper.horizontalPadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: _ResponsiveHelper.value(
                        context,
                        mobile: 80,
                        tablet: 100,
                        desktop: 120,
                      ),
                      color: primaryColor.withOpacity(0.3),
                    ),
                    SizedBox(height: _ResponsiveHelper.spacing(context, 16)),
                    Text(
                      'Aucune conversation',
                      style: TextStyle(
                        fontSize: _ResponsiveHelper.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final matches = uniqueDocs.values.toList();

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _ResponsiveHelper.maxWidth(context),
              ),
              child: _SortedMatchList(
                matches: matches,
                currentUserId: widget.currentUserId,
                isDark: isDark,
              ),
            ),
          );
        },
      ),
    );
  }

  Stream<List<QuerySnapshot>> _getMatchesStream() {
    final s1 = FirebaseFirestore.instance
        .collection('matches')
        .where('user1Id', isEqualTo: widget.currentUserId)
        .where('isActive', isEqualTo: true)
        .snapshots();

    final s2 = FirebaseFirestore.instance
        .collection('matches')
        .where('user2Id', isEqualTo: widget.currentUserId)
        .where('isActive', isEqualTo: true)
        .snapshots();

    return s1.asyncExpand((snap1) => s2.map((snap2) => [snap1, snap2]));
  }
}

// ✅ WIDGET SÉPARÉ POUR GÉRER LE TRI
class _SortedMatchList extends StatefulWidget {
  final List<DocumentSnapshot> matches;
  final String currentUserId;
  final bool isDark;

  const _SortedMatchList({
    required this.matches,
    required this.currentUserId,
    required this.isDark,
  });

  @override
  State<_SortedMatchList> createState() => _SortedMatchListState();
}

class _SortedMatchListState extends State<_SortedMatchList> {
  static const primaryColor = Color(0xFF6F61EF);
  static const secondaryColor = Color(0xFF39D2C0);

  final Map<String, DateTime> _chatTimestamps = {};
  final List<StreamSubscription> _subscriptions = [];

  bool _isDisposed = false;
  int _maxListeners = 25; // ✅ Valeur par défaut

  @override
  void initState() {
    super.initState();
    // ✅ NE RIEN FAIRE ICI - attendre didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ C'EST ICI QU'ON PEUT UTILISER MediaQuery
    if (_subscriptions.isEmpty) {
      // Calculer maxListeners UNE SEULE FOIS
      _maxListeners = _ResponsiveHelper.isDesktop(context)
          ? 50
          : (_ResponsiveHelper.isTablet(context) ? 35 : 25);

      _setupChatListeners();
    }
  }

  @override
  void dispose() {
    print(
        '🧹 Disposing _SortedMatchList - Annulation de ${_subscriptions.length} listeners');

    _isDisposed = true;

    for (var sub in _subscriptions) {
      try {
        sub.cancel();
      } catch (e) {
        print('⚠️ Erreur annulation listener: $e');
      }
    }
    _subscriptions.clear();
    _chatTimestamps.clear();

    print('✅ _SortedMatchList disposed proprement');
    super.dispose();
  }

  void _setupChatListeners() {
    // ✅ NETTOYER LES ANCIENS LISTENERS
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    print('📡 Configuration de ${widget.matches.length} listeners de chat');

    int listenerCount = 0;

    for (var match in widget.matches) {
      if (listenerCount >= _maxListeners) {
        print('⚠️ LIMITE ATTEINTE: $_maxListeners listeners maximum');
        break;
      }

      final data = match.data() as Map<String, dynamic>;
      final chatId = data['matchId']?.toString() ?? match.id;

      final subscription = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .snapshots()
          .listen(
        (snapshot) {
          if (!_isDisposed && mounted && snapshot.exists) {
            final chatData = snapshot.data() as Map<String, dynamic>;
            final timestamp = chatData['lastMessageTime'] as Timestamp?;

            if (timestamp != null) {
              setState(() {
                _chatTimestamps[chatId] = timestamp.toDate();
              });
            }
          }
        },
        onError: (error) {
          print('❌ Erreur listener chat $chatId: $error');
        },
        cancelOnError: false,
      );

      _subscriptions.add(subscription);
      listenerCount++;
    }

    print(
        '✅ ${_subscriptions.length} listeners configurés (max $_maxListeners)');
  }

  @override
  void didUpdateWidget(_SortedMatchList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.matches.length != widget.matches.length) {
      print(
          '🔄 Nombre de matches changé: ${oldWidget.matches.length} → ${widget.matches.length}');
      _setupChatListeners();
    }
  }

  List<DocumentSnapshot> _getSortedMatches() {
    final sorted = List<DocumentSnapshot>.from(widget.matches);

    sorted.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      final chatIdA = dataA['matchId']?.toString() ?? a.id;
      final chatIdB = dataB['matchId']?.toString() ?? b.id;

      final timeA = _chatTimestamps[chatIdA] ??
          (dataA['matchedAt'] as Timestamp?)?.toDate() ??
          DateTime(2000);
      final timeB = _chatTimestamps[chatIdB] ??
          (dataB['matchedAt'] as Timestamp?)?.toDate() ??
          DateTime(2000);

      return timeB.compareTo(timeA);
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return SizedBox.shrink();
    }

    final sortedMatches = _getSortedMatches();

    if (_ResponsiveHelper.isDesktop(context) && sortedMatches.length > 10) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 16,
        ),
        itemCount: sortedMatches.length,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final data = sortedMatches[index].data() as Map<String, dynamic>;
          return _MatchCard(
            matchId: sortedMatches[index].id,
            data: data,
            currentUserId: widget.currentUserId,
            isDark: widget.isDark,
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: sortedMatches.length,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final data = sortedMatches[index].data() as Map<String, dynamic>;
          return _MatchCard(
            matchId: sortedMatches[index].id,
            data: data,
            currentUserId: widget.currentUserId,
            isDark: widget.isDark,
          );
        },
      );
    }
  }
}

// ✅ WIDGET POUR CHAQUE CARD DE MATCH (AVEC TOUTES LES FONCTIONNALITÉS)
class _MatchCard extends StatelessWidget {
  final String matchId;
  final Map<String, dynamic> data;
  final String currentUserId;
  final bool isDark;

  const _MatchCard({
    required this.matchId,
    required this.data,
    required this.currentUserId,
    required this.isDark,
  });

  static const primaryColor = Color(0xFF6F61EF);
  static const secondaryColor = Color(0xFF39D2C0);

  @override
  Widget build(BuildContext context) {
    final user1Id = data['user1Id']?.toString() ?? '';
    final user2Id = data['user2Id']?.toString() ?? '';
    final otherId = user1Id == currentUserId ? user2Id : user1Id;

    if (otherId.isEmpty) {
      return const SizedBox.shrink();
    }

    final chatId = data['matchId']?.toString() ?? matchId;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(otherId)
          .snapshots(),
      builder: (context, userSnapshot) {
        String displayName = 'Chargement...';
        String? photoUrl;

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          displayName = userData['display_name'] ??
              userData['displayName'] ??
              userData['name'] ??
              'Utilisateur';
          photoUrl = userData['photo_url'] ?? userData['photoUrl'];
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .snapshots(),
          builder: (context, chatSnap) {
            String lastMsg = 'Nouveau match';
            DateTime? lastTime = (data['matchedAt'] as Timestamp?)?.toDate();
            String senderId = '';
            String msgType = 'text';
            int unreadCount = 0;

            if (chatSnap.hasData && chatSnap.data!.exists) {
              final chatData = chatSnap.data!.data() as Map<String, dynamic>;
              lastMsg = chatData['lastMessage']?.toString() ?? 'Nouveau match';
              lastTime =
                  (chatData['lastMessageTime'] as Timestamp?)?.toDate() ??
                      lastTime;
              senderId = chatData['lastMessageSenderId']?.toString() ?? '';
              msgType = chatData['lastMessageType']?.toString() ?? 'text';
              unreadCount = chatData['unreadCount_$currentUserId'] ?? 0;
            }

            return Dismissible(
              key: Key(matchId),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return await _showBlockDialog(context, displayName);
                } else if (direction == DismissDirection.endToStart) {
                  return await _showReportDialog(context, displayName);
                }
                return false;
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  _blockUser(
                      context, otherId, displayName, matchId, currentUserId);
                }
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: _ResponsiveHelper.horizontalPadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block,
                      color: Colors.white,
                      size: _ResponsiveHelper.value(
                        context,
                        mobile: 28,
                        tablet: 32,
                        desktop: 36,
                      ),
                    ),
                    SizedBox(height: _ResponsiveHelper.spacing(context, 4)),
                    Text(
                      'Bloquer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: _ResponsiveHelper.fontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                color: Colors.orange,
                alignment: Alignment.centerRight,
                padding: _ResponsiveHelper.horizontalPadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: _ResponsiveHelper.value(
                        context,
                        mobile: 28,
                        tablet: 32,
                        desktop: 36,
                      ),
                    ),
                    SizedBox(height: _ResponsiveHelper.spacing(context, 4)),
                    Text(
                      'Signaler',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: _ResponsiveHelper.fontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
              child: Material(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                child: InkWell(
                  onTap: () => _openChat(
                      context, chatId, otherId, displayName, currentUserId),
                  onLongPress: () =>
                      _showProfile(context, otherId, displayName),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _ResponsiveHelper.value(
                        context,
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),
                      vertical: _ResponsiveHelper.value(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? const Color(0xFF3A3A3A)
                              : const Color(0xFFE5E5E5),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: _ResponsiveHelper.avatarRadius(context),
                              backgroundColor: primaryColor.withOpacity(0.1),
                              backgroundImage:
                                  photoUrl != null && photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                              child: photoUrl == null || photoUrl.isEmpty
                                  ? Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : 'E',
                                      style: TextStyle(
                                        fontSize: _ResponsiveHelper.fontSize(
                                            context, 20),
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    )
                                  : null,
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(
                                    _ResponsiveHelper.value(
                                      context,
                                      mobile: 4,
                                      tablet: 5,
                                      desktop: 6,
                                    ),
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: _ResponsiveHelper.value(
                                      context,
                                      mobile: 20,
                                      tablet: 22,
                                      desktop: 24,
                                    ),
                                    minHeight: _ResponsiveHelper.value(
                                      context,
                                      mobile: 20,
                                      tablet: 22,
                                      desktop: 24,
                                    ),
                                  ),
                                  child: Text(
                                    unreadCount > 9 ? '9+' : '$unreadCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: _ResponsiveHelper.spacing(context, 12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize:
                                      _ResponsiveHelper.fontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                  height:
                                      _ResponsiveHelper.spacing(context, 4)),
                              Row(
                                children: [
                                  if (senderId == currentUserId &&
                                      lastMsg.isNotEmpty) ...[
                                    Icon(
                                      Icons.done_all,
                                      size: _ResponsiveHelper.value(
                                        context,
                                        mobile: 16,
                                        tablet: 18,
                                        desktop: 20,
                                      ),
                                      color: secondaryColor,
                                    ),
                                    SizedBox(
                                        width: _ResponsiveHelper.spacing(
                                            context, 4)),
                                  ],
                                  Expanded(
                                    child: Text(
                                      _preview(lastMsg, msgType),
                                      style: TextStyle(
                                        fontSize: _ResponsiveHelper.fontSize(
                                            context, 14),
                                        fontWeight: unreadCount > 0
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: unreadCount > 0
                                            ? (isDark
                                                ? Colors.white
                                                : Colors.black87)
                                            : (isDark
                                                ? const Color(0xFFB0B0B0)
                                                : const Color(0xFF606A85)),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: _ResponsiveHelper.spacing(context, 8)),
                        Text(
                          _formatTime(lastTime),
                          style: TextStyle(
                            fontSize: _ResponsiveHelper.fontSize(context, 12),
                            color: isDark
                                ? const Color(0xFFB0B0B0)
                                : const Color(0xFF606A85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _preview(String msg, String type) {
    if (msg.isEmpty) return 'Nouveau match';
    switch (type) {
      case 'image':
        return '📷 Photo';
      case 'voice':
        return '🎤 Message vocal';
      case 'video':
        return '🎥 Vidéo';
      default:
        return msg;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24 && dt.day == now.day) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) {
      final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _openChat(BuildContext context, String chatId, String otherId,
      String name, String currentUserId) async {
    try {
      // ✅ ÉTAPE 1 : Vérifier que le chat existe
      print('🔍 Tentative d\'ouverture du chat: $chatId');

      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();

      if (!chatDoc.exists) {
        print('❌ Chat inexistant: $chatId');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conversation introuvable',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cette conversation n\'existe plus. Elle a peut-être été supprimée.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      // ✅ ÉTAPE 2 : Vérifier les permissions
      final chatData = chatDoc.data() as Map<String, dynamic>;
      final participants = chatData['participants'] as List<dynamic>? ?? [];

      if (!participants.contains(currentUserId)) {
        print('❌ Utilisateur non autorisé: $currentUserId');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.block, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Vous n\'avez pas accès à cette conversation'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      // ✅ ÉTAPE 3 : Vérifier si le chat est bloqué
      final isBlocked = chatData['isBlocked'] ?? false;

      if (isBlocked) {
        print('❌ Chat bloqué');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.block, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Cette conversation est bloquée'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      print('✅ Chat accessible, navigation...');

      // ✅ ÉTAPE 4 : Naviguer vers le chat
      await navigateToChatPage(context, chatId, otherId, name, currentUserId);
    } catch (e, stackTrace) {
      print('❌ Erreur ouverture chat: $e');
      print('Stack: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Erreur d\'accès',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        e.toString().contains('permission')
                            ? 'Permissions insuffisantes'
                            : 'Impossible d\'ouvrir la conversation',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showProfile(
      BuildContext context, String userId, String userName) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profil introuvable'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            final photoUrl = userData['photo_url'] ?? userData['photoUrl'];
            final displayName = userData['display_name'] ??
                userData['displayName'] ??
                userData['name'] ??
                userName;
            final age = userData['age']?.toString() ?? '';
            final bio = userData['bio'] ?? userData['Bio'] ?? '';
            final location = userData['location'] ?? userData['ville'] ?? '';

            final modalHeight = _ResponsiveHelper.value(
              context,
              mobile: MediaQuery.of(context).size.height * 0.85,
              tablet: MediaQuery.of(context).size.height * 0.80,
              desktop: MediaQuery.of(context).size.height * 0.75,
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: _ResponsiveHelper.spacing(context, 12),
                    ),
                    child: Container(
                      width: _ResponsiveHelper.value(
                        context,
                        mobile: 40,
                        tablet: 50,
                        desktop: 60,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: _ResponsiveHelper.value(
                              context,
                              mobile: 400,
                              tablet: 500,
                              desktop: 600,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                            ),
                            child: photoUrl != null && photoUrl.isNotEmpty
                                ? Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Icon(
                                        Icons.person,
                                        size: _ResponsiveHelper.value(
                                          context,
                                          mobile: 100,
                                          tablet: 120,
                                          desktop: 150,
                                        ),
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      displayName[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: _ResponsiveHelper.value(
                                          context,
                                          mobile: 120,
                                          tablet: 150,
                                          desktop: 180,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(
                              _ResponsiveHelper.value(
                                context,
                                mobile: 20,
                                tablet: 28,
                                desktop: 36,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: _ResponsiveHelper.fontSize(
                                              context, 28),
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
                                          horizontal: _ResponsiveHelper.value(
                                            context,
                                            mobile: 16,
                                            tablet: 20,
                                            desktop: 24,
                                          ),
                                          vertical: _ResponsiveHelper.value(
                                            context,
                                            mobile: 8,
                                            tablet: 10,
                                            desktop: 12,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '$age ans',
                                          style: TextStyle(
                                            fontSize:
                                                _ResponsiveHelper.fontSize(
                                                    context, 16),
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (location.isNotEmpty) ...[
                                  SizedBox(
                                      height: _ResponsiveHelper.spacing(
                                          context, 12)),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: _ResponsiveHelper.value(
                                          context,
                                          mobile: 18,
                                          tablet: 20,
                                          desktop: 22,
                                        ),
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                      SizedBox(
                                          width: _ResponsiveHelper.spacing(
                                              context, 4)),
                                      Text(
                                        location,
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
                                if (bio.isNotEmpty) ...[
                                  SizedBox(
                                      height: _ResponsiveHelper.spacing(
                                          context, 24)),
                                  Text(
                                    'À propos',
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 18),
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(
                                      height: _ResponsiveHelper.spacing(
                                          context, 8)),
                                  Text(
                                    bio,
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 15),
                                      height: 1.5,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                                SizedBox(
                                    height:
                                        _ResponsiveHelper.spacing(context, 80)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(
                      _ResponsiveHelper.value(
                        context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: Size(
                            double.infinity,
                            _ResponsiveHelper.value(
                              context,
                              mobile: 50,
                              tablet: 56,
                              desktop: 60,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    } catch (e) {
      debugPrint('❌ Erreur affichage profil: $e');
    }
  }

  Future<bool> _showBlockDialog(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  Icons.block,
                  color: Colors.red,
                  size: _ResponsiveHelper.value(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                ),
                SizedBox(width: _ResponsiveHelper.spacing(context, 8)),
                Text(
                  'Bloquer ?',
                  style: TextStyle(
                    fontSize: _ResponsiveHelper.fontSize(context, 18),
                  ),
                ),
              ],
            ),
            content: Text(
              'Voulez-vous bloquer $name ?',
              style: TextStyle(
                fontSize: _ResponsiveHelper.fontSize(context, 15),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: _ResponsiveHelper.fontSize(context, 15),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(
                    _ResponsiveHelper.value(
                      context,
                      mobile: 80,
                      tablet: 100,
                      desktop: 120,
                    ),
                    _ResponsiveHelper.value(
                      context,
                      mobile: 40,
                      tablet: 44,
                      desktop: 48,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Bloquer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _ResponsiveHelper.fontSize(context, 15),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showReportDialog(BuildContext context, String name) async {
    String? selectedReason;
    final reasons = [
      'Comportement inapproprié',
      'Contenu offensant',
      'Faux profil',
      'Spam',
      'Harcèlement',
      'Autre'
    ];

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.flag,
                    color: Colors.orange,
                    size: _ResponsiveHelper.value(
                      context,
                      mobile: 24,
                      tablet: 28,
                      desktop: 32,
                    ),
                  ),
                  SizedBox(width: _ResponsiveHelper.spacing(context, 8)),
                  Expanded(
                    child: Text(
                      'Signaler',
                      style: TextStyle(
                        fontSize: _ResponsiveHelper.fontSize(context, 18),
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pourquoi signalez-vous $name ?',
                    style: TextStyle(
                      fontSize: _ResponsiveHelper.fontSize(context, 15),
                    ),
                  ),
                  SizedBox(height: _ResponsiveHelper.spacing(context, 16)),
                  ...reasons.map((reason) => RadioListTile<String>(
                        title: Text(
                          reason,
                          style: TextStyle(
                            fontSize: _ResponsiveHelper.fontSize(context, 14),
                          ),
                        ),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: Colors.orange,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) =>
                            setState(() => selectedReason = value),
                      )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: _ResponsiveHelper.fontSize(context, 15),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedReason == null ? Colors.grey : Colors.orange,
                    minimumSize: Size(
                      _ResponsiveHelper.value(
                        context,
                        mobile: 80,
                        tablet: 100,
                        desktop: 120,
                      ),
                      _ResponsiveHelper.value(
                        context,
                        mobile: 40,
                        tablet: 44,
                        desktop: 48,
                      ),
                    ),
                  ),
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          _reportUser(
                              context, name, selectedReason!, currentUserId);
                          Navigator.pop(dialogContext, false);
                        },
                  child: Text(
                    'Signaler',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _ResponsiveHelper.fontSize(context, 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _reportUser(BuildContext context, String userName, String reason,
      String currentUserId) async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reportedBy': currentUserId,
        'reportedUser': userName,
        'reason': reason,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$userName a été signalé'),
              backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      debugPrint('Erreur signalement: $e');
    }
  }

  void _blockUser(BuildContext context, String userId, String userName,
      String matchId, String currentUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('blockedUsers')
          .doc(userId)
          .set({
        'blockedUserId': userId,
        'blockedUserName': userName,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .update({
        'isActive': false,
        'blockedBy': currentUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$userName a été bloqué'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Erreur blocage: $e');
    }
  }
}

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
// ═══════════════════════════════════════════════════════════════
// PROFILE PAGE WIDGET
// Affiche le profil détaillé d'un utilisateur
// Adapté au thème de votre app de rencontres
// ═══════════════════════════════════════════════════════════════

class ProfilePageWidget1 extends StatefulWidget {
  const ProfilePageWidget1({
    Key? key,
    this.width,
    this.height,
    required this.userId, // ID du profil à afficher
    required this.currentUserId, // ID de l'utilisateur connecté
    this.showActions = true, // Afficher les boutons like/chat
    this.isFromMatch = false, // Si c'est un match existant
  }) : super(key: key);

  final double? width;
  final double? height;
  final String userId;
  final String currentUserId;
  final bool showActions;
  final bool isFromMatch;

  @override
  State<ProfilePageWidget1> createState() => _ProfilePageWidget1State();
}

class _ProfilePageWidget1State extends State<ProfilePageWidget1> {
  PageController _pageController = PageController();
  int _currentPhotoIndex = 0;
  bool isLoading = true;
  Map<String, dynamic>? userData;
  bool isLiked = false;
  bool isMatched = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkMatchStatus();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement profil: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _checkMatchStatus() async {
    try {
      // Vérifie si match existe
      final matchId1 = '${widget.currentUserId}_${widget.userId}';
      final matchId2 = '${widget.userId}_${widget.currentUserId}';

      final match1 = await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId1)
          .get();

      final match2 = await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId2)
          .get();

      if (mounted) {
        setState(() {
          isMatched = match1.exists || match2.exists;
        });
      }

      // Vérifie si déjà liké
      final like = await FirebaseFirestore.instance
          .collection('likes_given')
          .doc('${widget.currentUserId}_${widget.userId}')
          .get();

      if (mounted) {
        setState(() {
          isLiked = like.exists;
        });
      }
    } catch (e) {
      print('❌ Erreur vérification match: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (userData == null) {
      return _buildErrorState();
    }

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          _buildContent(),
          _buildTopBar(),
          if (widget.showActions && !isMatched) _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoGallery(),
          _buildInfoSection(),
          _buildBioSection(),
          _buildDetailsSection(),
          const SizedBox(height: 100), // Espace pour les boutons
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          right: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
            const Spacer(),
            if (isMatched)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Match',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    final photos = _getPhotos();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPhotoIndex = index);
            },
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Image.network(
                photos[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child:
                      const Icon(Icons.person, size: 100, color: Colors.grey),
                ),
              );
            },
          ),
          // Indicateurs de page
          if (photos.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPhotoIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    // 🔥 LECTURE DE TOUS LES CHAMPS POSSIBLES
    final name = userData!['display_name'] ??
        userData!['displayName'] ??
        userData!['name'] ??
        userData!['firstName'] ??
        'Utilisateur';
    final age = userData!['age']?.toString() ?? '?';

    // Ville/Localisation avec variantes
    final location = userData!['location'] ??
        userData!['city'] ??
        userData!['ville'] ??
        userData!['address'] ??
        '';

    final isPremium = userData!['isSubscribed'] ??
        userData!['isUserSubscribed'] ??
        userData!['isPremium'] ??
        false;

    // Distance (si disponible)
    final distance = userData!['distance']?.toString() ?? '';

    // Statut en ligne
    final isOnline = userData!['isOnline'] ?? false;
    final lastSeen = userData!['lastSeen'] as Timestamp?;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom + Âge + Badge Premium
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name, $age',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // 🔥 NOUVEAU : Statut en ligne
                    if (isOnline) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'En ligne',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else if (lastSeen != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Vu(e) ${_formatLastSeen(lastSeen)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.diamond, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Ville/Localisation
          if (location.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
                // 🔥 NOUVEAU : Distance si disponible
                if (distance.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$distance km',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 🔥 NOUVELLE MÉTHODE : Formater le "dernière connexion"
  String _formatLastSeen(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'à l\'instant';
    if (difference.inMinutes < 60) return 'il y a ${difference.inMinutes}min';
    if (difference.inHours < 24) return 'il y a ${difference.inHours}h';
    if (difference.inDays == 1) return 'hier';
    if (difference.inDays < 7) return 'il y a ${difference.inDays}j';
    return 'il y a longtemps';
  }

  Widget _buildBioSection() {
    final bio = userData!['bio'] ?? '';
    if (bio.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFE91E63), size: 20),
              SizedBox(width: 8),
              Text(
                'À propos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio,
            style:
                TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    // 🔥 CHAMPS SIMPLIFIÉS
    final gender = userData!['gender'] ?? '';
    final relationshipType = userData!['relationshipType'] ??
        userData!['relationship_type'] ??
        userData!['relationshipGoal'] ??
        '';

    // Si aucun champ à afficher, ne pas afficher la section
    if (gender.isEmpty && relationshipType.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFE91E63), size: 22),
              SizedBox(width: 8),
              Text(
                'Informations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sexe
          if (gender.isNotEmpty) ...[
            _buildDetailItem(Icons.person, 'Sexe', gender),
            const SizedBox(height: 16),
          ],

          // Type de relation
          if (relationshipType.isNotEmpty) ...[
            _buildDetailItem(
                Icons.favorite_border, 'Type de relation', relationshipType),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFE91E63), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.close,
              color: Colors.red,
              onPressed: () => Navigator.pop(context),
            ),
            _buildActionButton(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              color: const Color(0xFFE91E63),
              size: 70,
              onPressed: _handleLike,
            ),
            _buildActionButton(
              icon: Icons.message,
              color: const Color(0xFF2196F3),
              onPressed: _handleMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 60,
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }

  void _handleLike() async {
    if (isLiked) {
      _showSnackbar('Vous avez déjà liké ce profil', Colors.orange);
      return;
    }

    try {
      // Créer le like
      await FirebaseFirestore.instance
          .collection('likes_given')
          .doc('${widget.currentUserId}_${widget.userId}')
          .set({
        'giverId': widget.currentUserId,
        'receiverId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Créer la notification
      await FirebaseFirestore.instance
          .collection('likes_received')
          .doc('${widget.userId}_${widget.currentUserId}')
          .set({
        'receiverId': widget.userId,
        'giverId': widget.currentUserId,
        'giverName': userData!['display_name'] ?? 'Quelqu\'un',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      setState(() => isLiked = true);
      _showSnackbar('Like envoyé ! 💕', Colors.green);

      // Retourner à la page précédente après 1 seconde
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Erreur like: $e');
      _showSnackbar('Erreur lors du like', Colors.red);
    }
  }

  void _handleMessage() {
    if (!isMatched) {
      _showSnackbar(
          'Vous devez matcher avant d\'envoyer un message', Colors.orange);
      return;
    }

    // Navigation vers ChatPage
    try {
      final matchId = _generateMatchId(widget.currentUserId, widget.userId);
      context.pushNamed(
        'ChatPage',
        queryParameters: {
          'chatId': matchId,
          'otherUserId': widget.userId,
          'otherUserName': userData!['display_name'] ?? 'Utilisateur',
        },
      );
    } catch (e) {
      print('❌ Erreur navigation chat: $e');
    }
  }

  String _generateMatchId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  List<String> _getPhotos() {
    final List<String> photos = [];

    // Photo principale
    final mainPhoto = userData!['photo_url'] ??
        userData!['photoUrl'] ??
        userData!['imageUrl'] ??
        '';
    if (mainPhoto.isNotEmpty) photos.add(mainPhoto);

    // Photos additionnelles
    final additionalPhotos = userData!['photos'] as List<dynamic>? ?? [];
    for (var photo in additionalPhotos) {
      if (photo is String && photo.isNotEmpty) {
        photos.add(photo);
      }
    }

    return photos.isEmpty ? [''] : photos;
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFE91E63)),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Profil introuvable',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63)),
              child:
                  const Text('Retour', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

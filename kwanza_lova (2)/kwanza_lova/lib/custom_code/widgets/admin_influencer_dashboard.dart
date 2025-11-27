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

class AdminInfluencerDashboard extends StatefulWidget {
  const AdminInfluencerDashboard({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  _AdminInfluencerDashboardState createState() =>
      _AdminInfluencerDashboardState();
}

class _AdminInfluencerDashboardState extends State<AdminInfluencerDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _influencers = [];
  Map<String, dynamic> _globalStats = {};
  String? _error;
  String _sortBy = 'totalSignups';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final influencersQuery = await _firestore
          .collection('influencers')
          .orderBy('stats.totalSignups', descending: true)
          .limit(100) // ✅ LIMITE AJOUTÉE
          .get();

      _influencers = influencersQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _calculateGlobalStats();

      setState(() {
        _isLoading = false;
      });

      print('✅ ${_influencers.length} influenceurs chargés (max 100)');
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateGlobalStats() {
    int totalInfluencers = _influencers.length;
    int totalSignups = 0;
    int totalActiveUsers = 0;
    double totalAdRevenue = 0.0;
    int totalPremiumConversions = 0;

    for (var influencer in _influencers) {
      final stats = influencer['stats'] ?? {};
      totalSignups += (stats['totalSignups'] ?? 0) as int;
      totalActiveUsers += (stats['activeUsers'] ?? 0) as int;
      totalAdRevenue += (stats['totalAdRevenue'] ?? 0.0) as double;
      totalPremiumConversions += (stats['premiumConversions'] ?? 0) as int;
    }

    _globalStats = {
      'totalInfluencers': totalInfluencers,
      'totalSignups': totalSignups,
      'totalActiveUsers': totalActiveUsers,
      'totalAdRevenue': totalAdRevenue,
      'totalPremiumConversions': totalPremiumConversions,
      'averageSignupsPerInfluencer': totalInfluencers > 0
          ? (totalSignups / totalInfluencers).toStringAsFixed(1)
          : '0',
    };
  }

  void _sortInfluencers(String sortField) {
    setState(() {
      if (_sortBy == sortField) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortField;
        _sortAscending = false;
      }

      _influencers.sort((a, b) {
        final aStats = a['stats'] ?? {};
        final bStats = b['stats'] ?? {};

        dynamic aValue, bValue;

        switch (sortField) {
          case 'name':
            aValue = a['name'] ?? '';
            bValue = b['name'] ?? '';
            break;
          case 'totalSignups':
            aValue = aStats['totalSignups'] ?? 0;
            bValue = bStats['totalSignups'] ?? 0;
            break;
          case 'activeUsers':
            aValue = aStats['activeUsers'] ?? 0;
            bValue = bStats['activeUsers'] ?? 0;
            break;
          case 'adRevenue':
            aValue = aStats['totalAdRevenue'] ?? 0.0;
            bValue = bStats['totalAdRevenue'] ?? 0.0;
            break;
          case 'tier':
            aValue = a['tier'] ?? 'bronze';
            bValue = b['tier'] ?? 'bronze';
            break;
          default:
            aValue = aStats['totalSignups'] ?? 0;
            bValue = bStats['totalSignups'] ?? 0;
        }

        if (_sortAscending) {
          return Comparable.compare(aValue, bValue);
        } else {
          return Comparable.compare(bValue, aValue);
        }
      });
    });
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return Color(0xFFE5E4E2);
      case 'gold':
        return Color(0xFFFFD700);
      case 'silver':
        return Color(0xFFC0C0C0);
      default:
        return Color(0xFFCD7F32);
    }
  }

  String _getTierBadge(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return '💎';
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      default:
        return '🥉';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F61EF)),
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildGlobalStats(),
              SizedBox(height: 24),
              _buildTopPerformers(),
              SizedBox(height: 24),
              _buildInfluencersTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(
        _ResponsiveHelper.value(context, mobile: 24, tablet: 28, desktop: 32),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F61EF), Color(0xFF39D2C0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6F61EF).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _ResponsiveHelper.fontSize(context, 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Performance des Influenceurs',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques Globales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Influenceurs',
                '${_globalStats['totalInfluencers'] ?? 0}',
                Icons.people,
                Color(0xFF6F61EF),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Inscriptions',
                '${_globalStats['totalSignups'] ?? 0}',
                Icons.person_add,
                Color(0xFF39D2C0),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Utilisateurs Actifs',
                '${_globalStats['totalActiveUsers'] ?? 0}',
                Icons.online_prediction,
                Color(0xFF4CAF50),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Revenus Pub Total',
                '${(_globalStats['totalAdRevenue'] ?? 0.0).toStringAsFixed(2)} \$',
                Icons.monetization_on,
                Color(0xFFFFB340),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF6F61EF).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF6F61EF), size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moyenne par Influenceur',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_globalStats['averageSignupsPerInfluencer'] ?? '0'} inscriptions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F61EF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    final topPerformers = _influencers.take(5).toList();

    if (topPerformers.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
              SizedBox(width: 12),
              Text(
                'Top 5 Performeurs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...topPerformers.asMap().entries.map((entry) {
            final index = entry.key;
            final influencer = entry.value;
            final stats = influencer['stats'] ?? {};
            final signups = stats['totalSignups'] ?? 0;
            final revenue = stats['totalAdRevenue'] ?? 0.0;

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6F61EF), Color(0xFF39D2C0)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          influencer['name'] ?? 'Inconnu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$signups inscriptions • ${revenue.toStringAsFixed(2)}\$',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _getTierBadge(influencer['tier'] ?? 'bronze'),
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfluencersTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Tous les Influenceurs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildHeaderCell('Nom', 'name'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell('Niveau', 'tier'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell('Inscriptions', 'totalSignups'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell('Actifs', 'activeUsers'),
                ),
                Expanded(
                  flex: 1,
                  child: _buildHeaderCell('Rev. Pub', 'adRevenue'),
                ),
                SizedBox(width: 50),
              ],
            ),
          ),
          if (_influencers.isEmpty)
            Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Aucun influenceur enregistré',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _influencers.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final influencer = _influencers[index];
                final stats = influencer['stats'] ?? {};
                final tier = influencer['tier'] ?? 'bronze';
                final promoCode = influencer['promoCode'] ?? '';
                final isActive = influencer['isActive'] ?? false;

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color:
                                        isActive ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    influencer['name'] ?? 'Sans nom',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              promoCode,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6F61EF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Text(_getTierBadge(tier),
                                style: TextStyle(fontSize: 18)),
                            SizedBox(width: 4),
                            Text(
                              tier.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getTierColor(tier),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${stats['totalSignups'] ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${stats['activeUsers'] ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${(stats['totalAdRevenue'] ?? 0.0).toStringAsFixed(2)}\$',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFFFFB340),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            _handleAction(value, influencer);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'details',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  SizedBox(width: 8),
                                  Text('Voir détails'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: isActive ? 'deactivate' : 'activate',
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? Icons.block : Icons.check_circle,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(isActive ? 'Désactiver' : 'Activer'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, String sortField) {
    final isActive = _sortBy == sortField;

    return InkWell(
      onTap: () => _sortInfluencers(sortField),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isActive ? Color(0xFF6F61EF) : Colors.grey[700],
            ),
          ),
          if (isActive) ...[
            SizedBox(width: 4),
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: Color(0xFF6F61EF),
            ),
          ],
        ],
      ),
    );
  }

  void _handleAction(String action, Map<String, dynamic> influencer) {
    switch (action) {
      case 'details':
        _showInfluencerDetails(influencer);
        break;
      case 'activate':
      case 'deactivate':
        _toggleInfluencerStatus(influencer);
        break;
    }
  }

  void _showInfluencerDetails(Map<String, dynamic> influencer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails Influenceur'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nom', influencer['name'] ?? ''),
              _buildDetailRow('Email', influencer['email'] ?? ''),
              _buildDetailRow('Téléphone', influencer['phoneNumber'] ?? ''),
              _buildDetailRow('Code Promo', influencer['promoCode'] ?? ''),
              _buildDetailRow('Niveau', influencer['tier'] ?? ''),
              Divider(),
              Text('Statistiques',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildDetailRow('Inscriptions',
                  '${influencer['stats']?['totalSignups'] ?? 0}'),
              _buildDetailRow(
                  'Actifs', '${influencer['stats']?['activeUsers'] ?? 0}'),
              _buildDetailRow('Revenus Pub',
                  '${(influencer['stats']?['totalAdRevenue'] ?? 0.0).toStringAsFixed(2)} \$'),
              _buildDetailRow('Rétention 7j',
                  '${((influencer['stats']?['retentionRate7Days'] ?? 0) * 100).toStringAsFixed(1)}%'),
              _buildDetailRow('Rétention 30j',
                  '${((influencer['stats']?['retentionRate30Days'] ?? 0) * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleInfluencerStatus(Map<String, dynamic> influencer) async {
    final currentStatus = influencer['isActive'] ?? false;

    try {
      await _firestore
          .collection('influencers')
          .doc(influencer['id'])
          .update({'isActive': !currentStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              !currentStatus ? 'Influenceur activé' : 'Influenceur désactivé'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      _loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

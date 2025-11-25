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
import 'package:flutter/services.dart';

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

class InfluencerDashboard extends StatefulWidget {
  const InfluencerDashboard({
    Key? key,
    this.width,
    this.height,
    required this.influencerId,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String influencerId;

  @override
  _InfluencerDashboardState createState() => _InfluencerDashboardState();
}

class _InfluencerDashboardState extends State<InfluencerDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _influencerData;
  List<Map<String, dynamic>> _recentSignups = [];
  List<Map<String, dynamic>> _performanceData = [];
  String? _error;

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
      final influencerDoc = await _firestore
          .collection('influencers')
          .doc(widget.influencerId)
          .get();

      if (!influencerDoc.exists) {
        setState(() {
          _error = 'Influenceur introuvable';
          _isLoading = false;
        });
        return;
      }

      _influencerData = influencerDoc.data();
      _influencerData!['id'] = influencerDoc.id;

      final yesterday = DateTime.now().subtract(Duration(hours: 24));
      final signupsQuery = await _firestore
          .collection('promo_signups')
          .where('influencerId', isEqualTo: widget.influencerId)
          .where('signupDate', isGreaterThan: yesterday)
          .orderBy('signupDate', descending: true)
          .limit(10)
          .get();

      _recentSignups = signupsQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      final performanceQuery = await _firestore
          .collection('influencer_performance')
          .where('influencerId', isEqualTo: widget.influencerId)
          .where('date', isGreaterThan: sevenDaysAgo)
          .orderBy('date', descending: false)
          .get();

      _performanceData = performanceQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: $e';
        _isLoading = false;
      });
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
              _buildStatsCards(),
              SizedBox(height: 24),
              _buildPerformanceSummary(),
              SizedBox(height: 24),
              _buildRecentSignups(),
              SizedBox(height: 24),
              _buildPromoCodeCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stats = _influencerData!['stats'] ?? {};
    final tier = _influencerData!['tier'] ?? 'bronze';

    return Container(
      padding: EdgeInsets.all(
        _ResponsiveHelper.value(context, mobile: 20, tablet: 24, desktop: 28),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _influencerData!['name'] ?? 'Influenceur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _ResponsiveHelper.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getTierColor(tier),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _getTierBadge(tier),
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 8),
                    Text(
                      tier.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Inscriptions',
                  '${stats['totalSignups'] ?? 0}',
                  Icons.person_add,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  'Actifs',
                  '${stats['activeUsers'] ?? 0}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = _influencerData!['stats'] ?? {};

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Inscriptions',
                '${stats['totalSignups'] ?? 0}',
                Icons.people,
                Color(0xFF6F61EF),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Utilisateurs Actifs',
                '${stats['activeUsers'] ?? 0}',
                Icons.online_prediction,
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
                'Revenus Pub',
                '${(stats['totalAdRevenue'] ?? 0).toStringAsFixed(2)} \$',
                Icons.monetization_on,
                Color(0xFFFFB340),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Rétention 7j',
                '${((stats['retentionRate7Days'] ?? 0) * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
                Color(0xFF4CAF50),
              ),
            ),
          ],
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    if (_performanceData.isEmpty) {
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
        child: Center(
          child: Text(
            'Pas encore de données de performance',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final totalRevenue = _performanceData.fold<double>(
      0.0,
      (sum, item) => sum + ((item['dailyRevenue'] ?? 0.0) as double),
    );

    final totalSignups = _performanceData.fold<int>(
      0,
      (sum, item) => sum + ((item['dailySignups'] ?? 0) as int),
    );

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
          Text(
            'Performance (7 derniers jours)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric(
                  'Inscriptions',
                  '$totalSignups',
                  Icons.person_add,
                  Color(0xFF6F61EF),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildPerformanceMetric(
                  'Revenus',
                  '${totalRevenue.toStringAsFixed(2)}\$',
                  Icons.monetization_on,
                  Color(0xFFFFB340),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),
          Text(
            'Détails journaliers',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          ..._performanceData.reversed.take(5).map((perf) {
            final date = (perf['date'] as Timestamp).toDate();
            final signups = (perf['dailySignups'] ?? 0) as int;
            final revenue = (perf['dailyRevenue'] ?? 0.0) as double;

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '$signups inscr. • ${revenue.toStringAsFixed(2)}\$',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSignups() {
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
              Text(
                'Inscriptions Récentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF6F61EF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_recentSignups.length} / 24h',
                  style: TextStyle(
                    color: Color(0xFF6F61EF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_recentSignups.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Aucune inscription ces dernières 24h',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _recentSignups.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final signup = _recentSignups[index];
                final signupDate = (signup['signupDate'] as Timestamp).toDate();
                final timeAgo = _getTimeAgo(signupDate);

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6F61EF), Color(0xFF39D2C0)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    'Nouveau membre',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: signup['isActive'] == true
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      signup['isActive'] == true ? 'Actif' : 'En attente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: signup['isActive'] == true
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeCard() {
    final promoCode = _influencerData!['promoCode'] ?? '';
    final expiresAt =
        (_influencerData!['codeExpiresAt'] as Timestamp?)?.toDate();
    final daysLeft =
        expiresAt != null ? expiresAt.difference(DateTime.now()).inDays : 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F61EF), Color(0xFF39D2C0)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6F61EF).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Votre Code Promo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    promoCode,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF6F61EF),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: Color(0xFF6F61EF)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: promoCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code copié !'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time,
                  color: Colors.white.withOpacity(0.9), size: 16),
              SizedBox(width: 8),
              Text(
                daysLeft > 0 ? 'Expire dans $daysLeft jours' : 'Code expiré',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }
}

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

class SubscriptionWidget extends StatefulWidget {
  const SubscriptionWidget({
    Key? key,
    this.width,
    this.height,
    required this.currentUserId,
    this.currency = 'USD',
  }) : super(key: key);

  final double? width;
  final double? height;
  final String currentUserId;
  final String currency;

  @override
  State<SubscriptionWidget> createState() => _SubscriptionWidgetState();
}

class _SubscriptionWidgetState extends State<SubscriptionWidget>
    with TickerProviderStateMixin {
  int selectedPlanIndex = 1;
  String selectedPaymentMethod = '';
  bool isProcessing = false;
  bool showOtpField = false;
  late AnimationController _animationController;
  late AnimationController _successAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String currentCurrency = 'USD';

  final TextEditingController inputController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  List<Map<String, dynamic>> plans = [];

  @override
  void initState() {
    super.initState();
    currentCurrency = widget.currency;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _successAnimationController, curve: Curves.elasticOut),
    );
  }

  Color get primaryColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF8B7EFF)
      : const Color(0xFF6F61EF);

  Color get secondaryColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF4DE6D0)
      : const Color(0xFF39D2C0);

  Color get tertiaryColor => const Color(0xFFEE8B60);

  Color get textColor =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  Color get textSecondaryColor =>
      Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
      Colors.grey;

  Color get cardColor => Theme.of(context).cardColor;

  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;

  void _initializePlans() {
    final double conversionRate = currentCurrency == 'EUR' ? 0.85 : 1.0;
    final String currencySymbol = currentCurrency == 'EUR' ? '€' : '\$';

    plans = [
      {
        'id': 'classic',
        'name': 'Classique',
        'emoji': '⭐',
        'price': currentCurrency == 'EUR' ? 4.99 * conversionRate : 4.99,
        'duration': 'mois',
        'currency': currentCurrency,
        'currencySymbol': currencySymbol,
        'color': secondaryColor,
        'lightColor': secondaryColor.withOpacity(0.1),
        'badge': 'ESSENTIEL',
        'isPopular': false,
        'features': [
          'Swipes illimités',
          'Messages texte illimités',
          'Profil vérifié',
          'Support client prioritaire',
        ],
      },
      {
        'id': 'premium',
        'name': 'Premium',
        'emoji': '💎',
        'price': currentCurrency == 'EUR' ? 9.99 * conversionRate : 9.99,
        'duration': 'mois',
        'currency': currentCurrency,
        'currencySymbol': currencySymbol,
        'color': primaryColor,
        'lightColor': primaryColor.withOpacity(0.1),
        'badge': 'POPULAIRE',
        'isPopular': true,
        'features': [
          'Boost 48h (2x plus de vues)',
          'Priorité dans les suggestions',
          'Badge premium sur votre profil',
          'Swipes illimités',
          'Messages texte illimités',
          'Messages vocaux',
          'Appels audio',
          'Voir qui vous a liké',
        ],
      },
      {
        'id': 'platinum',
        'name': 'Platinum',
        'emoji': '🥇',
        'price': currentCurrency == 'EUR' ? 99.9 * conversionRate : 99.9,
        'duration': 'an',
        'currency': currentCurrency,
        'currencySymbol': currencySymbol,
        'color': tertiaryColor,
        'lightColor': tertiaryColor.withOpacity(0.1),
        'badge': 'MEILLEURE OFFRE',
        'isPopular': false,
        'features': [
          'Boost 7 jours (5x plus de vues)',
          'Badge Gold exclusif',
          'Appels audio et vidéo illimités',
          'Mise en avant exclusive',
          'Super likes illimités',
          'Rewind illimité',
          'Passeport mondial',
          'Support VIP 24/7',
          '+ Tous les avantages Premium',
        ],
      },
    ];
  }

  Widget _buildCurrencySelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text('Devise: ',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(width: 8),
          ToggleButtons(
            isSelected: [currentCurrency == 'USD', currentCurrency == 'EUR'],
            onPressed: (index) {
              setState(() {
                currentCurrency = index == 0 ? 'USD' : 'EUR';
                plans = [];
                selectedPaymentMethod = '';
                showOtpField = false;
                inputController.clear();
                otpController.clear();
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: primaryColor,
            color: textColor,
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('USD (\$)')),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('EUR (€)')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      _initializePlans();
    }

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrencySelector(),
                _buildHeroSection(),
                const SizedBox(height: 32),
                _buildPlansSection(),
                const SizedBox(height: 24),
                if (selectedPaymentMethod.isNotEmpty) _buildPaymentForm(),
                const SizedBox(height: 32),
                _buildTrustSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    if (plans.isEmpty) return SizedBox.shrink();

    final selectedPlan = plans[selectedPlanIndex];
    final color = selectedPlan['color'] as Color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(selectedPlan['emoji'] as String,
                  style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Text(selectedPlan['name'] as String,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${selectedPlan['currencySymbol']}${selectedPlan['price'].toStringAsFixed(2)} ${selectedPlan['currency']}/${selectedPlan['duration']}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
          if (selectedPlan['duration'] == 'an')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Soit ${selectedPlan['currencySymbol']}${(selectedPlan['price'] / 12).toStringAsFixed(2)}/mois',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    if (plans.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choisissez votre plan',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 24),
        ...plans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          return _buildPlanCard(plan, index);
        }).toList(),
        const SizedBox(height: 24),
        if (selectedPlanIndex >= 0) _buildPaymentMethods(),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    final isSelected = selectedPlanIndex == index;
    final color = plan['color'] as Color;
    final lightColor = plan['lightColor'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
          selectedPaymentMethod = '';
          showOtpField = false;
          inputController.clear();
          otpController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ]
              : null,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(plan['emoji'] as String,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan['name'] as String,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? color : textColor)),
                      const SizedBox(height: 4),
                      Text(
                        '${plan['currencySymbol']}${plan['price'].toStringAsFixed(2)} ${plan['currency']} / ${plan['duration']}',
                        style: TextStyle(
                            fontSize: 16,
                            color: textSecondaryColor,
                            fontWeight: FontWeight.w500),
                      ),
                      if (plan['duration'] == 'an')
                        Text(
                          'Soit ${plan['currencySymbol']}${(plan['price'] / 12).toStringAsFixed(2)}/mois',
                          style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600),
                        )
                      else
                        Text(
                          '${(plan['features'] as List).length} fonctionnalités',
                          style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? color : Colors.grey,
                  size: 28,
                ),
              ],
            ),
            if (plan['isPopular'] as bool || plan['duration'] == 'an')
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        plan['duration'] == 'an' ? Colors.green : tertiaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(plan['badge'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Méthodes de paiement',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        _buildPaymentOption('Mobile Money', '📱', 'mpesa',
            'M-Pesa, Orange Money, Airtel Money'),
        _buildPaymentOption(
          'Carte Bancaire',
          '💳',
          'card',
          '⚠️ Non disponible (sécurité)',
          isDisabled: true,
        ),
        _buildPaymentOption(
            'PayPal', '🟦', 'paypal', 'Paiement sécurisé via PayPal'),
      ],
    );
  }

  Widget _buildPaymentOption(
      String name, String icon, String id, String description,
      {bool isDisabled = false}) {
    if (plans.isEmpty) return SizedBox.shrink();

    final isSelected = selectedPaymentMethod == id;
    final selectedPlan = plans[selectedPlanIndex];
    final color = selectedPlan['color'] as Color;
    final lightColor = selectedPlan['lightColor'] as Color;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                selectedPaymentMethod = id;
                showOtpField = false;
                inputController.clear();
                otpController.clear();
              });
            },
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? lightColor.withOpacity(0.3) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                    Text(description,
                        style:
                            TextStyle(fontSize: 12, color: textSecondaryColor)),
                  ],
                ),
              ),
              if (isSelected && !isDisabled)
                Icon(Icons.check_circle, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    if (plans.isEmpty) return SizedBox.shrink();

    final selectedPlan = plans[selectedPlanIndex];
    final color = selectedPlan['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations de paiement',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        TextFormField(
          controller: inputController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: _getInputLabel(),
            labelStyle: TextStyle(color: textSecondaryColor),
            hintText: _getInputHint(),
            hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.5)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            prefixIcon: Icon(_getInputIcon(), color: color),
            fillColor: cardColor,
            filled: true,
          ),
          keyboardType: _getInputType(),
        ),
        if (showOtpField && selectedPaymentMethod == 'mpesa') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: secondaryColor),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: secondaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Un code a été envoyé à votre téléphone',
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: otpController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Code de confirmation',
              labelStyle: TextStyle(color: textSecondaryColor),
              hintText: 'Entrez le code à 6 chiffres',
              hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.5)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              prefixIcon: Icon(Icons.lock_outline, color: color),
              fillColor: cardColor,
              filled: true,
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
            ),
            child: isProcessing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Traitement...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(selectedPlan['emoji'] as String,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        showOtpField && selectedPaymentMethod == 'mpesa'
                            ? 'Confirmer le paiement'
                            : 'Payer ${selectedPlan['currencySymbol']}${selectedPlan['price'].toStringAsFixed(2)} ${selectedPlan['currency']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: secondaryColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user, color: secondaryColor, size: 24),
              const SizedBox(width: 8),
              Text('Paiement 100% Sécurisé',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'En continuant, vous acceptez nos conditions.\nAnnulation possible à tout moment.',
            style: TextStyle(fontSize: 12, color: textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getInputLabel() {
    switch (selectedPaymentMethod) {
      case 'card':
        return 'Numéro de carte';
      case 'paypal':
        return 'Email PayPal';
      default:
        return 'Numéro de téléphone';
    }
  }

  String _getInputHint() {
    switch (selectedPaymentMethod) {
      case 'card':
        return '4242 4242 4242 4242';
      case 'paypal':
        return 'votre@email.com';
      default:
        return '+243 XXX XXX XXX';
    }
  }

  IconData _getInputIcon() {
    switch (selectedPaymentMethod) {
      case 'card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.email;
      default:
        return Icons.phone;
    }
  }

  TextInputType _getInputType() {
    switch (selectedPaymentMethod) {
      case 'card':
        return TextInputType.number;
      case 'paypal':
        return TextInputType.emailAddress;
      default:
        return TextInputType.phone;
    }
  }

  Future<void> _processPayment() async {
    if (plans.isEmpty) {
      _showErrorDialog('Erreur: plans non initialisés');
      return;
    }

    if (selectedPaymentMethod == 'mpesa' && !showOtpField) {
      if (!_validateInput()) return;

      setState(() {
        isProcessing = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        showOtpField = true;
        isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Code de confirmation envoyé !'),
            backgroundColor: secondaryColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (!_validateInput()) return;

    setState(() => isProcessing = true);

    try {
      final selectedPlan = plans[selectedPlanIndex];
      final transactionId = _generateTransactionId();

      String paymentMethodId = selectedPaymentMethod;
      if (selectedPaymentMethod == 'mpesa') {
        final phone = inputController.text.trim();
        if (phone.startsWith('+243')) {
          if (phone.contains('815') ||
              phone.contains('816') ||
              phone.contains('817')) {
            paymentMethodId = 'orange_money';
          } else if (phone.contains('970') ||
              phone.contains('971') ||
              phone.contains('972')) {
            paymentMethodId = 'airtel_money';
          } else {
            paymentMethodId = 'mpesa';
          }
        }
      }

      print('💳 Paiement simulé:');
      print('   Méthode: $paymentMethodId');
      print('   Montant: ${selectedPlan['price']} ${selectedPlan['currency']}');
      print('   Transaction: $transactionId');
      if (showOtpField) {
        print('   Code OTP: ${otpController.text}');
      }

      await Future.delayed(const Duration(seconds: 2));

      final expiryDate = await _activateSubscription(transactionId);
      _showSuccessDialog(
          'Paiement simulé réussi (remplacer par vraie API en production)',
          expiryDate);
    } catch (e) {
      _showErrorDialog('Erreur de traitement: $e');
      print('❌ Erreur _processPayment: $e');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  String _generateTransactionId() {
    final now = DateTime.now();
    final random = Random().nextInt(9999);
    return 'TXN_${widget.currentUserId}_${now.millisecondsSinceEpoch}_$random';
  }

  bool _validateInput() {
    final input = inputController.text.trim();

    if (input.isEmpty) {
      _showErrorDialog('Veuillez remplir le champ requis');
      return false;
    }

    if (showOtpField &&
        selectedPaymentMethod == 'mpesa' &&
        otpController.text.length != 6) {
      _showErrorDialog('Code de confirmation invalide (6 chiffres requis)');
      return false;
    }

    switch (selectedPaymentMethod) {
      case 'card':
        if (input.replaceAll(' ', '').length < 13) {
          _showErrorDialog('Numéro de carte invalide');
          return false;
        }
        break;
      case 'paypal':
        if (!input.contains('@') || !input.contains('.')) {
          _showErrorDialog('Email PayPal invalide');
          return false;
        }
        break;
      case 'mpesa':
        if (input.length < 8) {
          _showErrorDialog('Numéro de téléphone invalide');
          return false;
        }
        break;
    }

    return true;
  }

  Future<DateTime> _activateSubscription(String transactionId) async {
    try {
      final plan = plans[selectedPlanIndex];
      final durationDays = plan['duration'] == 'an' ? 365 : 30;
      final expiryDate = DateTime.now().add(Duration(days: durationDays));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({
        'isUserSubscribed': true,
        'userSubscriptionPlan': plan['id'],
        'subscriptionType': plan['name'],
        'subscriptionPrice': plan['price'],
        'subscriptionCurrency': plan['currency'],
        'subscriptionExpiry': Timestamp.fromDate(expiryDate),
        'subscriptionActivatedAt': Timestamp.now(),
        'lastTransactionId': transactionId,
      });

      print('✅ Abonnement activé pour ${widget.currentUserId}');
      print('   Plan: ${plan['id']}');
      print('   Expiration: $expiryDate');

      return expiryDate;
    } catch (e) {
      print('❌ Erreur activation abonnement: $e');
      rethrow;
    }
  }

  void _showSuccessDialog(String paymentMessage, DateTime expiryDate) {
    if (plans.isEmpty) return;

    final selectedPlan = plans[selectedPlanIndex];
    _successAnimationController.forward(from: 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 50),
              ),
            ),
            const SizedBox(height: 24),
            Text('${selectedPlan['emoji']} Bienvenue Premium !',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Abonnement ${selectedPlan['name']} activé',
                style: TextStyle(
                    fontSize: 16, color: selectedPlan['color'] as Color)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Valable jusqu\'au ${DateFormat('dd/MM/yyyy').format(expiryDate)}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(paymentMessage,
                      style: TextStyle(fontSize: 11, color: textSecondaryColor),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPlan['color'] as Color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Commencer !',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: tertiaryColor),
            const SizedBox(width: 8),
            Text('Erreur de paiement', style: TextStyle(color: textColor)),
          ],
        ),
        content: Text(message, style: TextStyle(color: textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _successAnimationController.dispose();
    inputController.dispose();
    otpController.dispose();
    super.dispose();
  }
}

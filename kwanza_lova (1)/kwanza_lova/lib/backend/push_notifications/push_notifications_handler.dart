import 'dart:async';
import 'dart:convert';

import 'serialization_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../index.dart';
import '../../main.dart';

final _handledMessageIds = <String?>{};

class PushNotificationsHandler extends StatefulWidget {
  const PushNotificationsHandler({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  _PushNotificationsHandlerState createState() =>
      _PushNotificationsHandlerState();
}

class _PushNotificationsHandlerState extends State<PushNotificationsHandler> {
  bool _loading = false;

  Future handleOpenedPushNotification() async {
    if (isWeb) {
      return;
    }

    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await _handlePushNotification(notification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNotification);
  }

  Future _handlePushNotification(RemoteMessage message) async {
    if (_handledMessageIds.contains(message.messageId)) {
      return;
    }
    _handledMessageIds.add(message.messageId);

    safeSetState(() => _loading = true);
    try {
      final initialPageName = message.data['initialPageName'] as String;
      final initialParameterData = getInitialParameterData(message.data);
      final parametersBuilder = parametersBuilderMap[initialPageName];
      if (parametersBuilder != null) {
        final parameterData = await parametersBuilder(initialParameterData);
        if (mounted) {
          context.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        } else {
          appNavigatorKey.currentContext?.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      safeSetState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      handleOpenedPushNotification();
    });
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Container(
          color: Color(0xEA121229),
          child: Image.asset(
            'assets/images/logo_1-removebg-preview.png',
            fit: BoxFit.contain,
          ),
        )
      : widget.child;
}

class ParameterData {
  const ParameterData(
      {this.requiredParams = const {}, this.allParams = const {}});
  final Map<String, String?> requiredParams;
  final Map<String, dynamic> allParams;

  Map<String, String> get pathParameters => Map.fromEntries(
        requiredParams.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
  Map<String, dynamic> get extra => Map.fromEntries(
        allParams.entries.where((e) => e.value != null),
      );

  static Future<ParameterData> Function(Map<String, dynamic>) none() =>
      (data) async => ParameterData();
}

final parametersBuilderMap =
    <String, Future<ParameterData> Function(Map<String, dynamic>)>{
  'Authentification-page': ParameterData.none(),
  'forgot_password': ParameterData.none(),
  'swipe_page': ParameterData.none(),
  'Settings': ParameterData.none(),
  'editprofile': ParameterData.none(),
  'ProfilCompte': ParameterData.none(),
  'inscription': ParameterData.none(),
  'Centre_d_Aide_et_Politique': ParameterData.none(),
  'About_kwanzalova': ParameterData.none(),
  'LangueetApparence': ParameterData.none(),
  'Notifications': ParameterData.none(),
  'AbonnementsetPaiements': ParameterData.none(),
  'desactiversupprimerlecompte': ParameterData.none(),
  'InformationsduCompte': ParameterData.none(),
  'Matchespage': ParameterData.none(),
  'Chatpage': (data) async => ParameterData(
        allParams: {
          'otherUserId': getParameter<String>(data, 'otherUserId'),
          'otherUserName': getParameter<String>(data, 'otherUserName'),
          'chatId': getParameter<String>(data, 'chatId'),
        },
      ),
  'confidentiality_and_security': ParameterData.none(),
  'paiement': ParameterData.none(),
  'SubscriptionManagementWidget': ParameterData.none(),
  'ProfilePage': ParameterData.none(),
  'Notificationspam': ParameterData.none(),
  'desactiversupprimerlecompte_spam': ParameterData.none(),
  'politiquedeconfidentialit': ParameterData.none(),
  'Conditionsgnralesdutilisation': ParameterData.none(),
  'Conseilsdesecurite': ParameterData.none(),
  'FAQ': ParameterData.none(),
  'Contacterlesupport': ParameterData.none(),
  'InfluencerDashboard': ParameterData.none(),
  'phonesignin': ParameterData.none(),
  'version_app': ParameterData.none(),
  'Reseaux_sociaux': ParameterData.none(),
};

Map<String, dynamic> getInitialParameterData(Map<String, dynamic> data) {
  try {
    final parameterDataStr = data['parameterData'];
    if (parameterDataStr == null ||
        parameterDataStr is! String ||
        parameterDataStr.isEmpty) {
      return {};
    }
    return jsonDecode(parameterDataStr) as Map<String, dynamic>;
  } catch (e) {
    print('Error parsing parameter data: $e');
    return {};
  }
}

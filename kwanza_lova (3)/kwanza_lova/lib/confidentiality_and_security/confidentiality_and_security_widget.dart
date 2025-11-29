import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'confidentiality_and_security_model.dart';
export 'confidentiality_and_security_model.dart';

class ConfidentialityAndSecurityWidget extends StatefulWidget {
  const ConfidentialityAndSecurityWidget({super.key});

  static String routeName = 'confidentiality_and_security';
  static String routePath = '/confidentialityAndSecurity';

  @override
  State<ConfidentialityAndSecurityWidget> createState() =>
      _ConfidentialityAndSecurityWidgetState();
}

class _ConfidentialityAndSecurityWidgetState
    extends State<ConfidentialityAndSecurityWidget> {
  late ConfidentialityAndSecurityModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConfidentialityAndSecurityModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 440.0,
                  height: 750.0,
                  child: custom_widgets.PrivacySecurityWidget(
                    width: 440.0,
                    height: 750.0,
                    currentUserId: currentUserUid,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

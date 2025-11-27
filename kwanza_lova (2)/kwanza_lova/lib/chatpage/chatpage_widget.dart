import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chatpage_model.dart';
export 'chatpage_model.dart';

class ChatpageWidget extends StatefulWidget {
  const ChatpageWidget({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.chatId,
  });

  final String? otherUserId;
  final String? otherUserName;
  final String? chatId;

  static String routeName = 'Chatpage';
  static String routePath = '/chatpage';

  @override
  State<ChatpageWidget> createState() => _ChatpageWidgetState();
}

class _ChatpageWidgetState extends State<ChatpageWidget> {
  late ChatpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatpageModel());

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
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 440.0,
                  height: 750.0,
                  child: custom_widgets.ChatWidget(
                    width: 440.0,
                    height: 750.0,
                    currentUserId: currentUserUid,
                    chatId: widget!.chatId!,
                    otherUserId: widget!.otherUserId!,
                    otherUserName: widget!.otherUserName!,
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

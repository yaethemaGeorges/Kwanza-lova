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
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:record/record.dart';
// Version 6.0.0+
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart' as audio_players;
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

// ========================================
// 🛡️ GESTION CENTRALISÉE DES ERREURS
// ========================================
class _ChatErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic error,
    String operation, {
    VoidCallback? onRetry,
  }) {
    String userMessage;
    String? actionLabel;
    VoidCallback? actionCallback;

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          userMessage =
              'Vous n\'avez pas la permission d\'effectuer cette action.';
          break;
        case 'unavailable':
          userMessage = 'Service temporairement indisponible.';
          actionLabel = 'Réessayer';
          actionCallback = onRetry;
          break;
        case 'not-found':
          userMessage = 'La conversation n\'existe plus.';
          break;
        case 'aborted':
          userMessage = 'L\'opération a été annulée.';
          actionLabel = 'Réessayer';
          actionCallback = onRetry;
          break;
        default:
          userMessage = 'Erreur lors de $operation.';
      }
    } else if (error.toString().contains('NetworkException') ||
        error.toString().contains('SocketException')) {
      userMessage = 'Problème de connexion. Vérifiez votre internet.';
      actionLabel = 'Réessayer';
      actionCallback = onRetry;
    } else {
      userMessage = 'Erreur inattendue. Veuillez réessayer.';
    }

    debugPrint('[$operation] Error: $error');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text(userMessage)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: actionLabel != null && actionCallback != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: actionCallback,
                )
              : null,
        ),
      );
    }
  }

  static _ValidationResult validateMessage(String text) {
    if (text.isEmpty) {
      return _ValidationResult(isValid: false);
    }

    if (text.length > 5000) {
      return _ValidationResult(
        isValid: false,
        errorMessage: 'Le message ne peut pas dépasser 5000 caractères.',
      );
    }

    final suspiciousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'onerror=', caseSensitive: false),
      RegExp(r'onclick=', caseSensitive: false),
    ];

    for (final pattern in suspiciousPatterns) {
      if (pattern.hasMatch(text)) {
        return _ValidationResult(
          isValid: false,
          errorMessage: 'Le message contient du contenu non autorisé.',
        );
      }
    }

    return _ValidationResult(isValid: true);
  }
}

class _ValidationResult {
  final bool isValid;
  final String? errorMessage;
  _ValidationResult({required this.isValid, this.errorMessage});
}

/// ======================================== 💬 CHAT WIDGET PRINCIPAL
/// ========================================
class ChatWidget extends StatefulWidget {
  const ChatWidget({
    Key? key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String currentUserId;
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = audio_players.AudioPlayer();

  static const primaryColor = Color(0xFF6F61EF);
  static const secondaryColor = Color(0xFF39D2C0);
  static const primaryTextColor = Color(0xFF15161E);
  static const secondaryTextColor = Color(0xFF606A85);

  String otherUserDisplayName = '';
  String? otherUserPhotoUrl;
  bool _showEmojiPicker = false;
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordDuration = Duration.zero;
  String? _currentlyPlayingMessageId;

  Timer? _typingTimer;
  Timer? _recordingTimer;
  bool _isOtherUserTyping = false;
  StreamSubscription? _typingSubscription;

  bool _isOnline = true;
  StreamSubscription? _connectivitySubscription;
  final List<Map<String, dynamic>> _pendingMessages = [];

  StreamSubscription? _messageSubscription;
  bool _isOtherUserOnline = false;
  DateTime? _otherUserLastSeen;

  bool _isSending = false;

  StreamSubscription? _audioPlayerSubscription;

  Future<void> _markMessagesAsRead() async {
    try {
      print('📖 Marquage des messages comme lus...');

      // ÉTAPE 1 : Récupérer les messages non lus
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .where('senderId', isEqualTo: widget.otherUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (messagesSnapshot.docs.isEmpty) {
        print('✅ Aucun message à marquer');
        return;
      }

      print('📝 ${messagesSnapshot.docs.length} messages à marquer comme lus');

      // ÉTAPE 2 : Marquer les messages comme lus
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      // ÉTAPE 3 : Réinitialiser le compteur de messages non lus
      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

      batch.update(chatRef, {
        'unreadCount_${widget.currentUserId}': 0,
      });

      await batch.commit();

      print('✅ Messages marqués comme lus avec succès');
    } catch (e) {
      print('❌ Erreur marquage messages: $e');
      _ChatErrorHandler.handleError(context, e, 'le marquage des messages');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOtherUserData();
    _initChat();
    _requestPermissions();
    _setupOfflineMode();
    _listenToTypingStatus();
    _listenToNewMessages();
    _updateOnlineStatus(true);
    _setupOtherUserStatusListener();

    // ✅ AJOUT : Marquer les messages comme lus dès l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsRead();
    });

    _messageController.addListener(() {
      _onTextChanged(_messageController.text);
    });
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({
        'is_online': isOnline,
        'last_seen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  void _setupOtherUserStatusListener() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && mounted) {
          setState(() {
            _isOtherUserOnline = data['is_online'] ?? false;
            if (data['last_seen'] != null) {
              _otherUserLastSeen = (data['last_seen'] as Timestamp).toDate();
            }
          });
        }
      }
    });
  }

  Future<void> _setupOfflineMode() async {
    try {
      FirebaseFirestore.instance.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('Error setting up offline persistence: $e');
    }

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get(GetOptions(source: Source.cache));
    } catch (e) {
      debugPrint('Cache preload error: $e');
    }

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      final newStatus = result != ConnectivityResult.none;
      if (mounted && _isOnline != newStatus) {
        setState(() {
          _isOnline = newStatus;
        });

        if (_isOnline && _pendingMessages.isNotEmpty) {
          _sendPendingMessages();
        }
      }
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = connectivityResult != ConnectivityResult.none;
      });
    }
  }

  Future<void> _sendPendingMessages() async {
    for (final messageData in List.from(_pendingMessages)) {
      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .add(messageData);

        _pendingMessages.remove(messageData);
      } catch (e) {
        _ChatErrorHandler.handleError(
          context,
          e,
          'l\'envoi des messages en attente',
          onRetry: _sendPendingMessages,
        );
        break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _listenToNewMessages() {
    _messageSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final message = snapshot.docs.first.data();
        if (message['senderId'] != widget.currentUserId) {
          snapshot.docs.first.reference.update({'isRead': true});
        }
      }
    });
  }

  void _listenToTypingStatus() {
    _typingSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final typingUserId = data['typingUserId'] as String?;
      final lastTypingTime = data['lastTypingTime'] as Timestamp?;

      if (typingUserId == widget.otherUserId &&
          lastTypingTime != null &&
          DateTime.now().difference(lastTypingTime.toDate()).inSeconds < 3) {
        if (mounted) {
          setState(() {
            _isOtherUserTyping = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isOtherUserTyping = false;
          });
        }
      }
    });
  }

  void _onTextChanged(String text) {
    _typingTimer?.cancel();

    if (text.isEmpty) {
      _clearTypingStatus();
      return;
    }

    _updateTypingStatus();

    _typingTimer = Timer(Duration(seconds: 2), () {
      _clearTypingStatus();
    });
  }

  Future<void> _updateTypingStatus() async {
    if (!_isOnline) return;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'typingUserId': widget.currentUserId,
        'lastTypingTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating typing status: $e');
    }
  }

  Future<void> _clearTypingStatus() async {
    if (!_isOnline) return;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'typingUserId': null,
        'lastTypingTime': null,
      });
    } catch (e) {
      debugPrint('Error clearing typing status: $e');
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.camera.request();

    if (!kIsWeb && Platform.isAndroid) {
      try {
        await Permission.photos.request();
      } catch (e) {
        await Permission.storage.request();
      }
    } else if (!kIsWeb && Platform.isIOS) {
      await Permission.photos.request();
    }
  }

  Future<void> _initChat() async {
    try {
      debugPrint('🔍 Initialisation chat: ${widget.chatId}');

      final ref =
          FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      final doc = await ref.get();

      if (!doc.exists) {
        debugPrint('❌ ERREUR CRITIQUE: Chat inexistant: ${widget.chatId}');

        if (mounted) {
          _ChatErrorHandler.handleError(
            context,
            Exception('Conversation introuvable'),
            'l\'initialisation du chat',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Conversation introuvable',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cette conversation n\'existe pas ou a été supprimée.',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Retour automatique dans 2 secondes...',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
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

          Future.delayed(Duration(seconds: 2), () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        }
        return;
      }

      final data = doc.data()!;
      debugPrint('✅ Chat trouvé: ${widget.chatId}');

      bool needsRepair = false;
      Map<String, dynamic> updates = {};

      if (data['participants'] == null) {
        debugPrint('⚠️ Participants manquants');
        needsRepair = true;
        updates['participants'] = [widget.currentUserId, widget.otherUserId];
      }

      if (!data.containsKey('unreadCount_${widget.currentUserId}')) {
        needsRepair = true;
        updates['unreadCount_${widget.currentUserId}'] = 0;
      }

      if (!data.containsKey('unreadCount_${widget.otherUserId}')) {
        needsRepair = true;
        updates['unreadCount_${widget.otherUserId}'] = 0;
      }

      if (!data.containsKey('isActive')) {
        needsRepair = true;
        updates['isActive'] = true;
      }

      if (needsRepair && updates.isNotEmpty) {
        try {
          await ref.update(updates);
          debugPrint('✅ Chat réparé avec succès');
        } catch (updateError) {
          debugPrint('❌ Erreur lors de la réparation: $updateError');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ERREUR CRITIQUE _initChat: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        _ChatErrorHandler.handleError(
          context,
          e,
          'l\'initialisation du chat',
          onRetry: _initChat,
        );
      }
    }
  }

  Future<void> _loadOtherUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          otherUserDisplayName = data['display_name'] ??
              data['displayName'] ??
              data['name'] ??
              widget.otherUserName;
          otherUserPhotoUrl = data['photo_url'];
        });
      }
    } catch (e) {
      _ChatErrorHandler.handleError(context, e, 'le chargement du profil');
    }
  }

  Future<void> _sendMessage(
      {String? audioUrl, int? audioDuration, String? imageUrl}) async {
    if (_isSending) return;

    final text = _messageController.text.trim();
    if (text.isEmpty && audioUrl == null && imageUrl == null) return;

    if (text.isNotEmpty) {
      final validation = _ChatErrorHandler.validateMessage(text);
      if (!validation.isValid) {
        if (validation.errorMessage != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text(validation.errorMessage!)),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isSending = true;
    });

    final messageText = text;

    if (mounted && messageText.isNotEmpty) {
      _messageController.clear();
    }

    final messageData = {
      'senderId': widget.currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    if (imageUrl != null) {
      messageData['type'] = 'image';
      messageData['imageUrl'] = imageUrl;
      messageData['content'] = '📷 Photo';
    } else if (audioUrl != null) {
      messageData['type'] = 'audio';
      messageData['audioUrl'] = audioUrl;
      messageData['audioDuration'] = audioDuration ?? 0;
      messageData['content'] = '🎤 Message vocal';
    } else {
      messageData['type'] = 'text';
      messageData['content'] = messageText;
    }

    try {
      if (_isOnline) {
        final ref =
            FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

        await ref.collection('messages').add(messageData);

        await ref.update({
          'lastMessage': messageData['content'],
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageType': messageData['type'],
          'lastMessageSenderId': widget.currentUserId,
          'unreadCount_${widget.otherUserId}': FieldValue.increment(1),
        });

        _clearTypingStatus();
        _scrollToBottom();
      } else {
        _pendingMessages.add(messageData);
      }
    } catch (e) {
      if (!_pendingMessages.contains(messageData)) {
        _pendingMessages.add(messageData);
      }
      _ChatErrorHandler.handleError(
        context,
        e,
        'l\'envoi du message',
        onRetry: () => _sendMessage(
          audioUrl: audioUrl,
          audioDuration: audioDuration,
          imageUrl: imageUrl,
        ),
      );
    } finally {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadAndSendImage(image);
      }
    } catch (e) {
      _ChatErrorHandler.handleError(context, e, 'la sélection de l\'image');
    }
  }

  Future<void> _uploadAndSendImage(XFile image) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text('Envoi de l\'image...'),
                ],
              ),
            ),
          ),
        ),
      );

      final fileName =
          'chat_images/${widget.chatId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      final bytes = await image.readAsBytes();

      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await ref.getDownloadURL();

      if (mounted) {
        Navigator.pop(context);
      }

      await _sendMessage(imageUrl: downloadUrl);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      _ChatErrorHandler.handleError(context, e, 'l\'envoi de l\'image');
    }
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();

      if (!status.isGranted) {
        _showPermissionError('microphone');
        return;
      }

      if (!await _audioRecorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permission d\'enregistrement audio refusée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'L\'enregistrement audio n\'est pas supporté sur le web'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _recordDuration = Duration.zero;
      });

      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (!_isRecording) {
          timer.cancel();
          return;
        }
        if (mounted) {
          setState(() {
            _recordDuration += Duration(seconds: 1);
          });
        }
      });
    } catch (e) {
      _ChatErrorHandler.handleError(
          context, e, 'le démarrage de l\'enregistrement');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
      });

      if (path != null && _recordDuration.inSeconds >= 1) {
        await _uploadAudioMessage(path);
      }
    } catch (e) {
      _ChatErrorHandler.handleError(
          context, e, 'l\'arrêt de l\'enregistrement');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();
      if (_recordingPath != null && !kIsWeb) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      setState(() {
        _isRecording = false;
        _recordingPath = null;
        _recordDuration = Duration.zero;
      });
    } catch (e) {
      _ChatErrorHandler.handleError(
          context, e, 'l\'annulation de l\'enregistrement');
    }
  }

  Future<void> _uploadAudioMessage(String filePath) async {
    try {
      if (kIsWeb) return;

      final file = File(filePath);
      final fileName =
          'voice_messages/${widget.chatId}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      await _sendMessage(
        audioUrl: downloadUrl,
        audioDuration: _recordDuration.inSeconds,
      );

      await file.delete();
      setState(() {
        _recordingPath = null;
        _recordDuration = Duration.zero;
      });
    } catch (e) {
      _ChatErrorHandler.handleError(context, e, 'l\'envoi du message vocal');
    }
  }

  Future<void> _playAudio(String url, String messageId) async {
    try {
      await _audioPlayerSubscription?.cancel();

      if (_currentlyPlayingMessageId == messageId) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingMessageId = null;
        });
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(audio_players.UrlSource(url));
        setState(() {
          _currentlyPlayingMessageId = messageId;
        });

        _audioPlayerSubscription =
            _audioPlayer.onPlayerComplete.listen((event) {
          if (mounted) {
            setState(() {
              _currentlyPlayingMessageId = null;
            });
          }
        });
      }
    } catch (e) {
      _ChatErrorHandler.handleError(context, e, 'la lecture audio');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _initiateCall(String type) async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Les appels ne sont pas supportés sur le web'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // ✅ ÉTAPE 1 : DEMANDER LES PERMISSIONS D'ABORD
      print('🎥 Demande des permissions...');

      PermissionStatus micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        print('❌ Permission microphone refusée');
        _showPermissionError('microphone');
        return;
      }

      if (type == 'video') {
        PermissionStatus cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          print('❌ Permission caméra refusée');
          _showPermissionError('caméra');
          return;
        }
      }

      print('✅ Permissions accordées');

      // ✅ ÉTAPE 2 : CRÉER LE DOCUMENT D'APPEL
      final roomName =
          'chat_${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}';

      print('📞 Création de l\'appel: $roomName');

      final callDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('calls')
          .add({
        'callerId': widget.currentUserId,
        'receiverId': widget.otherUserId,
        'roomName': roomName,
        'type': type,
        'status': 'calling',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderId': widget.currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'call',
        'content': type == 'video' ? '📹 Appel vidéo' : '📞 Appel vocal',
        'callId': callDoc.id,
        'roomName': roomName,
      });

      // ✅ ÉTAPE 3 : CONFIGURATION JITSI OPTIMISÉE
      print('🎬 Lancement de Jitsi...');

      var jitsiMeet = JitsiMeet();

      var options = JitsiMeetConferenceOptions(
        room: roomName,
        serverURL: 'https://meet.jit.si',
        configOverrides: {
          'startWithAudioMuted': false,
          'startWithVideoMuted': type == 'audio',
          'subject':
              'Appel avec ${otherUserDisplayName.isNotEmpty ? otherUserDisplayName : widget.otherUserName}',
          // ✅ AJOUTS CRITIQUES pour éviter l'écran noir
          'prejoinConfig': {
            'enabled': false, // Désactiver le pré-join
          },
          'disableDeepLinking': true,
        },
        featureFlags: {
          'unsaferoomwarning.enabled': false,
          'prejoinpage.enabled': false,
          'chat.enabled': true,
          'filmstrip.enabled': true,
          'invite.enabled': false,
          'android.screensharing.enabled': false, // Évite les crashs
          'pip.enabled': false, // Désactiver picture-in-picture
          'meeting-name.enabled': false,
          'call-integration.enabled': false, // Important : évite les conflits
        },
        userInfo: JitsiMeetUserInfo(
          displayName: 'Vous',
          email: '', // Peut être vide
          avatar: null,
        ),
      );

      // ✅ ÉTAPE 4 : LANCER JITSI ET ÉCOUTER LES ÉVÉNEMENTS
      var listener = JitsiMeetEventListener(
        conferenceJoined: (url) {
          print('✅ Conférence rejointe: $url');
        },
        conferenceTerminated: (url, error) {
          print('🔚 Conférence terminée: $url');
          // Mettre à jour le statut de l'appel
          callDoc.update({
            'status': 'completed',
            'endedAt': FieldValue.serverTimestamp(),
          });
        },
        conferenceWillJoin: (url) {
          print('⏳ Préparation de la conférence...');
        },
        participantJoined: (email, name, role, participantId) {
          print('👤 Participant rejoint: $name');
        },
        participantLeft: (participantId) {
          print('👋 Participant parti: $participantId');
        },
        audioMutedChanged: (muted) {
          print('🎤 Audio muted: $muted');
        },
        videoMutedChanged: (muted) {
          print('📹 Vidéo muted: $muted');
        },
        endpointTextMessageReceived: (senderId, message) {
          print('💬 Message reçu: $message');
        },
        screenShareToggled: (participantId, sharing) {
          print('🖥️ Partage d\'écran: $sharing');
        },
        readyToClose: () {
          print('✅ Prêt à fermer');
        },
      );

      await jitsiMeet.join(options, listener);

      print('🎉 Jitsi lancé avec succès');
    } catch (e, stackTrace) {
      print('❌ ERREUR JITSI: $e');
      print('Stack trace: $stackTrace');
      _ChatErrorHandler.handleError(context, e, 'le lancement de l\'appel');
    }
  }

  void _showPermissionError(String permission) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Permission requise'),
          content: Text(
            'Veuillez autoriser l\'accès au $permission dans les paramètres de l\'application.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Paramètres', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _clearTypingStatus();
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: _ResponsiveHelper.value(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: otherUserPhotoUrl != null
                  ? CachedNetworkImageProvider(otherUserPhotoUrl!)
                  : null,
              child: otherUserPhotoUrl == null
                  ? Text(
                      otherUserDisplayName.isNotEmpty
                          ? otherUserDisplayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserDisplayName.isNotEmpty
                        ? otherUserDisplayName
                        : widget.otherUserName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: _ResponsiveHelper.fontSize(context, 18),
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _isOtherUserTyping
                        ? 'En train d\'écrire...'
                        : _isOtherUserOnline
                            ? 'En ligne'
                            : _otherUserLastSeen != null
                                ? 'Vu ${_formatLastSeen(_otherUserLastSeen!)}'
                                : 'Hors ligne',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: _ResponsiveHelper.fontSize(context, 12),
                      fontStyle: _isOtherUserTyping
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!_isOnline)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Hors ligne',
                          style: TextStyle(fontSize: 10, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          if (!kIsWeb) ...[
            IconButton(
              icon: Icon(Icons.call, color: Colors.white),
              onPressed: () => _initiateCall('audio'),
            ),
            IconButton(
              icon: Icon(Icons.videocam, color: Colors.white),
              onPressed: () => _initiateCall('video'),
            ),
          ],
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: isDark ? Colors.grey[800] : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'profile') _showProfile();
              if (v == 'block') _showBlockDialog();
              if (v == 'report') _showReportDialog();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person,
                        color: isDark ? Colors.white : primaryTextColor),
                    SizedBox(width: 12),
                    Text('Voir le profil',
                        style: TextStyle(
                            color: isDark ? Colors.white : primaryTextColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Bloquer'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Signaler'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_pendingMessages.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withOpacity(0.2),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_pendingMessages.length} message(s) en attente d\'envoi',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                  TextButton(
                    onPressed: _sendPendingMessages,
                    child: Text('Réessayer',
                        style: TextStyle(color: Colors.orange)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Erreur de chargement',
                            style: TextStyle(
                                color:
                                    isDark ? Colors.white : primaryTextColor)),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor),
                          child: Text('Réessayer',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                if (!snap.hasData) {
                  return Center(
                      child: CircularProgressIndicator(color: primaryColor));
                }

                final msgs = snap.data!.docs;
                if (msgs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 80,
                            color:
                                isDark ? Colors.grey[700] : Colors.grey[300]),
                        SizedBox(height: 16),
                        Text('Commencez la conversation !',
                            style: TextStyle(
                                fontSize: 18,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600])),
                        SizedBox(height: 8),
                        Text(
                            'Dites bonjour à ${otherUserDisplayName.isNotEmpty ? otherUserDisplayName : widget.otherUserName}',
                            style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[500])),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final data = msgs[i].data() as Map<String, dynamic>;
                    final messageId = msgs[i].id;
                    final isMe = data['senderId'] == widget.currentUserId;
                    final type = data['type']?.toString() ?? 'text';
                    final content = data['content']?.toString() ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final bubbleColor = isMe
                        ? primaryColor
                        : (isDark ? Colors.grey[800]! : Color(0x4C39D2C0));

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: otherUserPhotoUrl != null
                                  ? CachedNetworkImageProvider(
                                      otherUserPhotoUrl!)
                                  : null,
                              child: otherUserPhotoUrl == null
                                  ? Text(
                                      otherUserDisplayName.isNotEmpty
                                          ? otherUserDisplayName[0]
                                              .toUpperCase()
                                          : '?',
                                      style: TextStyle(fontSize: 12))
                                  : null,
                            ),
                            SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _ResponsiveHelper.value(
                                  context,
                                  mobile: 16,
                                  tablet: 20,
                                  desktop: 24,
                                ),
                                vertical: _ResponsiveHelper.value(
                                  context,
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black
                                          .withOpacity(isDark ? 0.3 : 0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (type == 'image') ...[
                                    GestureDetector(
                                      onTap: () =>
                                          _showFullImage(data['imageUrl']),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: data['imageUrl'] ?? '',
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 600,
                                          memCacheHeight: 600,
                                          maxWidthDiskCache: 1200,
                                          maxHeightDiskCache: 1200,
                                          placeholder: (context, url) =>
                                              Container(
                                            width: 200,
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                  color: primaryColor),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            width: 200,
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error,
                                                    color: Colors.red),
                                                SizedBox(height: 8),
                                                Text('Erreur de chargement',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] else if (type == 'audio') ...[
                                    _buildAudioMessage(
                                      data['audioUrl'] ?? '',
                                      data['audioDuration'] ?? 0,
                                      messageId,
                                      isMe,
                                      isDark,
                                    ),
                                  ] else ...[
                                    Text(content,
                                        style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white
                                                    : primaryTextColor),
                                            fontSize:
                                                _ResponsiveHelper.fontSize(
                                                    context, 15))),
                                  ],
                                  if (timestamp != null) ...[
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_formatTime(timestamp.toDate()),
                                            style: TextStyle(
                                                fontSize:
                                                    _ResponsiveHelper.fontSize(
                                                        context, 11),
                                                color: isMe
                                                    ? Colors.white
                                                        .withOpacity(0.7)
                                                    : (isDark
                                                        ? Colors.white54
                                                        : secondaryTextColor
                                                            .withOpacity(
                                                                0.6)))),
                                        if (isMe) ...[
                                          SizedBox(width: 4),
                                          Icon(
                                            data['isRead'] == true
                                                ? Icons.done_all
                                                : Icons.done,
                                            size: 14,
                                            color: data['isRead'] == true
                                                ? Colors.blue[300]
                                                : Colors.white.withOpacity(0.7),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isRecording)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? Colors.grey[850] : Colors.red[50],
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _cancelRecording,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete, color: Colors.white, size: 20),
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatDuration(_recordDuration),
                    style: TextStyle(
                      color: isDark ? Colors.white : primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Glissez pour annuler',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: _stopRecording,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          if (!_isRecording)
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
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: Offset(0, -2))
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(25)),
                        child: Row(
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.emoji_emotions_outlined, size: 22),
                              color: secondaryColor,
                              onPressed: () {
                                setState(() {
                                  _showEmojiPicker = !_showEmojiPicker;
                                });
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : primaryTextColor),
                                decoration: InputDecoration(
                                  hintText: 'Tapez votre message...',
                                  hintStyle:
                                      TextStyle(color: secondaryTextColor),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 12),
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.image, size: 22),
                              color: secondaryColor,
                              onPressed: _pickAndSendImage,
                            ),
                            if (!kIsWeb)
                              IconButton(
                                icon: Icon(Icons.mic, size: 22),
                                color: secondaryColor,
                                onPressed: _startRecording,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: (_messageController.text.trim().isNotEmpty &&
                              !_isSending)
                          ? _sendMessage
                          : null,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (_messageController.text.trim().isNotEmpty &&
                                  !_isSending)
                              ? primaryColor
                              : (isDark ? Colors.grey[700] : Colors.grey[300]),
                          shape: BoxShape.circle,
                          boxShadow:
                              (_messageController.text.trim().isNotEmpty &&
                                      !_isSending)
                                  ? [
                                      BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 2))
                                    ]
                                  : null,
                        ),
                        child: _isSending
                            ? Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.send,
                                color: (_messageController.text
                                            .trim()
                                            .isNotEmpty &&
                                        !_isSending)
                                    ? Colors.white
                                    : secondaryTextColor,
                                size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _messageController.text += emoji.emoji;
                },
                config: Config(
                  height: 256,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28,
                    columns: 7,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(color: primaryColor)),
                errorWidget: (context, url, error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 64),
                      SizedBox(height: 16),
                      Text('Erreur de chargement',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(
      String audioUrl, int duration, String messageId, bool isMe, bool isDark) {
    final isPlaying = _currentlyPlayingMessageId == messageId;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _playAudio(audioUrl, messageId),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withOpacity(0.2)
                  : primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: isMe ? Colors.white : primaryColor,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 2,
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withOpacity(0.3)
                    : (isDark ? Colors.white30 : primaryColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatDuration(Duration(seconds: duration)),
              style: TextStyle(
                fontSize: 12,
                color: isMe
                    ? Colors.white.withOpacity(0.8)
                    : (isDark ? Colors.white70 : secondaryTextColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inDays < 1) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return '${days[dt.weekday - 1]} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'hier';
    return 'il y a ${diff.inDays}j';
  }

  void _showProfile() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();

      if (!userDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(child: Text('Profil introuvable')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            final photoUrl = userData['photo_url'] ?? userData['photoUrl'];
            final displayName = userData['display_name'] ??
                userData['displayName'] ??
                userData['name'] ??
                otherUserDisplayName;
            final age = userData['age']?.toString() ?? '';
            final bio = userData['bio'] ?? userData['Bio'] ?? '';
            final location = userData['location'] ?? userData['ville'] ?? '';
            final gender = userData['gender'] ?? '';
            final interests = userData['interests'] as List<dynamic>? ?? [];

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
                    padding: EdgeInsets.symmetric(
                      vertical: _ResponsiveHelper.value(context,
                          mobile: 12, tablet: 14, desktop: 16),
                    ),
                    child: Container(
                      width: _ResponsiveHelper.value(context,
                          mobile: 40, tablet: 50, desktop: 60),
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
                          // Photo
                          Container(
                            height: _ResponsiveHelper.value(context,
                                mobile: 400, tablet: 500, desktop: 600),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1)),
                            child: photoUrl != null && photoUrl.isNotEmpty
                                ? Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Icon(Icons.person,
                                          size: 100, color: Colors.grey[400]),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: _ResponsiveHelper.value(
                                            context,
                                            mobile: 120,
                                            tablet: 150,
                                            desktop: 180),
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(_ResponsiveHelper.value(
                                context,
                                mobile: 24,
                                tablet: 32,
                                desktop: 40)),
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
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '$age ans',
                                          style: TextStyle(
                                            fontSize:
                                                _ResponsiveHelper.fontSize(
                                                    context, 18),
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor,
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
                                          size: 20,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: TextStyle(
                                            fontSize:
                                                _ResponsiveHelper.fontSize(
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
                                          size: 20,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600]),
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
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 20),
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    bio,
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 16),
                                      height: 1.6,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],

                                // Intérêts
                                if (interests.isNotEmpty) ...[
                                  SizedBox(height: 24),
                                  Text(
                                    'Centres d\'intérêt',
                                    style: TextStyle(
                                      fontSize: _ResponsiveHelper.fontSize(
                                          context, 20),
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: interests.map((interest) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color:
                                              secondaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: secondaryColor
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          interest.toString(),
                                          style: TextStyle(
                                            fontSize:
                                                _ResponsiveHelper.fontSize(
                                                    context, 14),
                                            color: secondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],

                                SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bouton
                  Container(
                    padding: EdgeInsets.all(_ResponsiveHelper.value(context,
                        mobile: 20, tablet: 24, desktop: 28)),
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
                          backgroundColor: primaryColor,
                          minimumSize: Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
    } catch (e) {
      debugPrint('❌ Erreur affichage profil: $e');
      if (mounted) {
        _ChatErrorHandler.handleError(context, e, 'l\'affichage du profil',
            onRetry: _showProfile);
      }
    }
  }

  void _showBlockDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? Color(0xFF2A2A2A) : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.block,
              color: Colors.red,
              size: _ResponsiveHelper.value(context,
                  mobile: 24, tablet: 28, desktop: 32),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bloquer cet utilisateur ?',
                style: TextStyle(
                  fontSize: _ResponsiveHelper.fontSize(context, 20),
                  color: isDark ? Colors.white : Colors.black87,
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
              'Voulez-vous bloquer ${otherUserDisplayName.isNotEmpty ? otherUserDisplayName : widget.otherUserName} ?',
              style: TextStyle(
                fontSize: _ResponsiveHelper.fontSize(context, 15),
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Conséquences :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildWarningItem('• Vous ne pourrez plus communiquer'),
                  _buildWarningItem('• Le match sera désactivé'),
                  _buildWarningItem('• Cette action est réversible'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: TextStyle(
                fontSize: _ResponsiveHelper.fontSize(context, 15),
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(100, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Bloquer',
              style: TextStyle(
                color: Colors.white,
                fontSize: _ResponsiveHelper.fontSize(context, 15),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _blockUser();
    }
  }

// Méthode helper pour _showBlockDialog
  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.red[700]),
      ),
    );
  }

// Méthode helper pour effectuer le blocage
  Future<void> _blockUser() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final blockedRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('blockedUsers')
          .doc(widget.otherUserId);

      batch.set(blockedRef, {
        'blockedUserId': widget.otherUserId,
        'blockedUserName': otherUserDisplayName.isNotEmpty
            ? otherUserDisplayName
            : widget.otherUserName,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      batch.update(chatRef, {
        'isBlocked': true,
        'blockedBy': widget.currentUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      final matchId =
          _generateMatchId(widget.currentUserId, widget.otherUserId);
      final matchRef =
          FirebaseFirestore.instance.collection('matches').doc(matchId);
      batch.update(matchRef, {
        'isActive': false,
        'blockedBy': widget.currentUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                      '${otherUserDisplayName.isNotEmpty ? otherUserDisplayName : widget.otherUserName} a été bloqué'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Future.delayed(Duration(seconds: 1), () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur blocage: $e');
      if (mounted) {
        _ChatErrorHandler.handleError(
            context, e, 'le blocage de l\'utilisateur',
            onRetry: _blockUser);
      }
    }
  }

// Méthode helper pour générer matchId
  String _generateMatchId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  void _showReportDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedReason;

    final reasons = [
      'Comportement inapproprié',
      'Contenu offensant',
      'Harcèlement',
      'Spam / Publicité',
      'Faux profil',
      'Contenu sexuel non sollicité',
      'Menaces ou violence',
      'Autre',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? Color(0xFF2A2A2A) : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.flag,
                color: Colors.orange,
                size: _ResponsiveHelper.value(context,
                    mobile: 24, tablet: 28, desktop: 32),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Signaler un problème',
                  style: TextStyle(
                    fontSize: _ResponsiveHelper.fontSize(context, 20),
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pourquoi signalez-vous ${otherUserDisplayName.isNotEmpty ? otherUserDisplayName : widget.otherUserName} ?',
                  style: TextStyle(
                    fontSize: _ResponsiveHelper.fontSize(context, 15),
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Votre signalement sera traité de manière confidentielle',
                          style:
                              TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ...reasons.map((reason) => RadioListTile<String>(
                      title: Text(
                        reason,
                        style: TextStyle(
                          fontSize: _ResponsiveHelper.fontSize(context, 14),
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (value) {
                        setState(() => selectedReason = value);
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Annuler',
                style: TextStyle(
                  fontSize: _ResponsiveHelper.fontSize(context, 15),
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedReason == null ? Colors.grey : Colors.orange,
                minimumSize: Size(100, 42),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: selectedReason == null
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      _submitReport(selectedReason!);
                    },
              child: Text(
                'Signaler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _ResponsiveHelper.fontSize(context, 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Méthode helper pour soumettre le signalement
  Future<void> _submitReport(String reason) async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reportedBy': widget.currentUserId,
        'reportedUser': widget.otherUserId,
        'reportedUserName': otherUserDisplayName.isNotEmpty
            ? otherUserDisplayName
            : widget.otherUserName,
        'reason': reason,
        'context': 'chat',
        'chatId': widget.chatId,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'reviewed': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Signalement envoyé',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Notre équipe examinera votre signalement',
                          style: TextStyle(fontSize: 12)),
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
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur signalement: $e');
      if (mounted) {
        _ChatErrorHandler.handleError(context, e, 'le signalement',
            onRetry: () => _submitReport(reason));
      }
    }
  }

  @override
  void dispose() {
    print('🧹 DÉBUT DISPOSE ChatWidget');

    // ✅ ANNULER TOUS LES STREAMSUBSCRIPTIONS
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _audioPlayerSubscription?.cancel();

    // ✅ ANNULER LES TIMERS
    _typingTimer?.cancel();
    _recordingTimer?.cancel();

    // ✅ DISPOSE DES CONTROLLERS
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();

    // ✅ NETTOYAGE FIRESTORE
    _clearTypingStatus();
    _updateOnlineStatus(false);

    // ✅ REMOVE OBSERVER
    WidgetsBinding.instance.removeObserver(this);

    print('✅ ChatWidget dispose terminé');

    super.dispose();
  }
}

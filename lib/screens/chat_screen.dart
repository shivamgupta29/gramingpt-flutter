import 'package:flutter/material.dart';
import 'dart:async';

import '../widgets/chat_bubble.dart';
import '../widgets/history_drawer.dart';
import '../helpers/database_helper.dart';
import '../services/api_service.dart'; // Using the centralized ApiService
import 'package:permission_handler/permission_handler.dart' as perm_handler; // Kept for microphone permission
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'nearby_places_screen.dart';

class GraminChatMessage {
  final String text;
  final bool isUser;
  final String? audioUrl;

  GraminChatMessage({required this.text, required this.isUser, this.audioUrl});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  bool _isListening = false;
  String _transcribedText = '';

  bool _isLoading = false;

  // Data State
  List<GraminChatMessage> _messages = <GraminChatMessage>[];
  String? _currentConversationId;
  String _currentConversationTitle = ' ग्रामीण GPT';

  List<ConversationSummary> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _initTts();
    await _initSpeech();
    _loadHistory();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("hi-IN");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    // Try to find a specific Hindi voice to prevent accent switching
    try {
      // Get the list of available voices on the device
      List<dynamic> voices = await _flutterTts.getVoices;
      
      // Find a voice that is for Hindi (hi-IN)
      var hindiVoice = voices.firstWhere(
        (voice) => voice['locale'] == 'hi-IN',
        orElse: () => null,
      );

      if (hindiVoice != null) {
        // If a Hindi voice is found, set it explicitly.
        // This can sometimes help lock the engine to the correct accent.
        await _flutterTts.setVoice({"name": hindiVoice['name'], "locale": hindiVoice['locale']});
      }
    } catch (e) {
      // Could not get voices, proceed with default settings.
    }
  }

  // This function now only handles microphone/speech permissions
  Future<void> _initSpeech() async {
    var micStatus = await perm_handler.Permission.microphone.request();
    if (micStatus.isGranted) {
      bool initialized = await _speech.initialize();
      if (mounted) {
        setState(() => _speechInitialized = initialized);
      }
    } else {
      if (mounted) {
        setState(() => _speechInitialized = false);
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    DatabaseHelper.instance.close();
    super.dispose();
  }

  // --- DATABASE & CONVERSATION MANAGEMENT ---

  Future<void> _loadHistory() async {
    final history = await DatabaseHelper.instance.getConversations();
    setState(() {
      _conversationHistory = history;
    });
  }

  void _startNewConversation() {
    setState(() {
      _messages = [];
      _currentConversationId = null;
      _currentConversationTitle = 'नई बातचीत';
    });
  }

  void _loadConversation(String conversationId) async {
    final summary = _conversationHistory.firstWhere((s) => s.id == conversationId);
    final messages = await DatabaseHelper.instance.getMessages(conversationId);
    setState(() {
      _currentConversationId = conversationId;
      _currentConversationTitle = summary.title;
      _messages = messages;
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // --- SPEECH & SENDING LOGIC ---

  void _startListening() {
    if (!_speechInitialized || _isListening) return;
    _transcribedText = '';
    setState(() => _isListening = true);
    _speech.listen(
      localeId: 'hi_IN',
      onResult: (result) => setState(() => _transcribedText = result.recognizedWords),
    );
  }

  // **UPDATED:** This function now uses the ApiService for everything.
  void _stopListeningAndSend() async {
    if (!_isListening) return;

    _speech.stop();
    setState(() => _isListening = false);

    await Future.delayed(const Duration(milliseconds: 200));

    if (_transcribedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not hear you. Please try again.')),
      );
      return;
    }

    final userMessageText = _transcribedText;
    final userMessage = GraminChatMessage(text: userMessageText, isUser: true);

    setState(() {
      _messages.insert(0, userMessage);
      _isLoading = true;
    });
    _transcribedText = '';

    if (_currentConversationId == null) {
      String title = userMessageText.split(' ').take(5).join(' ');
      final newConversationId = await DatabaseHelper.instance.createConversation(title);
      setState(() {
        _currentConversationId = newConversationId;
        _currentConversationTitle = title;
      });
      _loadHistory();
    }

    await DatabaseHelper.instance.saveMessage(userMessage, _currentConversationId!);

    try {
      // The ApiService now handles getting location and calling the backend.
      final aiResponseText = await ApiService.getAiResponse(userMessageText);
      await _speak(aiResponseText);

      final aiMessage = GraminChatMessage(text: aiResponseText, isUser: false);
      await DatabaseHelper.instance.saveMessage(aiMessage, _currentConversationId!);

      setState(() {
        _messages.insert(0, aiMessage);
      });

    } catch (e) {
      final errorMessage = GraminChatMessage(text: "Error: ${e.toString()}", isUser: false);
      setState(() {
        _messages.insert(0, errorMessage);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleMicTap() {
    if (_isListening) {
      _stopListeningAndSend();
    } else {
      _startListening();
    }
  }

  // --- UI WIDGETS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(_currentConversationTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital, color: Colors.white),
            tooltip: 'Nearby Health Centers',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NearbyPlacesScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.green[700],
        elevation: 4.0,
      ),
      drawer: HistoryDrawer(
        history: _conversationHistory,
        onLoadConversation: _loadConversation,
        onNewConversation: _startNewConversation,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) => MessageBubble(message: _messages[index]),
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _transcribedText.isNotEmpty ? _transcribedText : "सुन रहा है...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.w500),
              ),
            ),
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 64,
              color: _speechInitialized ? Colors.green[600] : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _speechInitialized
                  ? 'नमस्ते! पूछने के लिए माइक दबाएं।'
                  : 'माइक्रोफोन की अनुमति आवश्यक है।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: _speechInitialized ? Colors.grey[700] : Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      color: Colors.white,
      child: Center(
        child: GestureDetector(
          onTap: _handleMicTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _speechInitialized ? (_isListening ? Colors.red[400] : Colors.green[600]) : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.grey, spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 35),
          ),
        ),
      ),
    );
  }
}

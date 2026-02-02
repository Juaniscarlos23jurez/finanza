import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/chat_cards/meal_card.dart';
import '../widgets/chat_cards/multi_meal_card.dart';
import '../widgets/chat_cards/nutrition_plan_card.dart';
import '../widgets/chat_cards/shopping_list_card.dart';
import '../widgets/chat_cards/summary_cards.dart';
import '../widgets/chat_cards/goal_cards.dart';
import '../widgets/chat_cards/legacy_finance_cards.dart';



class ChatScreen extends StatefulWidget {
  final String? conversationId;
  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? _currentConversationId;
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();
  
  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech-to-text status: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        debugPrint('Speech-to-text error: ${error.errorMsg}');
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.voiceError(error.errorMsg))),
          );
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.voiceUnavailable)),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
          // Si es el resultado final y hay texto, enviamos automáticamente
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _handleSend();
          }
        },
        localeId: Localizations.localeOf(context).toLanguageTag(),
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (text.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.messageTooLong(1000))),
      );
      return;
    }

    _messageController.clear();
    setState(() => _isTyping = true);
    debugPrint('ChatScreen: Handling send for text: $text');

    try {
      await _chatService.sendMessage(
        conversationId: _currentConversationId,
        text: text,
        onConversationCreated: (newId) {
          debugPrint('ChatScreen: Conversation created with ID: $newId');
          setState(() => _currentConversationId = newId);
        },
      );
      debugPrint('ChatScreen: Message sent successfully');
    } catch (e) {
      debugPrint('ChatScreen: Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.errorLabel}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HistoryDrawer(
        onChatSelected: (id) {
          setState(() => _currentConversationId = id);
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _currentConversationId == null
                    ? _buildWelcomeMessage()
                    : StreamBuilder<DatabaseEvent>(
                        stream: _chatService.getMessages(_currentConversationId!),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('${l10n.errorLabel}: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                             if (snapshot.connectionState == ConnectionState.waiting) {
                               return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                             }
                             return const SizedBox(); 
                          }

                          final data = snapshot.data!.snapshot.value;
                          final List<Message> messages = [];
                          
                          if (data is Map) {
                            data.forEach((key, value) {
                              if (value is Map) {
                                try {
                                  messages.add(_chatService.fromRealtimeDB(value));
                                } catch (e) {
                                  debugPrint('Error parsing message from Map: $e');
                                }
                              }
                            });
                          } else if (data is List) {
                            for (var item in data) {
                              if (item != null && item is Map) {
                                try {
                                  messages.add(_chatService.fromRealtimeDB(item));
                                } catch (e) {
                                  debugPrint('Error parsing message from List: $e');
                                }
                              }
                            }
                          }
                          
                          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                          WidgetsBinding.instance.addPostFrameCallback((_) { 
                             if (_scrollController.hasClients) {
                               _scrollController.animateTo(
                                 _scrollController.position.maxScrollExtent,
                                 duration: const Duration(milliseconds: 300),
                                 curve: Curves.easeOut,
                               );
                             }
                          });

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                            itemCount: messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == messages.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Text(l10n.savingIndicator, style: const TextStyle(color: AppTheme.secondary, fontSize: 10, fontStyle: FontStyle.italic)),
                                );
                              }
                              return ChatMessageWidget(message: messages[index]);
                            },
                          );
                        },
                      ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            l10n.welcomeHi,
            style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.welcomeDesc,
            style: GoogleFonts.manrope(fontSize: 15, color: AppTheme.secondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.tryAsking,
            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          _buildExampleQuestion(l10n.examplePlanQ, l10n.examplePlanD),
          _buildExampleQuestion(l10n.exampleLogQ, l10n.exampleLogD),
          _buildExampleQuestion(l10n.exampleSummaryQ, l10n.exampleSummaryD),
          _buildExampleQuestion(l10n.exampleGoalQ, l10n.exampleGoalD),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppTheme.accent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.micTip,
                    style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleQuestion(String question, String description) {
    // Extract actual text from localized string in case it has emojis/formatting we don't want in the text input
    // But usually the user wants the exact text.
    final String cleanQuestion = question.replaceFirst('📋 ', '').replaceFirst('🍽️ ', '').replaceFirst('📊 ', '').replaceFirst('🎯 ', '').replaceAll('"', '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _messageController.text = cleanQuestion;
          // Focus the input field if possible, or just let the user edit
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppTheme.primary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Text(
            l10n.nutricionAi,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: AppTheme.primary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
            onPressed: () {
               setState(() => _currentConversationId = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _isListening ? AppTheme.primary.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: _isListening 
                    ? Border.all(color: AppTheme.primary, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: _isListening 
                            ? l10n.listeningLabel 
                            : l10n.askHint,
                        hintStyle: GoogleFonts.manrope(
                          color: _isListening ? AppTheme.primary : AppTheme.secondary,
                          fontStyle: _isListening ? FontStyle.italic : FontStyle.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none_outlined,
                      color: _isListening ? Colors.red : AppTheme.secondary,
                    ),
                    onPressed: _toggleListening,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: _isListening ? Colors.red : AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isListening ? Icons.stop_rounded : Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _isListening ? _toggleListening : _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}


class ChatMessageWidget extends StatefulWidget {
  final Message message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // Recursively convert Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _deepConvertMap(Map<dynamic, dynamic> map) {
    return map.map<String, dynamic>((key, value) {
      final stringKey = key.toString();
      if (value is Map) {
        return MapEntry(stringKey, _deepConvertMap(value));
      } else if (value is List) {
        return MapEntry(stringKey, value.map((item) {
          if (item is Map) return _deepConvertMap(item);
          return item;
        }).toList());
      }
      return MapEntry(stringKey, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: widget.message.isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (widget.message.isAi)
             Row(
               children: [
                 const Icon(FontAwesomeIcons.robot, size: 12, color: AppTheme.secondary),
                 const SizedBox(width: 8),
                 Text(
                   l10n.aiAssistantLabel,
                   style: GoogleFonts.manrope(
                     fontSize: 10,
                     fontWeight: FontWeight.w800,
                     color: AppTheme.secondary,
                     letterSpacing: 1.0,
                   ),
                 ),
               ],
             )
          else
            Text(
              l10n.userLabel,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
                letterSpacing: 1.0,
              ),
            ),
          const SizedBox(height: 8),
          if (widget.message.isGenUI)
            _buildGenUIPlaceholder()
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
              decoration: BoxDecoration(
                color: widget.message.isAi ? Colors.white : AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(widget.message.isAi ? 4 : 22),
                  bottomRight: Radius.circular(widget.message.isAi ? 22 : 4),
                ),
                boxShadow: widget.message.isAi
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ]
                    : [],
              ),
              child: Text(
                widget.message.text,
                style: GoogleFonts.manrope(
                  color: widget.message.isAi ? const Color(0xFF2D3142) : Colors.white,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: widget.message.isAi ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenUIPlaceholder() {
    final Map<String, dynamic> data = _deepConvertMap(widget.message.data!);
    final String type = data['type'] ?? 'unknown';

    try {
      if (type == 'meal') return MealCard(data: data);
      if (type == 'multi_meal') return MultiMealCard(data: data);
      if (type == 'daily_summary') return DailySummaryCard(data: data);
      if (type == 'nutrition_goal') return NutritionGoalCard(data: data);
      if (type == 'meal_list') return MealListCard(data: data);
      if (type == 'meal_plan') return MealPlanCard(data: data);
      if (type == 'nutrition_plan') return NutritionPlanCard(data: data);
      if (type == 'view_chart') return ChartTriggerCard(data: data);
      if (type == 'shopping_list') return ShoppingListCard(data: data);
      
      // Legacy finance types
      if (type == 'transaction') return TransactionCard(data: data);
      if (type == 'multi_transaction') return MultiTransactionCard(data: data);
      if (type == 'balance') return BalanceCard(data: data);
      if (type == 'goal_suggestion') return GoalSuggestionCard(data: data);
      if (type == 'transaction_list') return TransactionListCard(data: data);
    } catch (e) {
      debugPrint('CRASH rendering card type $type: $e');
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(l10n.cardError(type), style: const TextStyle(color: Colors.red)),
      );
    }

    return const SizedBox.shrink();
  }
}
class HistoryDrawer extends StatelessWidget {
  final Function(String?) onChatSelected;
  const HistoryDrawer({super.key, required this.onChatSelected});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppTheme.background,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.historyLabel,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: chatService.getUserConversations(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(l10n.errorLabel, style: GoogleFonts.manrope(color: Colors.red));
                    }
                    if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                       return const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2));
                    }
                    
                    final data = snapshot.data!.snapshot.value;
                    if (data == null || (data is Map && data.isEmpty)) {
                      return Text(l10n.noRecentData, style: GoogleFonts.manrope(color: AppTheme.secondary));
                    }

                    // Convert map to list and sort
                    final List<MapEntry<dynamic, dynamic>> entries = [];
                    if (data is Map) {
                       entries.addAll(data.entries);
                    }
                    
                    entries.sort((a, b) {
                       final tA = a.value['last_activity'] as int? ?? 0;
                       final tB = b.value['last_activity'] as int? ?? 0;
                       return tB.compareTo(tA);
                    });

                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final key = entries[index].key;
                        final value = entries[index].value as Map<dynamic, dynamic>;
                        
                        String dateLabel = '';
                        if (value['last_activity'] is int) {
                           final dt = DateTime.fromMillisecondsSinceEpoch(value['last_activity'] as int);
                           dateLabel = '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                        }
                        
                        return GestureDetector(
                          onTap: () {
                             Navigator.pop(context); // Close drawer
                             onChatSelected(key);
                          },
                          child: _buildHistoryItem(value['title']?.toString() ?? l10n.noRecentData, dateLabel),
                        );
                      },
                    );
                  },
                ),
              ),
              CustomDrawerButton(
                icon: Icons.add_rounded,
                text: l10n.newChatBtn,
                onPressed: () {
                   Navigator.pop(context);
                   onChatSelected(null);
                },
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(date, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDrawerButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  const CustomDrawerButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : AppTheme.primary,
          foregroundColor: isSecondary ? AppTheme.primary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Text(text, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

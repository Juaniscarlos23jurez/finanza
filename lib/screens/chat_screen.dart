
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../models/message_model.dart';
import '../services/finance_service.dart';
import '../services/chat_service.dart';
import '../services/ad_service.dart';

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

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de voz: ${error.errorMsg}')),
          );
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reconocimiento de voz no disponible')),
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
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
        localeId: 'es_MX', // Español México
      );
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _isTyping = true);

    try {
      await _chatService.sendMessage(
        conversationId: _currentConversationId,
        text: text,
        onConversationCreated: (newId) {
          setState(() => _currentConversationId = newId);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                            return Center(child: Text('Error: ${snapshot.error}'));
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
                                final map = value as Map<dynamic, dynamic>;
                                messages.add(_chatService.fromRealtimeDB(map, key: key?.toString()));
                              });
                           } else if (data is List) {
                             // Lists in Firebase are tricky with keys if indices are used, but typically we push() which makes keys
                             // If it's a list, we might not have string keys easily unless we restructure.
                             // For now assuming Map which is standard for push()
                             for (var item in data) {
                               if (item != null) {
                                 messages.add(_chatService.fromRealtimeDB(item as Map<dynamic, dynamic>));
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
                                return const Padding(
                                  padding: EdgeInsets.only(bottom: 24),
                                  child: Text('La IA está pensando...', style: TextStyle(color: AppTheme.secondary, fontSize: 10, fontStyle: FontStyle.italic)),
                                );
                              }
                              return ChatMessageWidget(
                                message: messages[index],
                                conversationId: _currentConversationId,
                              );
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(FontAwesomeIcons.robot, size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Hola! Soy tu asistente financiero.',
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia una conversación para comenzar.',
            style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary),
          ),
        ],
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
            'FINANZAS AI',
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
                            ? "Escuchando..." 
                            : "Pregunta sobre tus finanzas...",
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
  final String? conversationId;

  const ChatMessageWidget({super.key, required this.message, this.conversationId});

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  bool _isSaving = false;
  // bool _isSaved = false; // We will use widget.message.isHandled instead
  final FinanceService _financeService = FinanceService();
  final ChatService _chatService = ChatService();

  Future<void> _markAsHandled() async {
    if (widget.conversationId != null && widget.message.key != null) {
      await _chatService.updateMessage(
        widget.conversationId!, 
        widget.message.key!, 
        {'is_handled': true}
      );
    }
  }

  Future<void> _saveTransaction(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    
    try {
      final bool isExpense = data['is_expense'] ?? true;
      
      await _financeService.createRecord({
        'amount': double.tryParse(data['amount'].toString()) ?? 0.0,
        'category': data['category'] ?? 'General',
        'type': isExpense ? 'expense' : 'income',
        'date': DateTime.now().toIso8601String().split('T')[0],
        'description': data['description'] ?? 'Transacción AI',
      });

      await _markAsHandled();

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento registrado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
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
                   'ASISTENTE IA',
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
              'TÚ',
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
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              decoration: BoxDecoration(
                color: widget.message.isAi ? Colors.white : AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(widget.message.isAi ? 4 : 20),
                  bottomRight: Radius.circular(widget.message.isAi ? 20 : 4),
                ),
                boxShadow: widget.message.isAi
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Text(
                widget.message.text,
                style: GoogleFonts.manrope(
                  color: widget.message.isAi ? AppTheme.primary : Colors.white,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: widget.message.isAi ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenUIPlaceholder() {
    if (widget.message.data == null) return const SizedBox.shrink();

    final data = widget.message.data!;
    final String type = data['type'] ?? 'unknown';

    switch (type) {
      case 'goal_suggestion':
        return _buildGoalSuggestionCard(data);
      case 'transaction':
        return _buildTransactionCard(data);
      case 'multi_transaction':
        return _buildMultiTransactionCard(data);
      case 'balance':
        return _buildBalanceCard(data);
      case 'transaction_list':
        return _buildTransactionListCard(data);
      case 'view_chart':
        return _buildChartTriggerCard(data);
      case 'premium_analysis':
        return _buildPremiumAnalysisCard(data);
      case 'csv_export':
        return _buildCsvExportCard(data);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPremiumAnalysisCard(Map<String, dynamic> data) {
    // If isHandled is true, it means the content is UNLOCKED
    final bool isUnlocked = widget.message.isHandled;
    final String title = data['title'] ?? 'Análisis Premium';
    final String summary = data['summary'] ?? 'Contenido exclusivo desbloqueable.';
    final String content = data['content'] ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnlocked 
            ? [Colors.white, Colors.white]
            : [const Color(0xFF2E3192), const Color(0xFF1BFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.auto_awesome, 
                    color: isUnlocked ? AppTheme.primary : Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppTheme.primary : Colors.white,
                        ),
                      ),
                      if (!isUnlocked)
                        Text(
                          'Análisis Profundo con IA',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (isUnlocked) ...[
            if (data['metrics'] != null)
             _buildReportMetrics(data['metrics']),
          
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: MarkdownBody(
                data: content,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary, height: 1.6),
                  h1: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  h2: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  h3: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  listBullet: GoogleFonts.manrope(color: AppTheme.primary),
                  tableBorder: TableBorder.all(color: AppTheme.primary.withValues(alpha: 0.1), width: 1),
                  tableBody: GoogleFonts.manrope(fontSize: 13, color: AppTheme.secondary),
                  tableHead: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  tableCellsPadding: const EdgeInsets.all(8),
                  blockquote: GoogleFonts.manrope(fontSize: 14, color: AppTheme.primary, fontStyle: FontStyle.italic),
                  blockquoteDecoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 12, color: AppTheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    'Análisis generado por Finanzas AI',
                    style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
             // Locked State
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: Text(
                 summary,
                 style: GoogleFonts.manrope(color: Colors.white, fontSize: 14, height: 1.5),
               ),
             ),
             const SizedBox(height: 24),
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(24),
               decoration: const BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.only(
                   bottomLeft: Radius.circular(22), // slightly less than outer
                   bottomRight: Radius.circular(22),
                 ),
               ),
               child: Column(
                 children: [
                   Text(
                     'Este reporte contiene información estratégica de alto valor.',
                     textAlign: TextAlign.center,
                     style: GoogleFonts.manrope(
                       color: AppTheme.secondary,
                       fontSize: 12,
                     ),
                   ),
                   const SizedBox(height: 16),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                     onPressed: _isSaving ? null : _showRewardedAd,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppTheme.primary,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       elevation: 0,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
                     ),
                     child: _isSaving 
                         ? const SizedBox(
                             height: 20,
                             width: 20,
                             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                           )
                         : Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               const Icon(Icons.play_circle_fill_rounded, size: 20),
                               const SizedBox(width: 8),
                               Text(
                                 'Ver Video para Desbloquear',
                                 style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                               ),
                             ],
                           ),
                   ),
                   ),
                 ],
               ),
             ),
          ],
        ],
      ),
    );
  }

  Widget _buildCsvExportCard(Map<String, dynamic> data) {
    final String filename = data['filename'] ?? 'export.csv';
    final String csvData = data['data'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined, color: Colors.green, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Reporte CSV Listo',
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            filename,
            style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _shareCsv(filename, csvData),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(
                'Compartir / Guardar CSV',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareCsv(String filename, String data) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(data);
      
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Aquí tienes mi reporte financiero.',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir CSV: $e')),
        );
      }
    }
  }

  Widget _buildReportMetrics(dynamic metrics) {
    if (metrics is! List) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: metrics.map((m) {
          final String label = m['label'] ?? '';
          final String value = m['value'] ?? '';
          final String iconName = m['icon'] ?? 'star';
          
          IconData displayIcon = Icons.auto_graph_rounded;
          if (iconName == 'trending_up') displayIcon = Icons.trending_up_rounded;
          if (iconName == 'trending_down') displayIcon = Icons.trending_down_rounded;
          if (iconName == 'savings') displayIcon = Icons.savings_rounded;
          if (iconName == 'warning') displayIcon = Icons.warning_amber_rounded;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(displayIcon, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showRewardedAd() {
    setState(() => _isSaving = true); // Loading state
    AdService().loadRewardedAd(
      onAdLoaded: (ad) {
        setState(() => _isSaving = false);
        ad.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            // User watched the ad! Unlock the content.
            _markAsHandled(); // This persists "unlocked" state to Firebase
            // _markAsHandled call will update the widget via StreamBuilder update in parent or strict setState if local?
            // Since we are inside a widget that might not rebuild from stream instantly without parent update, let's force local update too.
            // But actually ChatMessageWidget receives 'message' as param. 
            // We should optimistically update local state or rely on Firebase Stream.
            // For immediate feedback let's assume parent stream updates automatically.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Contenido desbloqueado!'), backgroundColor: Colors.green),
            );
          }
        );
      },
      onAdFailedToLoad: (error) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo cargar el anuncio. Intenta de nuevo. ($error)'), backgroundColor: Colors.red),
        );
      },
    );
  }

  Widget _buildTransactionListCard(Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Resumen de Movimientos',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Concepto', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary))),
                Expanded(child: Text('Monto', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary), textAlign: TextAlign.right)),
                Expanded(child: Text('Resultó', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary), textAlign: TextAlign.right)),
                Expanded(child: Text('Impacto', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...items.take(5).map((item) {
            final bool isExpense = item['is_expense'] ?? true;
            final double amount = double.tryParse(item['amount'].toString()) ?? 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['description'] ?? 'Item', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(item['date'] ?? '', style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${amount.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${(double.tryParse(item['balance']?.toString() ?? '') ?? 0.0).toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isExpense ? Colors.red : Colors.green).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isExpense ? 'Baja 📉' : 'Sube 📈',
                          style: GoogleFonts.manrope(
                            fontSize: 9, 
                            fontWeight: FontWeight.bold,
                            color: isExpense ? Colors.red : Colors.green
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (items.isEmpty)
             Center(child: Text('Sin datos recientes', style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary)))
          else ...[
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance Resultante',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondary),
                ),
                Text(
                  '\$${(double.tryParse(data['total_balance']?.toString() ?? '') ?? double.tryParse(data['balance']?.toString() ?? '') ?? 0.0).toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900, 
                    fontSize: 18, 
                    color: AppTheme.primary
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultiTransactionCard(Map<String, dynamic> data) {
    final List<dynamic> transactions = data['transactions'] ?? [];

    if (transactions.isEmpty) return const SizedBox.shrink();

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in transactions) {
      final amount = double.tryParse(t['amount'].toString()) ?? 0;
      if (t['is_expense'] == true) {
        totalExpense += amount;
      } else {
        totalIncome += amount;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${transactions.length} Transacciones',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (totalIncome >= totalExpense ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  totalIncome >= totalExpense 
                      ? '+\$${(totalIncome - totalExpense).toStringAsFixed(2)}' 
                      : '-\$${(totalExpense - totalIncome).toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: totalIncome >= totalExpense ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // List of transactions
          ...transactions.map((t) {
            final bool isExpense = t['is_expense'] ?? true;
            final double amount = double.tryParse(t['amount'].toString()) ?? 0;
            final String desc = t['description'] ?? 'Transacción';
            final String category = t['category'] ?? 'General';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isExpense ? Colors.red : Colors.green).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 16,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          desc,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          category,
                          style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.secondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isExpense ? "-" : "+"}\$${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          // Summary row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Ingresos', style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary)),
                    Text('+\$${totalIncome.toStringAsFixed(2)}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.grey.withValues(alpha: 0.2)),
                Column(
                  children: [
                    Text('Gastos', style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary)),
                    Text('-\$${totalExpense.toStringAsFixed(2)}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Save all button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || widget.message.isHandled) ? null : () => _saveAllTransactions(transactions),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.message.isHandled ? Colors.green : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.message.isHandled ? Icons.check_circle_outline : Icons.save_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.message.isHandled ? 'Todo Guardado' : 'Guardar ${transactions.length} Transacciones',
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAllTransactions(List<dynamic> transactions) async {
    setState(() => _isSaving = true);

    try {
      for (var t in transactions) {
        final bool isExpense = t['is_expense'] ?? true;
        await _financeService.createRecord({
          'amount': double.tryParse(t['amount'].toString()) ?? 0.0,
          'category': t['category'] ?? 'General',
          'type': isExpense ? 'expense' : 'income',
          'date': DateTime.now().toIso8601String().split('T')[0],
          'description': t['description'] ?? 'Transacción AI',
        });
      }
      
      await _markAsHandled();

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${transactions.length} transacciones guardadas')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Widget _buildGoalSuggestionCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.flag_rounded, color: Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sugerencia de Meta',
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(data['title'] ?? 'Meta', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text('Objetivo: \$${data['target_amount']}', style: GoogleFonts.manrope(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(data['reason'] ?? '', style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || widget.message.isHandled) ? null : () => _createGoal(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.message.isHandled ? Colors.green : Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(widget.message.isHandled ? 'Meta Creada' : 'Crear Meta', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTriggerCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.bar_chart_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Análisis Disponible', style: GoogleFonts.manrope(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  data['message'] ?? 'Ver gráficas detalladas',
                  style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ve a la pestaña "Movimientos" para ver los gráficos.')));
            },
            style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _createGoal(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    try {
      final financeService = FinanceService();
      await financeService.createGoal({
        'title': data['title'],
        'target_amount': double.tryParse(data['target_amount'].toString()) ?? 0.0,
        'target_date': DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0], // Default 30 days
        'current_amount': 0.0,
        'status': 'active',
        'description': data['reason'] ?? 'Meta creada por AI',
      });

      await _markAsHandled();

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meta creada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear meta: $e')),
        );
      }
    }
  }

  Widget _buildTransactionCard(Map<String, dynamic> data) {
    final bool isExpense = data['is_expense'] ?? true;
    final double amount = double.tryParse(data['amount'].toString()) ?? 0.0;
    final String category = data['category'] ?? 'General';
    final String description = data['description'] ?? 'Transacción';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ticket Generado', style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
              Icon(isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
                   color: isExpense ? Colors.redAccent : Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isExpense ? Colors.redAccent : Colors.green).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isExpense ? Icons.shopping_bag_outlined : Icons.attach_money,
                  color: isExpense ? Colors.redAccent : Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(description, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${isExpense ? "-" : "+"}\$${amount.toStringAsFixed(2)}',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900, 
                  fontSize: 20,
                  color: isExpense ? AppTheme.primary : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || widget.message.isHandled) ? null : () => _saveTransaction(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.message.isHandled ? Colors.green : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.message.isHandled ? Icons.check_circle_outline : Icons.save_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.message.isHandled ? 'Guardado' : 'Confirmar y Guardar',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Map<String, dynamic> data) {
    final double total = double.tryParse(data['total'].toString()) ?? 0.0;
    final double income = double.tryParse(data['income'].toString()) ?? 0.0;
    final double expenses = double.tryParse(data['expenses'].toString()) ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text('BALANCE ACTUAL', style: GoogleFonts.manrope(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('\$${total.toStringAsFixed(2)}', style: GoogleFonts.manrope(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Ingresos', '+\$${income.toStringAsFixed(0)}', Colors.greenAccent),
              _buildMiniStat('Gastos', '-\$${expenses.toStringAsFixed(0)}', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.manrope(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class HistoryDrawer extends StatelessWidget {
  final Function(String?) onChatSelected;
  const HistoryDrawer({super.key, required this.onChatSelected});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    // Assuming context is sufficient for Theme and MediaQuery, and we can instantiate ChatService safely.

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
                'HISTORIAL',
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
                      return Text('Error cargando historial', style: GoogleFonts.manrope(color: Colors.red));
                    }
                    if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                       return const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2));
                    }
                    
                    final data = snapshot.data!.snapshot.value;
                    if (data == null || (data is Map && data.isEmpty)) {
                      return Text('No hay conversaciones guardadas.', style: GoogleFonts.manrope(color: AppTheme.secondary));
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
                          child: _buildHistoryItem(value['title']?.toString() ?? 'Conversación sin título', dateLabel),
                        );
                      },
                    );
                  },
                ),
              ),
              CustomDrawerButton(
                icon: Icons.add_rounded,
                text: 'Nuevo Chat',
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

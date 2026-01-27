import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';
import '../models/message_model.dart';
import '../services/finance_service.dart';
import '../services/chat_service.dart';
import '../services/nutrition_service.dart';

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
        localeId: 'es_MX', // Español México
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
                               messages.add(_chatService.fromRealtimeDB(map));
                             });
                          } else if (data is List) {
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
            '¡Hola! Soy tu asistente nutricional.',
            style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Puedo ayudarte con planes personalizados, seguimiento de comidas y consejos nutricionales.',
            style: GoogleFonts.manrope(fontSize: 15, color: AppTheme.secondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          Text(
            'Prueba preguntando:',
            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          _buildExampleQuestion('📋 "Crea un plan de comidas para hoy"', 'Genera un plan completo con horarios y calorías'),
          _buildExampleQuestion('🍽️ "Registra mi desayuno: huevos y pan integral"', 'Calcula macros y calorías automáticamente'),
          _buildExampleQuestion('📊 "Muestra mi resumen nutricional de hoy"', 'Visualiza tu progreso diario'),
          _buildExampleQuestion('🎯 "Ayúdame a perder 5kg en 2 meses"', 'Crea metas personalizadas'),
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
                    'Tip: Usa el micrófono para hablar naturalmente',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            'NUTRICIÓN AI',
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
                            : "Pregunta sobre tu nutrición...",
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
  bool _isSaving = false;
  bool _isSaved = false;
  final FinanceService _financeService = FinanceService();

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

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
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
    if (widget.message.data == null) return const SizedBox.shrink();

    final data = widget.message.data!;
    final String type = data['type'] ?? 'unknown';

    // Nutrition-specific types
    if (type == 'meal') {
      return _buildMealCard(data);
    } else if (type == 'multi_meal') {
      return _buildMultiMealCard(data);
    } else if (type == 'daily_summary') {
      return _buildDailySummaryCard(data);
    } else if (type == 'nutrition_goal') {
      return _buildNutritionGoalCard(data);
    } else if (type == 'meal_list') {
      return _buildMealListCard(data);
    } else if (type == 'meal_plan') {
      return _buildMealPlanCard(data);
    } else if (type == 'nutrition_plan') {
      return _buildNutritionPlanCard(data);
    } else if (type == 'view_chart') {
      return _buildChartTriggerCard(data);
    } else if (type == 'shopping_list') {
      return _buildShoppingListCard(data);
    }
    // Legacy finance types (for backward compatibility)
    else if (type == 'transaction') {
      return _buildTransactionCard(data);
    } else if (type == 'multi_transaction') {
      return _buildMultiTransactionCard(data);
    } else if (type == 'balance') {
      return _buildBalanceCard(data);
    } else if (type == 'goal_suggestion') {
      return _buildGoalSuggestionCard(data);
    } else if (type == 'transaction_list') {
      return _buildTransactionListCard(data);
    }

    return const SizedBox.shrink();
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
              onPressed: (_isSaving || _isSaved) ? null : () => _saveAllTransactions(transactions),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isSaved ? Icons.check_circle_outline : Icons.save_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isSaved ? 'Todo Guardado' : 'Guardar ${transactions.length} Transacciones',
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

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
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
              onPressed: (_isSaving || _isSaved) ? null : () => _createGoal(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.green : Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isSaved ? 'Meta Creada' : 'Crear Meta', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white)),
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

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
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
              onPressed: (_isSaving || _isSaved) ? null : () => _saveTransaction(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
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
                      Icon(_isSaved ? Icons.check_circle_outline : Icons.save_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isSaved ? 'Guardado' : 'Confirmar y Guardar',
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


  // ============ NUTRITION-SPECIFIC CARDS ============

  Widget _buildMealCard(Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Comida';
    final int calories = int.tryParse(data['calories'].toString()) ?? 0;
    final int protein = int.tryParse(data['protein'].toString()) ?? 0;
    final int carbs = int.tryParse(data['carbs'].toString()) ?? 0;
    final int fats = int.tryParse(data['fats'].toString()) ?? 0;
    final double score = double.tryParse(data['score']?.toString() ?? '0') ?? 0;
    final String description = data['description'] ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic header
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('REGISTRO NUTRICIONAL', 
                      style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    Text(name, 
                      style: GoogleFonts.manrope(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (score > 0)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Text(score.toStringAsFixed(1), style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(description, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 20),
                ],
                // Macros visualization
                Row(
                  children: [
                    _buildMacroPill('Proteína', '${protein}g', Colors.red.shade400, Icons.fitness_center),
                    const SizedBox(width: 8),
                    _buildMacroPill('Carbos', '${carbs}g', Colors.orange.shade400, Icons.grain),
                    const SizedBox(width: 8),
                    _buildMacroPill('Grasas', '${fats}g', Colors.amber.shade600, Icons.opacity),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('CALORÍAS TOTALES', style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.w900)),
                         Text('$calories kcal', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                       ],
                     ),
                     ElevatedButton(
                       onPressed: (_isSaving || _isSaved) ? null : () => _saveMeal(data),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                         elevation: 0,
                       ),
                       child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_isSaved ? 'GUARDADO' : 'CONFIRMAR', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
                     ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPill(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.manrope(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
            Text(label, style: GoogleFonts.manrope(color: color.withValues(alpha: 0.7), fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }


  Future<void> _saveMeal(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    
    try {
      final nutritionService = NutritionService();
      await nutritionService.saveDailyMeals([data]);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comida registrada correctamente'),
            backgroundColor: Colors.green,
          ),
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

  Widget _buildMultiMealCard(Map<String, dynamic> data) {
    final List<dynamic> meals = data['meals'] ?? [];
    if (meals.isEmpty) return const SizedBox.shrink();

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFats = 0;

    for (var meal in meals) {
      totalCalories += int.tryParse(meal['calories'].toString()) ?? 0;
      totalProtein += int.tryParse(meal['protein'].toString()) ?? 0;
      totalCarbs += int.tryParse(meal['carbs'].toString()) ?? 0;
      totalFats += int.tryParse(meal['fats'].toString()) ?? 0;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMIDAS DEL DÍA', 
                      style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    Text('${meals.length} Registros', 
                      style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('$totalCalories kcal', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...meals.map((meal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.restaurant_menu, size: 16, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meal['name'] ?? 'Comida', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                              Text(meal['description'] ?? '', style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.secondary)),
                            ],
                          ),
                        ),
                        Text('${meal['calories']} kcal', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primary)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSmallMacro('Prot', '${totalProtein}g', Colors.red.shade400),
                    _buildSmallMacro('Carb', '${totalCarbs}g', Colors.orange.shade400),
                    _buildSmallMacro('Grasa', '${totalFats}g', Colors.amber.shade600),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isSaving || _isSaved) ? null : () => _saveAllMeals(meals),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(_isSaved ? 'TODO GUARDADO' : 'REGISTRAR TODO', 
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMacro(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.manrope(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
        Text(label, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _saveAllMeals(List<dynamic> meals) async {
    setState(() => _isSaving = true);

    try {
      final nutritionService = NutritionService();
      await nutritionService.saveDailyMeals(meals);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meals.length} comidas guardadas'),
            backgroundColor: Colors.green,
          ),
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

  Widget _buildDailySummaryCard(Map<String, dynamic> data) {
    final int totalCalories = int.tryParse(data['total_calories'].toString()) ?? 0;
    final int protein = int.tryParse(data['protein'].toString()) ?? 0;
    final int carbs = int.tryParse(data['carbs'].toString()) ?? 0;
    final int fats = int.tryParse(data['fats'].toString()) ?? 0;
    final double water = double.tryParse(data['water_liters'].toString()) ?? 0.0;

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
          Text('RESUMEN DE HOY', style: GoogleFonts.manrope(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$totalCalories kcal', style: GoogleFonts.manrope(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Proteína', '${protein}g', Colors.red.shade200),
              _buildMiniStat('Carbos', '${carbs}g', Colors.orange.shade200),
              _buildMiniStat('Grasas', '${fats}g', Colors.amber.shade200),
            ],
          ),
          if (water > 0) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, color: Colors.lightBlueAccent, size: 16),
                const SizedBox(width: 8),
                Text('${water.toStringAsFixed(1)}L de agua', style: GoogleFonts.manrope(color: Colors.white, fontSize: 14)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionGoalCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
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
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.flag_rounded, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Meta Nutricional Sugerida',
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(data['title'] ?? 'Meta', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text('Objetivo: ${data['target_value']}', style: GoogleFonts.manrope(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(data['reason'] ?? '', style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || _isSaved) ? null : () => _createNutritionGoal(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isSaved ? 'Meta Creada' : 'Crear Meta', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNutritionGoal(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    try {
      final nutritionService = NutritionService();
      await nutritionService.saveGoal(data);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
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

  Widget _buildMealListCard(Map<String, dynamic> data) {
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
              const Icon(Icons.history, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Historial de Comidas',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Center(child: Text('Sin comidas registradas', style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary)))
          else
            ...items.take(10).map((item) {
              final String name = item['name'] ?? 'Comida';
              final int calories = int.tryParse(item['calories'].toString()) ?? 0;
              final String time = item['time'] ?? '';
              final bool healthy = item['healthy'] ?? true;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (healthy ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        healthy ? Icons.check_circle : Icons.warning_amber_rounded,
                        size: 16,
                        color: healthy ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (time.isNotEmpty)
                            Text(time, style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.secondary)),
                        ],
                      ),
                    ),
                    Text(
                      '$calories kcal',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMealPlanCard(Map<String, dynamic> data) {
    final List<dynamic> meals = data['meals'] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
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
              const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Plan de Comidas Sugerido',
                style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...meals.map((meal) {
            final String mealType = meal['meal'] ?? 'Comida';
            final String suggestion = meal['suggestion'] ?? '';
            final int calories = int.tryParse(meal['calories'].toString()) ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mealType, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(suggestion, style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('$calories kcal', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNutritionPlanCard(Map<String, dynamic> data) {
    final List<dynamic> days = data['days'] ?? (data['meals'] != null ? [{'day': 'Hoy', 'meals': data['meals']}] : []);
    final int calories = int.tryParse(data['daily_calories'].toString()) ?? 0;
    final Map macros = data['macros'] ?? {};

    return DefaultTabController(
      length: days.length,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PLAN PERSONALIZADO', 
                        style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text('$calories kcal / día', style: GoogleFonts.manrope(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                         child: Text('Objetivo Alcanzado', style: GoogleFonts.manrope(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                       ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMacroDisplay('Prot', '${macros['protein']}g', Colors.red.shade200),
                      _buildMacroDisplay('Carb', '${macros['carbs']}g', Colors.orange.shade200),
                      _buildMacroDisplay('Grasa', '${macros['fats']}g', Colors.amber.shade200),
                    ],
                  ),
                ],
              ),
            ),
            if (days.length > 1)
              TabBar(
                isScrollable: true,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.secondary,
                indicatorColor: AppTheme.accent,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: days.map<Widget>((d) => Tab(text: d['day']?.toString() ?? 'Día')).toList(),
              ),
            SizedBox(
              height: 250,
              child: TabBarView(
                children: days.map<Widget>((dayData) {
                  final List<dynamic> meals = dayData['meals'] ?? [];
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: meals.map((meal) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(meal['time'] ?? '00:00', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.secondary)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(meal['name'] ?? '', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                                  Text(meal['details'] ?? '', style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isSaved) ? null : () => _saveNutritionPlan(data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(_isSaved ? 'PLAN GUARDADO' : 'ACTIVAR ESTE PLAN', 
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.manrope(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
        Text(label, style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }


  Future<void> _saveNutritionPlan(Map<String, dynamic> data) async {
    setState(() => _isSaving = true);
    try {
      final nutritionService = NutritionService();
      await nutritionService.savePlan(data);
      
      // Also sync current day's meals to the Daily Timeline
      final List<dynamic> days = data['days'] ?? (data['meals'] != null ? [{'day': 'Hoy', 'meals': data['meals']}] : []);
      if (days.isNotEmpty) {
        final List<dynamic> dailyMeals = days[0]['meals'] ?? [];
        await nutritionService.saveDailyMeals(dailyMeals);
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan nutricional guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar plan: $e')),
        );
      }
    }
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

  Widget _buildShoppingListCard(Map<String, dynamic> data) {
    final String title = data['title'] ?? 'Lista de Compras';
    final List<dynamic> items = data['items'] ?? [];

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LISTA GENERADA',
                        style: GoogleFonts.manrope(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length} items',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...items.map((item) {
                  final String name = item['name'] ?? item.toString();
                  final String quantity = item['quantity'] ?? '1 unidad';
                  final String category = item['category'] ?? 'Otros';
                  
                  Color categoryColor = AppTheme.secondary;
                  IconData categoryIcon = Icons.shopping_basket_outlined;
                  
                  if (category.contains('Proteína')) {
                    categoryColor = Colors.red.shade400;
                    categoryIcon = Icons.egg_outlined;
                  } else if (category.contains('Verdura')) {
                    categoryColor = Colors.green.shade400;
                    categoryIcon = Icons.eco_outlined;
                  } else if (category.contains('Fruta')) {
                    categoryColor = Colors.orange.shade400;
                    categoryIcon = Icons.apple_outlined;
                  } else if (category.contains('Grano')) {
                    categoryColor = Colors.amber.shade600;
                    categoryIcon = Icons.grain_outlined;
                  } else if (category.contains('Lácteo')) {
                    categoryColor = Colors.blue.shade300;
                    categoryIcon = Icons.water_drop_outlined;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(categoryIcon, size: 18, color: categoryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    quantity,
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: AppTheme.secondary.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      category,
                                      style: GoogleFonts.manrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: categoryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isSaving || _isSaved) ? null : () => _saveShoppingList(items),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSaved ? Icons.check_circle : Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isSaved ? 'AGREGADO A LA DESPENSA' : 'AGREGAR TODO A LA DESPENSA',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveShoppingList(List<dynamic> items) async {
    setState(() => _isSaving = true);

    try {
      final nutritionService = NutritionService();
      
      // Save all items to Firebase shopping_list node
      await nutritionService.saveShoppingList(items);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${items.length} items agregados a la Despensa'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'VER',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to pantry screen (index 2 in main_screen)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
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

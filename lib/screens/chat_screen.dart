import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../models/message_model.dart';
import '../services/finance_service.dart';
import '../services/chat_service.dart';

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

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
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
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.secondary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: "Escribe algo...",
                        hintStyle: GoogleFonts.manrope(color: AppTheme.secondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none_outlined, color: AppTheme.secondary),
                    onPressed: () {},
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
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _handleSend,
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

    if (type == 'transaction') {
      return _buildTransactionCard(data);
    } else if (type == 'balance') {
      return _buildBalanceCard(data);
    } else if (type == 'goal_suggestion') {
      return _buildGoalSuggestionCard(data);
    } else if (type == 'view_chart') {
      return _buildChartTriggerCard(data);
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
              const SizedBox(height: 12),
              CustomDrawerButton(
                icon: Icons.settings_outlined,
                text: 'Configuración',
                onPressed: () {},
                isSecondary: true,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../models/message_model.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AiService _aiService = AiService();
  final List<Message> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      Message(
        text: "Hola! Soy tu asistente financiero inteligente. ¿En qué puedo ayudarte hoy?",
        isAi: true,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add(Message(text: text, isAi: false, timestamp: DateTime.now()));
      _isTyping = true;
    });

    final aiResponse = await _aiService.sendMessage(text);

    setState(() {
      _messages.add(aiResponse);
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HistoryDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Text('AI is thinking...', style: TextStyle(color: AppTheme.secondary, fontSize: 10, fontStyle: FontStyle.italic)),
                      );
                    }
                    final message = _messages[index];
                    return ChatMessageWidget(message: message);
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
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.primary),
            onPressed: () {},
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


class ChatMessageWidget extends StatelessWidget {
  final Message message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: message.isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (message.isAi)
             Row(
               children: [
                 const Icon(FontAwesomeIcons.robot, size: 12, color: AppTheme.secondary),
                 const SizedBox(width: 8),
                 Text(
                   'AI ASSISTANT',
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
              'YOU',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondary,
                letterSpacing: 1.0,
              ),
            ),
          const SizedBox(height: 8),
          if (message.isGenUI)
            _buildGenUIPlaceholder(context)
          else
            Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              decoration: BoxDecoration(
                color: message.isAi ? Colors.white : AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isAi ? 4 : 20),
                  bottomRight: Radius.circular(message.isAi ? 20 : 4),
                ),
                boxShadow: message.isAi
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
                message.text,
                style: GoogleFonts.manrope(
                  color: message.isAi ? AppTheme.primary : Colors.white,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: message.isAi ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenUIPlaceholder(BuildContext context) {
    if (message.data == null) return const SizedBox.shrink();

    final data = message.data!;
    final String type = data['type'] ?? 'unknown';

    if (type == 'transaction') {
      return _buildTransactionCard(data);
    } else if (type == 'balance') {
      return _buildBalanceCard(data);
    }

    return const SizedBox.shrink();
  }

  Widget _buildTransactionCard(Map<String, dynamic> data) {
    final bool isExpense = data['is_expense'] ?? true;
    final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
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
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Map<String, dynamic> data) {
    final double total = (data['total'] as num?)?.toDouble() ?? 0.0;
    final double income = (data['income'] as num?)?.toDouble() ?? 0.0;
    final double expenses = (data['expenses'] as num?)?.toDouble() ?? 0.0;

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
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
              _buildHistoryItem('Análisis de Gastos', 'Hoy, 10:45 AM'),
              _buildHistoryItem('Presupuesto Viaje', 'Ayer, 8:20 PM'),
              _buildHistoryItem('Meta de Ahorros', '22 Feb, 2:15 PM'),
              _buildHistoryItem('Inversiones Tesla', '20 Feb, 11:00 AM'),
              const Spacer(),
              CustomDrawerButton(
                icon: Icons.add_rounded,
                text: 'Nuevo Chat',
                onPressed: () => Navigator.pop(context),
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
                Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [
    Message(
      text: "Hola! Soy tu asistente financiero inteligente. ¿En qué puedo ayudarte hoy?",
      isAi: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Message(
      text: "¿Cómo van mis ahorros este mes?",
      isAi: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    Message(
      text: "Tus ahorros han crecido un 12% respecto al mes pasado. Aquí tienes un resumen visual de tu progreso:",
      isAi: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      isGenUI: true,
    ),
  ];

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
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
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
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _messages.add(Message(
                      text: _messageController.text,
                      isAi: false,
                      timestamp: DateTime.now(),
                    ));
                    _messageController.clear();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isAi;
  final DateTime timestamp;
  final bool isGenUI;

  Message({
    required this.text,
    required this.isAi,
    required this.timestamp,
    this.isGenUI = false,
  });
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
            _buildGenUIPlaceholder()
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

  Widget _buildGenUIPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ahorros del Mes', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Febrero 2024', style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12)),
                ],
              ),
              const Icon(Icons.trending_up, color: Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCell('Meta', '\$2,500'),
              _buildStatCell('Actual', '\$1,840'),
              _buildStatCell('Restante', '\$660'),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.73,
              backgroundColor: AppTheme.background,
              color: AppTheme.primary,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '¡Vas por buen camino! Has completado el 73% de tu meta.',
            style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  Widget _buildStatCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.manrope(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w900)),
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

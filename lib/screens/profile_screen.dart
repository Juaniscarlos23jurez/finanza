import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/finance_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FinanceService _financeService = FinanceService();
  Map<String, dynamic>? _userData;
  List<dynamic> _allTransactions = [];
  bool _isLoading = true;
  final DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchProfile(),
      _fetchTransactions(),
    ]);
  }

  Future<void> _fetchTransactions() async {
    try {
      final data = await _financeService.getFinanceData();
      if (mounted) {
        setState(() {
          _allTransactions = data['records'] as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error fetching transactions for profile calendar: $e');
    }
  }

  Future<void> _fetchProfile() async {
    final result = await _authService.getProfile();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _userData = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildCalendar(),
                  const SizedBox(height: 48),
                  _buildMenuSection('CUENTA', [
                    _buildMenuItem(Icons.person_outline_rounded, 'Información Personal', onTap: () => _showPersonalInfoModal(context)),
                    _buildMenuItem(Icons.email_outlined, 'Programar Envío de Reporte', onTap: () => _showScheduleReportModal(context)),
                    //_buildMenuItem(Icons.account_balance_wallet_outlined, 'Métodos de Pago'),
                   // _buildMenuItem(Icons.notifications_none_rounded, 'Notificaciones'),
                  ]),
                 
                  const SizedBox(height: 32),
                  _buildMenuSection('OTRO', [
                    _buildMenuItem(Icons.feedback_outlined, 'Feedback', onTap: () => _showFeedbackModal(context)),
                    _buildMenuItem(Icons.help_outline_rounded, 'Ayuda y Soporte'),
                    _buildMenuItem(
                      Icons.info_outline_rounded, 
                      'Términos y Condiciones',
                      onTap: () async {
                        final uri = Uri.parse('https://fynlink.shop/terminos_y_privacidad_app_clientes_html.html#terminos');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    _buildMenuItem(
                      Icons.privacy_tip_outlined, 
                      'Política de Privacidad',
                      onTap: () async {
                        final uri = Uri.parse('https://fynlink.shop/terminos_y_privacidad_app_clientes_html.html#privacidad');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 48),
                  _buildLogoutButton(context),
                  const SizedBox(height: 12),
                  _buildDeleteAccountButton(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final name = _userData?['name'] ?? 'Usuario';
    final email = _userData?['email'] ?? 'email@ejemplo.com';
    final photoUrl = _userData?['photo_url'];

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                  )
                ],
              ),
              child: ClipOval(
                child: photoUrl != null
                    ? Image.network(photoUrl, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.person_rounded, size: 60, color: AppTheme.primary),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
        Text(
          email,
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppTheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.secondary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool hasSwitch = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
            if (hasSwitch)
              Switch.adaptive(
                value: true,
                onChanged: (v) {},
                activeTrackColor: AppTheme.primary,
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppTheme.secondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          // Show a simple loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          await _authService.logout();

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.redAccent,
        ),
        child: Text(
          'Cerrar Sesión',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
  Widget _buildDeleteAccountButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showDeleteConfirmation(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.redAccent.withValues(alpha: 0.5),
        ),
        child: Text(
          'Eliminar mi cuenta permanentemente',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar cuenta?', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Text(
          'Esta acción no se puede deshacer. Se borrarán todos tus datos financieros de forma permanente.',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.manrope(color: AppTheme.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              final result = await _authService.deleteAccount();

              if (context.mounted) {
                Navigator.pop(context); // Close loading
                
                if (result['success']) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${result['message']}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Eliminar', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackModal(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    String selectedType = 'Sugerencia';
    final List<String> types = ['Error', 'Sugerencia', 'Felicitación'];
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            top: 32,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danos tu Feedback',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tu opinión nos ayuda a mejorar la experiencia para todos.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¿De qué trata tu comentario?',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: types.map((type) {
                  final isSelected = selectedType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => selectedType = type);
                      }
                    },
                    selectedColor: AppTheme.primary,
                    labelStyle: GoogleFonts.manrope(
                      color: isSelected ? Colors.white : AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Cuéntanos qué te gusta o qué podemos mejorar...',
                  hintStyle: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          if (feedbackController.text.trim().isEmpty) return;

                          setModalState(() => isSending = true);
                          
                          final result = await _authService.sendFeedback(
                            type: selectedType,
                            message: feedbackController.text.trim(),
                          );
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['success'] 
                                  ? '¡Gracias por tu feedback!' 
                                  : 'Error: ${result['message']}'),
                                backgroundColor: result['success'] ? Colors.green : Colors.redAccent,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isSending
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Enviar Comentarios',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: TableCalendar(
        locale: 'es',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final color = _getDayColor(day);
            if (color != null) {
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  '${day.day}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Color? _getDayColor(DateTime day) {
    double income = 0;
    double expense = 0;
    String dayStr = DateFormat('yyyy-MM-dd').format(day);
    bool hasData = false;

    for (var t in _allTransactions) {
      if ((t['date'] ?? '').toString().startsWith(dayStr)) {
        hasData = true;
        double amt = double.tryParse(t['amount'].toString()) ?? 0;
        if (t['type'] == 'income') {
          income += amt;
        } else {
          expense += amt;
        }
      }
    }

    if (!hasData) return null;
    return income >= expense 
        ? Colors.green.withValues(alpha: 0.2) 
        : Colors.red.withValues(alpha: 0.2);
  }

  void _showPersonalInfoModal(BuildContext context) {
    if (_userData == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Información Personal',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoItem('Nombre Completo', _userData?['name'] ?? 'No disponible'),
            const SizedBox(height: 16),
            _buildInfoItem('Correo Electrónico', _userData?['email'] ?? 'No disponible'),
            const SizedBox(height: 16),
            _buildInfoItem('ID de Usuario', _userData?['id']?.toString() ?? 'No disponible'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleReportModal(BuildContext context) {
    if (_userData == null) return;
    
    final email = _userData?['email'] ?? '';
    final photoUrl = (_userData?['photo_url'] ?? '').toString();
    final provider = (_userData?['provider'] ?? '').toString().toLowerCase();
    
    // Heurística para detectar login social si el backend no lo envía explícitamente
    final bool isSocial = provider.contains('google') || 
                         provider.contains('apple') || 
                         photoUrl.contains('googleusercontent') || 
                         photoUrl.contains('appleid');
    
    final TextEditingController emailController = TextEditingController(text: email);
    bool isRequesting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            top: 32,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Programar Reporte',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, color: AppTheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Recibirás un Excel con tus movimientos y un análisis financiero generado por IA.',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!isSocial) ...[
                Text(
                  'Confirma el correo de destino:',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                  ),
                ),
              ] else ...[
                Text(
                  'El reporte se enviará a tu correo registrado:',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isRequesting
                      ? null
                      : () async {
                          final targetEmail = emailController.text.trim();
                          if (targetEmail.isEmpty) return;

                          setModalState(() => isRequesting = true);
                          
                          try {
                            await _financeService.requestReport(targetEmail);
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('¡Reporte programado con éxito! Revisa tu correo.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setModalState(() => isRequesting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isRequesting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Confirmar y Programar',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

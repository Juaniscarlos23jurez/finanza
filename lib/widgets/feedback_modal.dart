import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class FeedbackModal extends StatefulWidget {
  final AuthService authService;

  const FeedbackModal({
    super.key,
    required this.authService,
  });

  @override
  State<FeedbackModal> createState() => _FeedbackModalState();

  static Future<void> show(BuildContext context, AuthService authService) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackModal(authService: authService),
    );
  }
}

class _FeedbackModalState extends State<FeedbackModal> {
  final TextEditingController _feedbackController = TextEditingController();
  late String _selectedType;
  bool _isSending = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    // We'll initialize _selectedType in didChangeDependencies to have access to context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedType = AppLocalizations.of(context)!.typeSuggestion;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_feedbackController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    final result = await widget.authService.sendFeedback(
      type: _selectedType,
      message: _feedbackController.text.trim(),
    );

    if (mounted) {
      if (result['success']) {
        setState(() {
          _isSending = false;
          _showSuccess = true;
        });
        HapticFeedback.lightImpact();
        
        // Wait a bit to show success state before closing
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result['message']}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = [
      AppLocalizations.of(context)!.typeError,
      AppLocalizations.of(context)!.typeSuggestion,
      AppLocalizations.of(context)!.typeCompliment
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showSuccess 
            ? _buildSuccessState()
            : Column(
                key: const ValueKey('form'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.feedbackTitle,
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.background,
                          foregroundColor: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.feedbackSubtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)!.feedbackTypeQuestion,
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
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedType = type);
                          }
                        },
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.background,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        labelStyle: GoogleFonts.manrope(
                          color: isSelected ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.background.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 5,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.feedbackHint,
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 14, 
                          color: AppTheme.secondary.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              AppLocalizations.of(context)!.sendFeedback,
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
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

  Widget _buildSuccessState() {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 80,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.feedbackSuccess,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

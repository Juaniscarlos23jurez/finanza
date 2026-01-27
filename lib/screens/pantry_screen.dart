import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/nutrition_service.dart';
import '../theme/app_theme.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final NutritionService _nutritionService = NutritionService();
  List<Map<String, dynamic>> _ingredients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  void _loadIngredients() {
    _nutritionService.getPlan().listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _extractIngredients(data);
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  void _extractIngredients(Map<dynamic, dynamic> plan) {
    // Logic to extract ingredients from the plan structure
    // This assumes the AI generates a 'days' or 'meals' list with 'ingredients'
    final List<Map<String, dynamic>> extracted = [];
    final List<dynamic> days = plan['days'] ?? (plan['meals'] != null ? [{'meals': plan['meals']}] : []);

    for (var day in days) {
      final List<dynamic> meals = day['meals'] ?? [];
      for (var meal in meals) {
        final List<dynamic> ingredients = meal['ingredients'] ?? [];
        for (var ing in ingredients) {
          final String name = ing is String ? ing : (ing['name'] ?? '');
          if (name.isNotEmpty && !extracted.any((e) => e['name'] == name)) {
            extracted.add({
              'name': name,
              'bought': false,
              'affiliate_url': 'https://www.amazon.com/s?k=${Uri.encodeComponent(name)}',
            });
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _ingredients = extracted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La Despensa',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                'Lista de compras automática',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : _ingredients.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _ingredients.length,
                            itemBuilder: (context, index) => _buildIngredientItem(index),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: AppTheme.secondary.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          Text(
            'Tu lista está vacía',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Activa un plan en el chat para\ngenerar ingredientes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(int index) {
    final item = _ingredients[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: item['bought'],
            activeColor: AppTheme.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              setState(() => _ingredients[index]['bought'] = val);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item['name'],
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                decoration: item['bought'] ? TextDecoration.lineThrough : null,
                color: item['bought'] ? AppTheme.secondary : AppTheme.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Simular apertura de link de afiliados
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abriendo ${item['name']} en tienda asociada...'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart_checkout_rounded, color: AppTheme.accent),
          ),
        ],
      ),
    );
  }
}

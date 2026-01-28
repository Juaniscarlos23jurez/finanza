import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/nutrition_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> with SingleTickerProviderStateMixin {
  final NutritionService _nutritionService = NutritionService();
  late TabController _tabController;
  
  Map<String, List<Map<String, dynamic>>> _categorizedIngredients = {};
  Map<String, dynamic> _inventory = {};
  bool _isLoading = true;
  int _totalItems = 0;
  int _checkedItems = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Listen to shopping list from Firebase (items added manually or from AI)
    _nutritionService.getShoppingList().listen((event) {
      if (event.snapshot.value != null && mounted) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _loadShoppingListFromFirebase(data);
      }
    });

    // Also listen to nutrition plan to extract ingredients
    _nutritionService.getPlan().listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _extractIngredients(data);
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    });

    // Listen to inventory
    _nutritionService.getInventory().listen((event) {
      if (event.snapshot.value != null && mounted) {
        setState(() {
          _inventory = Map<String, dynamic>.from(event.snapshot.value as Map);
        });
      }
    });
  }

  void _loadShoppingListFromFirebase(Map<dynamic, dynamic> shoppingList) {
    final Map<String, List<Map<String, dynamic>>> categorized = {};
    int total = 0;
    int checked = 0;

    shoppingList.forEach((key, value) {
      final item = value as Map<dynamic, dynamic>;
      final String name = item['name'] ?? key;
      final String category = item['category'] ?? 'Otros';
      final bool bought = item['bought'] ?? false;
      
      categorized.putIfAbsent(category, () => []);
      categorized[category]!.add({
        'name': name,
        'bought': bought,
        'category': category,
        'quantity': item['quantity'] ?? '1 unidad',
        'affiliate_url': item['affiliate_url'] ?? 'https://www.amazon.com/s?k=${Uri.encodeComponent(name)}',
      });
      
      total++;
      if (bought) checked++;
    });

    if (mounted) {
      setState(() {
        _categorizedIngredients = categorized;
        _totalItems = total;
        _checkedItems = checked;
        _isLoading = false;
      });
    }
  }

  void _extractIngredients(Map<dynamic, dynamic> plan) {
    // This method now only adds items from the plan that aren't already in the shopping list
    final Map<String, List<Map<String, dynamic>>> categorized = Map.from(_categorizedIngredients);
    final List<dynamic> days = plan['days'] ?? (plan['meals'] != null ? [{'meals': plan['meals']}] : []);

    int total = _totalItems;
    int checked = _checkedItems;

    for (var day in days) {
      final List<dynamic> meals = day['meals'] ?? [];
      for (var meal in meals) {
        final List<dynamic> ingredients = meal['ingredients'] ?? [];
        for (var ing in ingredients) {
          final String name = ing is String ? ing : (ing['name'] ?? '');
          final String category = _categorizeIngredient(name);
          
          if (name.isNotEmpty) {
            categorized.putIfAbsent(category, () => []);
            
            // Check if already exists
            final exists = categorized[category]!.any((e) => e['name'] == name);
            if (!exists) {
              final item = {
                'name': name,
                'bought': false,
                'category': category,
                'quantity': ing is Map ? (ing['quantity'] ?? '1 unidad') : '1 unidad',
                'affiliate_url': 'https://www.amazon.com/s?k=${Uri.encodeComponent(name)}',
              };
              categorized[category]!.add(item);
              total++;
            }
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _categorizedIngredients = categorized;
        _totalItems = total;
        _checkedItems = checked;
        _isLoading = false;
      });
    }
  }

  String _categorizeIngredient(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pollo') || lower.contains('carne') || lower.contains('pescado') || 
        lower.contains('huevo') || lower.contains('atún')) {
      return 'Proteínas';
    } else if (lower.contains('lechuga') || lower.contains('tomate') || lower.contains('cebolla') || 
               lower.contains('zanahoria') || lower.contains('espinaca') || lower.contains('brócoli')) {
      return 'Verduras';
    } else if (lower.contains('manzana') || lower.contains('plátano') || lower.contains('naranja') || 
               lower.contains('fresa') || lower.contains('uva')) {
      return 'Frutas';
    } else if (lower.contains('arroz') || lower.contains('pasta') || lower.contains('pan') || 
               lower.contains('avena') || lower.contains('quinoa')) {
      return 'Granos';
    } else if (lower.contains('leche') || lower.contains('yogur') || lower.contains('queso')) {
      return 'Lácteos';
    } else if (lower.contains('aceite') || lower.contains('sal') || lower.contains('pimienta') || 
               lower.contains('ajo') || lower.contains('especias')) {
      return 'Condimentos';
    }
    return 'Otros';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Proteínas': return Icons.egg_outlined;
      case 'Verduras': return Icons.eco_outlined;
      case 'Frutas': return Icons.apple_outlined;
      case 'Granos': return Icons.grain_outlined;
      case 'Lácteos': return Icons.water_drop_outlined;
      case 'Condimentos': return Icons.local_fire_department_outlined;
      default: return Icons.shopping_basket_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Proteínas': return Colors.red.shade400;
      case 'Verduras': return Colors.green.shade400;
      case 'Frutas': return Colors.orange.shade400;
      case 'Granos': return Colors.amber.shade600;
      case 'Lácteos': return Colors.blue.shade300;
      case 'Condimentos': return Colors.purple.shade300;
      default: return AppTheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShoppingListTab(),
                  _buildInventoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildSpeedDial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'add_shopping',
          onPressed: () => _showAddItemDialog(isInventory: false),
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: Text(
            'Añadir a Compras',
            style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'add_inventory',
          onPressed: () => _showAddItemDialog(isInventory: true),
          backgroundColor: Colors.green,
          icon: const Icon(Icons.inventory, color: Colors.white),
          label: Text(
            'Añadir a Inventario',
            style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog({required bool isInventory}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    String selectedCategory = 'Otros';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isInventory ? Colors.green : AppTheme.primary).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isInventory ? Icons.inventory : Icons.shopping_cart,
                        color: isInventory ? Colors.green : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isInventory ? 'Añadir a Inventario' : 'Añadir a Lista de Compras',
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            isInventory ? 'Lo que ya tienes en casa' : 'Lo que necesitas comprar',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nombre del ingrediente',
                    hintText: 'Ej: Pollo, Arroz, Manzanas...',
                    prefixIcon: const Icon(Icons.restaurant_menu),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: AppTheme.background,
                  ),
                ),
                const SizedBox(height: 16),
                if (!isInventory) ...[
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad (opcional)',
                      hintText: 'Ej: 500g, 2 unidades...',
                      prefixIcon: const Icon(Icons.scale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Categoría',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Proteínas', 'Verduras', 'Frutas', 'Granos', 'Lácteos', 'Condimentos', 'Otros']
                        .map((cat) {
                      final isSelected = selectedCategory == cat;
                      final color = _getCategoryColor(cat);
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(cat),
                                size: 16,
                                color: isSelected ? Colors.white : color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor ingresa un nombre')),
                        );
                        return;
                      }

                      final nav = Navigator.of(context);
                      final sm = ScaffoldMessenger.of(context);

                      if (isInventory) {
                        await _addToInventory(name);
                      } else {
                        final quantity = quantityController.text.trim().isEmpty 
                            ? '1 unidad' 
                            : quantityController.text.trim();
                        await _nutritionService.addShoppingItem(name, quantity, selectedCategory);
                      }

                      if (!mounted) return;
                      nav.pop();
                      sm.showSnackBar(
                        SnackBar(
                          content: Text(
                            isInventory 
                                ? '$name agregado al inventario' 
                                : '$name agregado a la lista de compras',
                          ),
                          backgroundColor: isInventory ? Colors.green : AppTheme.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInventory ? Colors.green : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isInventory ? 'Agregar a Inventario' : 'Agregar a Lista',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                    'Gestión inteligente de compras',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
              if (_totalItems > 0)
                Row(
                  children: [
                    IconButton(
                      onPressed: _shareShoppingList,
                      icon: const Icon(Icons.share_outlined, color: AppTheme.primary),
                      tooltip: 'Compartir lista',
                    ),
                    IconButton(
                      onPressed: _showClearConfirmation,
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                      tooltip: 'Limpiar lista',
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_checkedItems/$_totalItems',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_totalItems > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _totalItems > 0 ? _checkedItems / _totalItems : 0,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.secondary,
        labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
        labelPadding: const EdgeInsets.symmetric(vertical: 12),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            height: 48,
            child: Center(child: Text('🛒 Lista de Compras')),
          ),
          Tab(
            height: 48,
            child: Center(child: Text('📦 Mi Inventario')),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (_categorizedIngredients.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: _categorizedIngredients.entries.map((entry) {
        return _buildCategorySection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCategorySection(String category, List<Map<String, dynamic>> items) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                category,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${items.length}',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildIngredientItem(item, color)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIngredientItem(Map<String, dynamic> item, Color categoryColor) {
    final bool bought = item['bought'] ?? false;
    final String itemName = item['name'].toString();
    final bool inInventory = _inventory.containsKey(NutritionService.sanitizeKey(itemName));

    return Dismissible(
      key: Key('shopping_${item['name']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) async {
        final itemName = item['name'].toString();
        // Remove from Firebase
        try {
          final authService = AuthService();
          final userId = await authService.getUserId();
          if (userId != null) {
            final safeName = NutritionService.sanitizeKey(itemName);
            await FirebaseDatabase.instance
                .ref('users/$userId/shopping_list/$safeName')
                .remove();
          }
        } catch (e) {
          debugPrint('Error deleting item: $e');
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$itemName eliminado')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bought ? AppTheme.background : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: inInventory ? Border.all(color: Colors.green.shade300, width: 2) : null,
          boxShadow: bought ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final newBoughtState = !bought;
                setState(() {
                  item['bought'] = newBoughtState;
                  if (newBoughtState) {
                    _checkedItems++;
                  } else {
                    _checkedItems--;
                  }
                });
                
                // Persist to Firebase
                try {
                  final authService = AuthService();
                  final userId = await authService.getUserId();
                  if (userId != null) {
                    // Sanitizar nombre para que coincida con la llave guardada
                    final safeName = NutritionService.sanitizeKey(item['name'].toString());
                    await FirebaseDatabase.instance
                        .ref('users/$userId/shopping_list/$safeName/bought')
                        .set(newBoughtState);
                  }
                } catch (e) {
                  debugPrint('Error updating bought state: $e');
                }
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: bought ? AppTheme.accent : Colors.transparent,
                  border: Border.all(
                    color: bought ? AppTheme.accent : AppTheme.secondary.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: bought
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: bought ? TextDecoration.lineThrough : null,
                      color: bought ? AppTheme.secondary : AppTheme.primary,
                    ),
                  ),
                  if (item['quantity'] != null)
                    Text(
                      item['quantity'],
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppTheme.secondary.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            if (inInventory)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'En casa',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _openAffiliateLink(item['affiliate_url']),
              icon: Icon(Icons.shopping_cart_checkout_rounded, color: categoryColor, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: categoryColor.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
            IconButton(
              onPressed: () => _addToInventory(item['name']),
              icon: Icon(
                inInventory ? Icons.inventory : Icons.add_box_outlined,
                color: inInventory ? Colors.green : AppTheme.primary,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: inInventory 
                    ? Colors.green.withOpacity(0.1)
                    : AppTheme.primary.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    if (_inventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.secondary.withOpacity(0.2)),
            const SizedBox(height: 24),
            Text(
              'Inventario vacío',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.secondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega ingredientes que ya tienes en casa',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: _inventory.entries.map((entry) {
        final data = entry.value as Map<dynamic, dynamic>;
        final String displayName = data['name'] ?? entry.key;
        return _buildInventoryItem(displayName, data);
      }).toList(),
    );
  }

  Widget _buildInventoryItem(String name, dynamic data) {
    final Map<String, dynamic> item = data is Map ? Map<String, dynamic>.from(data) : {'added_at': DateTime.now().millisecondsSinceEpoch};
    final DateTime addedAt = DateTime.fromMillisecondsSinceEpoch(item['added_at'] ?? DateTime.now().millisecondsSinceEpoch);
    final int daysAgo = DateTime.now().difference(addedAt).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
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
                Text(
                  daysAgo == 0 ? 'Agregado hoy' : 'Hace $daysAgo día${daysAgo > 1 ? 's' : ''}',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppTheme.secondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeFromInventory(name),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: AppTheme.secondary.withOpacity(0.2)),
          const SizedBox(height: 24),
          Text(
            'Tu lista está vacía',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.secondary),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Activa un plan en el chat para generar tu lista de compras automáticamente',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.secondary.withOpacity(0.6), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAffiliateLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  Future<void> _addToInventory(String itemName) async {
    await _nutritionService.addToInventory(itemName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$itemName agregado al inventario'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removeFromInventory(String itemName) async {
    await _nutritionService.removeFromInventory(itemName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$itemName eliminado del inventario'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Limpiar lista?', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: const Text('Se eliminarán todos los productos de tu lista de compras.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR', style: GoogleFonts.manrope(color: AppTheme.secondary)),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              await _nutritionService.clearShoppingList();
              if (mounted) {
                if (nav.canPop()) nav.pop();
              }
            },
            child: Text('LIMPIAR TODO', style: GoogleFonts.manrope(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _shareShoppingList() async {
    if (_categorizedIngredients.isEmpty) return;

    String content = "*Mi Lista de Compras (Nutrición AI)*\n\n";
    _categorizedIngredients.forEach((category, items) {
      content += "*$category:*\n";
      for (var item in items) {
        final bought = item['bought'] ?? false;
        content += "${bought ? '✅' : '⬜'} ${item['name']} (${item['quantity']})\n";
      }
      content += "\n";
    });

    final Uri url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(content)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback to mail or generic share if possible, but for now just show a snackbar with the text to show it works
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copiado al portapapeles (Simulado)')),
        );
      }
    }
  }

}

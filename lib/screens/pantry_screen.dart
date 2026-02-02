import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/nutrition_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

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
  
  // Selection Mode
  bool _isSelectionMode = false;
  final Set<String> _selectedInventory = {};

  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
        'is_recurring': item['is_recurring'] ?? false,
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
      return 'cat_proteins';
    } else if (lower.contains('lechuga') || lower.contains('tomate') || lower.contains('cebolla') || 
               lower.contains('zanahoria') || lower.contains('espinaca') || lower.contains('brócoli')) {
      return 'cat_vegetables';
    } else if (lower.contains('manzana') || lower.contains('plátano') || lower.contains('naranja') || 
               lower.contains('fresa') || lower.contains('uva')) {
      return 'cat_fruits';
    } else if (lower.contains('arroz') || lower.contains('pasta') || lower.contains('pan') || 
               lower.contains('avena') || lower.contains('quinoa')) {
      return 'cat_grains';
    } else if (lower.contains('leche') || lower.contains('yogur') || lower.contains('queso')) {
      return 'cat_dairy';
    } else if (lower.contains('aceite') || lower.contains('sal') || lower.contains('pimienta') || 
               lower.contains('ajo') || lower.contains('especias')) {
      return 'cat_condiments';
    }
    return 'cat_others';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'cat_proteins':
      case 'Proteínas': return Icons.egg_outlined;
      case 'cat_vegetables':
      case 'Verduras': return Icons.eco_outlined;
      case 'cat_fruits':
      case 'Frutas': return Icons.apple_outlined;
      case 'cat_grains':
      case 'Granos': return Icons.grain_outlined;
      case 'cat_dairy':
      case 'Lácteos': return Icons.water_drop_outlined;
      case 'cat_condiments':
      case 'Condimentos': return Icons.local_fire_department_outlined;
      default: return Icons.shopping_basket_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'cat_proteins':
      case 'Proteínas': return Colors.red.shade400;
      case 'cat_vegetables':
      case 'Verduras': return Colors.green.shade400;
      case 'cat_fruits':
      case 'Frutas': return Colors.orange.shade400;
      case 'cat_grains':
      case 'Granos': return Colors.amber.shade600;
      case 'cat_dairy':
      case 'Lácteos': return Colors.blue.shade300;
      case 'cat_condiments':
      case 'Condimentos': return Colors.purple.shade300;
      default: return AppTheme.secondary;
    }
  }

  String _getCategoryName(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'cat_proteins':
      case 'Proteínas': return l10n.catProteins;
      case 'cat_vegetables':
      case 'Verduras': return l10n.catVegetables;
      case 'cat_fruits':
      case 'Frutas': return l10n.catFruits;
      case 'cat_grains':
      case 'Granos': return l10n.catGrains;
      case 'cat_dairy':
      case 'Lácteos': return l10n.catDairy;
      case 'cat_condiments':
      case 'Condimentos': return l10n.catCondiments;
      default: return l10n.catOthers;
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
    final l10n = AppLocalizations.of(context)!;
    
    if (_isSelectionMode && _tabController.index == 1) {
       return FloatingActionButton.extended(
          onPressed: _deleteSelectedInventory,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.delete_sweep, color: Colors.white),
          label: Text(
            'Eliminar (${_selectedInventory.length})',
            style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
    }
    
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
            l10n.addToShopping,
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
            l10n.addToInventory,
            style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog({required bool isInventory}) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    String selectedCategory = 'cat_others';
    bool isRecurring = false;

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
                        color: (isInventory ? Colors.green : AppTheme.primary).withValues(alpha: 0.1),
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
                            isInventory ? l10n.addToInventory : l10n.addToShopping,
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            isInventory ? l10n.pantryInventoryDesc : l10n.pantryShoppingDesc,
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
                    labelText: l10n.ingredientNameLabel,
                    hintText: 'Ej: Pollo, Arroz...',
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
                        labelText: l10n.quantityOptional,
                        hintText: 'Ej: 500g, 2 units...',
                        prefixIcon: const Icon(Icons.scale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: AppTheme.background,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Producto Recurrente',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        'Se mantendrá en tu lista para la próxima vez',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppTheme.secondary,
                        ),
                      ),
                      value: isRecurring,
                      activeTrackColor: AppTheme.primary,
                      onChanged: (val) => setModalState(() => isRecurring = val),
                    ),
                    const SizedBox(height: 16),
                    Text(
                    l10n.categoryLabel,
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
                    children: ['cat_proteins', 'cat_vegetables', 'cat_fruits', 'cat_grains', 'cat_dairy', 'cat_condiments', 'cat_others']
                        .map((catKey) {
                      final isSelected = selectedCategory == catKey;
                      final color = _getCategoryColor(catKey);
                      final catDisplayName = _getCategoryName(context, catKey);
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedCategory = catKey),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withValues(alpha: 0.1),
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
                                _getCategoryIcon(catKey),
                                size: 16,
                                color: isSelected ? Colors.white : color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                catDisplayName,
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
                          SnackBar(content: Text(l10n.enterNameError)),
                        );
                        return;
                      }

                      final nav = Navigator.of(context);
                      final sm = ScaffoldMessenger.of(context);

                      if (isInventory) {
                        await _addToInventory(name);
                      } else {
                        final quantity = quantityController.text.trim().isEmpty 
                            ? '1 ${l10n.itemQuantityUnit}' 
                            : quantityController.text.trim();
                        await _nutritionService.addShoppingItem(
                          name, 
                          quantity, 
                          selectedCategory,
                          isRecurring: isRecurring,
                        );
                      }

                      if (!mounted) return;
                      nav.pop();
                      sm.showSnackBar(
                        SnackBar(
                          content: Text(
                            isInventory 
                                ? '$name ${l10n.addedToInventoryMsg}' 
                                : '$name ${l10n.addedToShoppingMsg}',
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
                      isInventory ? l10n.addToInventory : l10n.addToShopping,
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
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.pantryTitle,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    l10n.pantrySubtitle,
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
                      tooltip: l10n.shareList,
                    ),
                    IconButton(
                      onPressed: _showClearConfirmation,
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                      tooltip: l10n.clearList,
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
    final l10n = AppLocalizations.of(context)!;
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
        tabs: [
          Tab(
            height: 48,
            child: Center(child: Text(l10n.shoppingList)),
          ),
          Tab(
            height: 48,
            child: Center(child: Text(l10n.myInventory)),
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
      return _buildEmptyState(context);
    }

    // Define category order
    final List<String> categoryOrder = [
      'cat_proteins', 
      'cat_vegetables', 
      'cat_fruits', 
      'cat_grains', 
      'cat_dairy', 
      'cat_condiments',
      'cat_others'
    ];
    
    // Helper to process categories
    List<Widget> sections = [];
    
    // 1. Process ordered categories
    for (var category in categoryOrder) {
      if (_categorizedIngredients.containsKey(category)) {
        final rawItems = _categorizedIngredients[category]!;
        // Filter out items already in inventory
        final visibleItems = rawItems.where((item) {
           final safeKey = NutritionService.sanitizeKey(item['name'].toString());
           return !_inventory.containsKey(safeKey);
        }).toList();
        
        if (visibleItems.isNotEmpty) {
          sections.add(_buildCategorySection(context, category, visibleItems));
        }
      }
    }
    
    // 2. Process any remaining categories not in the ordered list (custom ones?)
    _categorizedIngredients.forEach((key, value) {
      if (!categoryOrder.contains(key)) {
        final visibleItems = value.where((item) {
           final safeKey = NutritionService.sanitizeKey(item['name'].toString());
           return !_inventory.containsKey(safeKey);
        }).toList();
        
        if (visibleItems.isNotEmpty) {
          sections.add(_buildCategorySection(context, key, visibleItems));
        }
      }
    });

    if (sections.isEmpty) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          children: sections,
        ),
        
        // Show Finish Shopping button if there are bought items THAT ARE VISIBLE
        // (If we hid them, we shouldn't count them? Wait, checking bought items.)
        // We need to re-calc _checkedItems based on VISIBLE items effectively?
        // Or does _checkedItems track global state? 
        // Logic: You buy items you SEE. 
        if (_checkedItems > 0)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _finishShopping,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                shadowColor: Colors.green.withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Finalizar Compra', // Removed count as it might be confusing if some are hidden
                    style: GoogleFonts.manrope(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _finishShopping() async {
    // Iterate over bought items
    int addedCount = 0;
    
    // Create a flattened list of all items to find bought ones
    final List<Map<String, dynamic>> allItems = [];
    _categorizedIngredients.forEach((_, items) => allItems.addAll(items));
    
    final boughtItems = allItems.where((i) => i['bought'] == true).toList();
    
    if (boughtItems.isEmpty) return;

    // Show confirmation or just do it? User wants convenience. Let's do it and show summary.
    // Logic:
    // 1. Add to inventory
    // 2. If Recurring: Uncheck (bought=false)
    // 3. If Not Recurring: Delete from shopping list

    for (var item in boughtItems) {
      final name = item['name'].toString();
      final isRecurring = item['is_recurring'] == true;
      final safeName = NutritionService.sanitizeKey(name);
      
      // 1. Add to inventory
      await _nutritionService.addToInventory(name);
      
      // 2. Handle List Item
      if (isRecurring) {
        // Reset bought status
        await FirebaseDatabase.instance
            .ref('users/${await AuthService().getUserId()}/shopping_list/$safeName/bought')
            .set(false);
      } else {
        // Delete
        await FirebaseDatabase.instance
            .ref('users/${await AuthService().getUserId()}/shopping_list/$safeName')
            .remove();
      }
      addedCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$addedCount productos movidos al inventario'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildCategorySection(BuildContext context, String category, List<Map<String, dynamic>> items) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(context, category);

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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                categoryName,
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
                  color: color.withValues(alpha: 0.1),
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
    final l10n = AppLocalizations.of(context)!;
    final bool bought = item['bought'] ?? false;
    final bool isRecurring = item['is_recurring'] ?? false;
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
          SnackBar(content: Text('$itemName ${l10n.itemDeleted}')),
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
              color: Colors.black.withValues(alpha: 0.03),
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
                    color: bought ? AppTheme.accent : AppTheme.secondary.withValues(alpha: 0.3),
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
                        color: AppTheme.secondary.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            if (isRecurring)
               Padding(
                 padding: const EdgeInsets.only(right: 8),
                 child: Icon(Icons.repeat, color: AppTheme.primary.withValues(alpha: 0.5), size: 16),
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
                      l10n.atHome,
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
                backgroundColor: categoryColor.withValues(alpha: 0.1),
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
                    ? Colors.green.withValues(alpha: 0.1)
                    : AppTheme.primary.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    final l10n = AppLocalizations.of(context)!;
    if (_inventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: AppTheme.secondary.withValues(alpha: 0.2)),
            const SizedBox(height: 24),
            Text(
              l10n.emptyInventory,
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.secondary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pantryInventoryEmptyDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isSelectionMode)
          Container(
             color: Colors.red.withValues(alpha: 0.1),
             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   '${_selectedInventory.length} seleccionados',
                   style: GoogleFonts.manrope(
                     fontWeight: FontWeight.bold,
                     color: Colors.red,
                   ),
                 ),
                 TextButton(
                   onPressed: () {
                     setState(() {
                       _isSelectionMode = false;
                       _selectedInventory.clear();
                     });
                   },
                   child: Text('Cancelar', style: GoogleFonts.manrope(color: Colors.red)),
                 ),
               ],
             ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _isSelectionMode = true),
                  icon: const Icon(Icons.checklist, size: 20),
                  label: Text(
                    'Seleccionar para borrar',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondary,
                    backgroundColor: AppTheme.secondary.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            children: _inventory.entries.map((entry) {
              final data = entry.value as Map<dynamic, dynamic>;
              final String displayName = data['name'] ?? entry.key;
              final String safeKey = NutritionService.sanitizeKey(displayName);
              return _buildInventoryItem(displayName, data, safeKey);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryItem(String name, dynamic data, String key) {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, dynamic> item = data is Map ? Map<String, dynamic>.from(data) : {'added_at': DateTime.now().millisecondsSinceEpoch};
    final DateTime addedAt = DateTime.fromMillisecondsSinceEpoch(item['added_at'] ?? DateTime.now().millisecondsSinceEpoch);
    final int daysAgo = DateTime.now().difference(addedAt).inDays;
    
    final bool isSelected = _selectedInventory.contains(key);

    return InkWell(
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _selectedInventory.add(key);
        });
      },
      onTap: _isSelectionMode ? () {
        setState(() {
          if (isSelected) {
            _selectedInventory.remove(key);
            if (_selectedInventory.isEmpty) _isSelectionMode = false;
          } else {
            _selectedInventory.add(key);
          }
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.red) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            if (_isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? Colors.red : Colors.grey,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              ),
            if (!_isSelectionMode) const SizedBox(width: 12),
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
                    daysAgo == 0 ? l10n.addedToday : l10n.daysAgo(daysAgo),
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppTheme.secondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (!_isSelectionMode)
              IconButton(
                onPressed: () => _removeFromInventory(name),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _deleteSelectedInventory() async {
     final int count = _selectedInventory.length;
     
     // Confirm?
     for (var key in _selectedInventory) {
       // We only have the key (sanitized name), or we might need the original name.
       // NutritionService uses sanitizeKey(name) to store.
       // Wait, removeFromInventory takes 'itemName' and sanitizes it again.
       // Store logic assumes key IS the sanitized name.
       // Let's call a method that deletes by key?
       // NutritionService currently has: delete by name -> sanitizes name -> remove.
       // If I have the sanitized key, I can't easily get the unsanitized name unless I store it.
       // But wait, the key IS the sanitized name.
       // So if I pass the key to something that expects a name to sanitize...
       // If name 'A B', key 'A_B'.
       // sanitize('A_B') -> 'A_B'.
       // So passing the key as the name usually works IF sanitize is idempotent and simple (which it is, replaces speical chars).
       await FirebaseDatabase.instance
            .ref('users/${await AuthService().getUserId()}/inventory/$key')
            .remove();
     }

     setState(() {
       _selectedInventory.clear();
       _isSelectionMode = false;
     });

     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count productos eliminados'),
          backgroundColor: Colors.red,
        ),
      );
     }
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: AppTheme.secondary.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          Text(
            l10n.emptyShoppingList,
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.secondary),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.pantryEmptyDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.secondary.withValues(alpha: 0.6), height: 1.5),
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
    final l10n = AppLocalizations.of(context)!;
    await _nutritionService.addToInventory(itemName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$itemName ${l10n.addedToInventoryMsg}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removeFromInventory(String itemName) async {
    final l10n = AppLocalizations.of(context)!;
    await _nutritionService.removeFromInventory(itemName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$itemName ${l10n.itemDeleted}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showClearConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearList, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Text(l10n.clearListConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelLabel, style: GoogleFonts.manrope(color: AppTheme.secondary)),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              await _nutritionService.clearShoppingList();
              if (mounted) {
                if (nav.canPop()) nav.pop();
              }
            },
            child: Text(l10n.clearAllLabel, style: GoogleFonts.manrope(color: Colors.red, fontWeight: FontWeight.bold)),
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

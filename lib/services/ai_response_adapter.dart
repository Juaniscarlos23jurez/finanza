
class AiResponseAdapter {
  /// Adapts a single transaction map into a consistent NormalizedTransaction
  static NormalizedTransaction adaptTransaction(Map<String, dynamic> raw) {
    return NormalizedTransaction.fromMap(raw);
  }

  /// Adapts a list of transactions
  static List<NormalizedTransaction> adaptMultiTransaction(List<dynamic> rawList) {
    return rawList
        .whereType<Map<String, dynamic>>() // Filter only valid maps
        .map((data) => NormalizedTransaction.fromMap(data))
        .toList();
  }
  static NormalizedGoal adaptGoal(Map<String, dynamic> raw) {
    return NormalizedGoal.fromMap(raw);
  }

  static NormalizedBalance adaptBalance(Map<String, dynamic> raw) {
    return NormalizedBalance.fromMap(raw);
  }

  // --- Shared Helpers ---

  static String _safeString(Map data, List<String> keys, {String defaultVal = ''}) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        return data[key].toString();
      }
    }
    return defaultVal;
  }

  static double _safeDouble(Map data, List<String> keys, {double defaultVal = 0.0}) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final val = data[key];
        if (val is num) return val.toDouble();
        if (val is String) {
          // Remove currency symbols and cleaner parse
          String clean = val.replaceAll(RegExp(r'[^\d.-]'), ''); 
          return double.tryParse(clean) ?? defaultVal;
        }
      }
    }
    return defaultVal;
  }
}

class NormalizedTransaction {
  final double amount;
  final String category;
  final String description;
  final String date; // ISO 8601 YYYY-MM-DD
  final bool isExpense;

  NormalizedTransaction({
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.isExpense,
  });

  factory NormalizedTransaction.fromMap(Map<String, dynamic> map) {
    // 1. Smart Type Inference
    final bool isExpense = _parseTransactionType(map);

    // 2. Safe Field Extraction
    final double amount = AiResponseAdapter._safeDouble(map, ['amount', 'cost', 'price', 'value', 'monto']);
    final String category = AiResponseAdapter._safeString(map, ['category', 'cat', 'categoria'], defaultVal: 'General');
    final String description = AiResponseAdapter._safeString(map, ['description', 'desc', 'concept', 'concepto'], defaultVal: 'Transacción AI');
    final String date = AiResponseAdapter._safeString(map, ['date', 'time', 'fecha'], defaultVal: DateTime.now().toIso8601String().split('T')[0]);

    return NormalizedTransaction(
      amount: amount,
      category: category,
      description: description,
      date: date,
      isExpense: isExpense,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'type': isExpense ? 'expense' : 'income',
      'date': date,
      'description': description,
    };
  }

  // --- Helpers ---

  static bool _parseTransactionType(Map<String, dynamic> map) {
    // Check explicit keys first
    if (map.containsKey('is_expense')) {
      final val = map['is_expense'];
      if (val is bool) return val;
      if (val is String) {
        if (val.toLowerCase() == 'true') return true;
        if (val.toLowerCase() == 'false') return false;
      }
    }

    // Check synonym keys for "type"
    final typeVal = AiResponseAdapter._safeString(map, ['type', 'tipo']).toLowerCase();
    if (['expense', 'gasto', 'deuda', 'payment', 'pago', 'cost'].contains(typeVal)) {
      return true;
    }
    if (['income', 'ingreso', 'gain', 'deposit', 'deposito', 'ahorro'].contains(typeVal)) {
      return false; // It's an income
    }

    // Inference by Amount (if type is missing or ambiguous)
    // If amount is negative, usually explicitly stated as such, it might be an expense or just signed.
    // If user prompt says "Gaste -500", AI might output amount: -500.
    // Let's check if amount is explicitly negative in the raw data
    if (map.containsKey('amount') || map.containsKey('cost') || map.containsKey('price')) {
       // Inference by value logic (optional)
    }

    // Inference by Description
    final desc = AiResponseAdapter._safeString(map, ['description', 'desc', 'concept']).toLowerCase();
    if (desc.contains('gane') || desc.contains('recibi') || desc.contains('deposito') || desc.contains('cobro')) {
       return false; // Income
    }

    // Default to true (Expense)
    return true; 
  }
}

class NormalizedGoal {
  final String title;
  final double targetAmount;
  final String description;
  final String targetDate;

  NormalizedGoal({
    required this.title,
    required this.targetAmount,
    required this.description,
    required this.targetDate,
  });

  factory NormalizedGoal.fromMap(Map<String, dynamic> map) {
    return NormalizedGoal(
      title: AiResponseAdapter._safeString(map, ['title', 'name', 'titulo'], defaultVal: 'Meta'),
      targetAmount: AiResponseAdapter._safeDouble(map, ['target_amount', 'amount', 'goal', 'monto']),
      description: AiResponseAdapter._safeString(map, ['reason', 'description', 'desc', 'motivo'], defaultVal: 'Ahorro sugerido por IA'),
      targetDate: AiResponseAdapter._safeString(map, ['target_date', 'date'], defaultVal: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'target_amount': targetAmount,
      'description': description,
      'target_date': targetDate,
      'current_amount': 0.0,
      'status': 'active',
    };
  }
}

class NormalizedBalance {
  final double total;
  final double income;
  final double expenses;

  NormalizedBalance({
    required this.total,
    required this.income,
    required this.expenses,
  });

  factory NormalizedBalance.fromMap(Map<String, dynamic> map) {
    return NormalizedBalance(
      total: AiResponseAdapter._safeDouble(map, ['total', 'balance', 'saldo']),
      income: AiResponseAdapter._safeDouble(map, ['income', 'ingresos', 'ganancias']),
      expenses: AiResponseAdapter._safeDouble(map, ['expenses', 'gastos', 'salidas']),
    );
  }
}

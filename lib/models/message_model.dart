class Message {
  final String text;
  final bool isAi;
  final DateTime timestamp;
  final bool isGenUI;
  final Map<String, dynamic>? data;

  final String? key; // Firebase key
  final bool isHandled; // If GenUI action was completed

  Message({
    this.key,
    required this.text,
    required this.isAi,
    required this.timestamp,
    this.isGenUI = false,
    this.isHandled = false,
    this.data,
  });
}

class Message {
  final String? id;
  final String text;
  final bool isAi;
  final DateTime timestamp;
  final bool isGenUI;
  final Map<String, dynamic>? data;

  Message({
    this.id,
    required this.text,
    required this.isAi,
    required this.timestamp,
    this.isGenUI = false,
    this.data,
  });
}

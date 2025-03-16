// إدارة الديون class
class Debt {
  final String description;
  final double amount;
  final DateTime dueDate;
  final DateTime receiptDate;
  final DateTime? lastEditTime; // وقت آخر تعديل

  Debt({
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.receiptDate,
    this.lastEditTime,
  });

  // Convert a Debt into a Map
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'receiptDate': receiptDate.toIso8601String(),
      'lastEditTime': lastEditTime?.toIso8601String(),
    };
  }

  // Extract a Debt from a Map
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      description: map['description'],
      amount: map['amount'],
      dueDate: DateTime.parse(map['dueDate']),
      receiptDate: DateTime.parse(map['receiptDate']),
      lastEditTime: map['lastEditTime'] != null 
          ? DateTime.parse(map['lastEditTime'])
          : null,
    );
  }
}

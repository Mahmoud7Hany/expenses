// إدارة الديون class
class Debt {
  String description;
  double amount;
  DateTime dueDate;
  DateTime receiptDate;

  Debt({
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.receiptDate,
  });

  // Convert a Debt into a Map
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'receiptDate': receiptDate.toIso8601String(),
    };
  }

  // Extract a Debt from a Map
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      description: map['description'],
      amount: map['amount'],
      dueDate: DateTime.parse(map['dueDate']),
      receiptDate: DateTime.parse(map['receiptDate']),
    );
  }
}

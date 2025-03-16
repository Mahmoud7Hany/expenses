class Expense {
  final String name;
  final double amount;
  final DateTime dateTime;

  Expense({
    required this.name,
    required this.amount,
    required this.dateTime,
  });

  // تحويل Expense إلى Map لحفظه في JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  // إنشاء Expense من Map (JSON)
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dateTime: json['dateTime'] != null 
          ? DateTime.parse(json['dateTime'] as String)
          : DateTime.now(),
    );
  }
}

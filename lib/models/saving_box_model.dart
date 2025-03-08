class SavingBoxTransaction {
  final double amount;
  final DateTime date;
  final bool isDeposit;
  final String note;

  SavingBoxTransaction({
    required this.amount,
    required this.date,
    required this.isDeposit,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'isDeposit': isDeposit,
      'note': note,
    };
  }

  factory SavingBoxTransaction.fromMap(Map<String, dynamic> map) {
    return SavingBoxTransaction(
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isDeposit: map['isDeposit'],
      note: map['note'],
    );
  }
}

class SavingBox {
  final String id;
  final String name;
  final double targetAmount;
  final double initialBalance;
  double currentBalance;
  List<SavingBoxTransaction> transactions;

  SavingBox({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.initialBalance,
    required this.currentBalance,
    List<SavingBoxTransaction>? transactions,
  }) : this.transactions = transactions ?? [];

  double get totalDeposits => transactions
      .where((t) => t.isDeposit)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalWithdraws => transactions
      .where((t) => !t.isDeposit)
      .fold(0.0, (sum, t) => sum + t.amount);

  // تحديث طريقة حساب المبلغ المدخر ليشمل الرصيد الافتتاحي
  double get savedAmount => initialBalance + totalDeposits - totalWithdraws;

  double get remainingAmount => targetAmount - currentBalance;
  double get progressPercentage => (currentBalance / targetAmount * 100).clamp(0, 100);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'initialBalance': initialBalance,
      'currentBalance': currentBalance,
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }

  factory SavingBox.fromMap(Map<String, dynamic> map) {
    return SavingBox(
      id: map['id'],
      name: map['name'],
      targetAmount: map['targetAmount'],
      initialBalance: map['initialBalance'],
      currentBalance: map['currentBalance'],
      transactions: (map['transactions'] as List)
          .map((t) => SavingBoxTransaction.fromMap(t))
          .toList(),
    );
  }
}

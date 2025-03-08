// خاص ب اضافه حاجه اتصرفت جديده
// بيتم اضافه الاسم والسعر الخاص بالحاجه اللي اتصرفت
class Expense {
  final String name;
  final double amount;

  Expense(this.name, this.amount);

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
      };
}

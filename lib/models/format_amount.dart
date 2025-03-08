// ignore_for_file: unnecessary_null_comparison

// الكود ده خاص بعدم عرض القيمه العشريه لو مش موجوده لو موجوده بيتم عرضه
String formatAmount(double amount) {
  if (amount != null) {
    if (amount % 1 == 0) {
      // القيمة لا تحتوي على أرقام عشرية
      return '${amount.toInt()} جنيه';
    } else {
      // القيمة تحتوي على أرقام عشرية
      return '${amount.toStringAsFixed(2)} جنيه';
    }
  } else {
    // قيمة الإنفاق فارغة
    return '';
  }
}

class SadaqahModel {
  final double totalAmount;
  final double percentage;
  final double sadaqahAmount;
  final DateTime date;
  final String note;

  SadaqahModel({
    required this.totalAmount,
    required this.percentage,
    required this.sadaqahAmount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'totalAmount': totalAmount,
      'percentage': percentage,
      'sadaqahAmount': sadaqahAmount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory SadaqahModel.fromMap(Map<String, dynamic> map) {
    return SadaqahModel(
      totalAmount: map['totalAmount'],
      percentage: map['percentage'],
      sadaqahAmount: map['sadaqahAmount'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}

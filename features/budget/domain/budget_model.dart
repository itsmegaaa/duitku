class BudgetModel {
  final String id;
  final String profileId;
  final String categoryId;
  final double amountLimit;
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    required this.profileId,
    required this.categoryId,
    required this.amountLimit,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'categoryId': categoryId,
      'amountLimit': amountLimit,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      profileId: map['profileId'] as String,
      categoryId: map['categoryId'] as String,
      amountLimit: (map['amountLimit'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }
}

class TransactionModel {
  final String id;
  final String profileId;
  final String categoryId;
  final double amount;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String note;
  final String? receiptUrl;
  final bool isRecurring;
  final DateTime createdAt;
  final int syncStatus; // 0 = local, 1 = synced

  TransactionModel({
    required this.id,
    required this.profileId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    required this.note,
    this.receiptUrl,
    required this.isRecurring,
    required this.createdAt,
    required this.syncStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'categoryId': categoryId,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
      'receiptUrl': receiptUrl,
      'isRecurring': isRecurring ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      profileId: map['profileId'] as String,
      categoryId: map['categoryId'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String,
      receiptUrl: map['receiptUrl'] as String?,
      isRecurring: (map['isRecurring'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      syncStatus: map['syncStatus'] as int,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? profileId,
    String? categoryId,
    double? amount,
    String? type,
    DateTime? date,
    String? note,
    String? receiptUrl,
    bool? isRecurring,
    DateTime? createdAt,
    int? syncStatus,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

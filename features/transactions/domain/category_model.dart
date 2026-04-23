class CategoryModel {
  final String id;
  final String profileId;
  final String name;
  final String icon; // string emoji like "🍔"
  final int colorValue;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.isDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'name': name,
      'icon': icon,
      'colorValue': colorValue,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      profileId: map['profileId'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colorValue: map['colorValue'] as int,
      isDefault: (map['isDefault'] as int) == 1,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? profileId,
    String? name,
    String? icon,
    int? colorValue,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

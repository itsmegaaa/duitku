class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String currency;
  final String avatarType; // "emoji", "image", "initials"
  final String avatarValue; 
  final double balance;
  final bool isCloudSynced;
  final String? pinHash;

  ProfileModel({
    required this.id,
    required this.name,
    this.email = '',
    this.currency = 'IDR',
    this.avatarType = 'initials',
    this.avatarValue = '',
    this.balance = 0.0,
    this.isCloudSynced = false,
    this.pinHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currency': currency,
      'avatarType': avatarType,
      'avatarValue': avatarValue,
      'balance': balance,
      'isCloudSynced': isCloudSynced ? 1 : 0,
      'pinHash': pinHash,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: (map['email'] as String?) ?? '',
      currency: (map['currency'] as String?) ?? 'IDR',
      avatarType: (map['avatarType'] as String?) ?? 'initials',
      avatarValue: (map['avatarValue'] as String?) ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      isCloudSynced: ((map['isCloudSynced'] as int?) ?? 0) == 1,
      pinHash: map['pinHash'] as String?,
    );
  }
}

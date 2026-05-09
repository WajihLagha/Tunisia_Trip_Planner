class UserModel {
  final String? id;
  final String? userName;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? ageGroup;
  final List<String>? travelStyles;
  final String? groupSize;
  final String? budget;
  final String? transportType;
  final String? accommodationType;
  final bool? active;

  UserModel({
    this.id,
    this.userName,
    this.email,
    this.phoneNumber,
    this.address,
    this.ageGroup,
    this.travelStyles,
    this.groupSize,
    this.budget,
    this.transportType,
    this.accommodationType,
    this.active,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      ageGroup: json['ageGroup'] as String?,
      travelStyles: (json['travelStyles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      groupSize: json['groupSize'] as String?,
      budget: json['budget'] as String?,
      transportType: json['transportType'] as String?,
      accommodationType: json['accommodationType'] as String?,
      active: json['active'] as bool?,
    );
  }
}

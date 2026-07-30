class User {
  final String id;
  final String username;
  final String email;
  final List<String> roles;
  final String? organizationId;
  final String? organizationName;
  final String? companyId;
  final String? companyName;
  final List<String> effectivePermissions;
  final String? profilePhotoId;
  final String? companyLogoId;
  final String? primaryColor;
  final String? secondaryColor;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
    this.organizationId,
    this.organizationName,
    this.companyId,
    this.companyName,
    required this.effectivePermissions,
    this.profilePhotoId,
    this.companyLogoId,
    this.primaryColor,
    this.secondaryColor,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      organizationId: json['organizationId'],
      organizationName: json['organizationName'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      effectivePermissions: List<String>.from(json['effectivePermissions'] ?? []),
      profilePhotoId: json['profilePhotoId'],
      companyLogoId: json['companyLogoId'],
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'roles': roles,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'companyId': companyId,
      'companyName': companyName,
      'effectivePermissions': effectivePermissions,
      'profilePhotoId': profilePhotoId,
      'companyLogoId': companyLogoId,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    List<String>? roles,
    String? organizationId,
    String? organizationName,
    String? companyId,
    String? companyName,
    List<String>? effectivePermissions,
    String? profilePhotoId,
    String? companyLogoId,
    String? primaryColor,
    String? secondaryColor,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      effectivePermissions: effectivePermissions ?? this.effectivePermissions,
      profilePhotoId: profilePhotoId ?? this.profilePhotoId,
      companyLogoId: companyLogoId ?? this.companyLogoId,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }

  // Helper method for roles
  bool hasRole(String role) => roles.contains(role);
  
  // Helper method for permissions
  bool hasPermission(String permission) => effectivePermissions.contains(permission);
}

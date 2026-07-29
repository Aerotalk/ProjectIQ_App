class PermissionManager {
  final Set<String> _permissions = {};

  void setPermissions(List<String> permissions) {
    _permissions.clear();
    _permissions.addAll(permissions);
  }

  void clearPermissions() {
    _permissions.clear();
  }

  bool hasPermission(String permission) {
    return _permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((p) => _permissions.contains(p));
  }

  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((p) => _permissions.contains(p));
  }
}

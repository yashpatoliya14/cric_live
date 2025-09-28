/// Enum defining different user roles in a tournament
enum UserRole {
  /// Tournament host/creator - has full access to all tournament features
  host,
  
  /// Tournament scorer - can create, edit, and manage matches
  scorer,
  
  /// Regular viewer - can only view tournament and match details
  viewer,
}

/// Extension methods for UserRole enum
extension UserRoleExtension on UserRole {
  /// Get display text for the role
  String get displayText {
    switch (this) {
      case UserRole.host:
        return "Tournament Admin";
      case UserRole.scorer:
        return "Scorer Access";
      case UserRole.viewer:
        return "Spectator";
    }
  }

  /// Check if role has admin privileges
  bool get hasAdminAccess {
    return this == UserRole.host || this == UserRole.scorer;
  }

  /// Check if role can create matches
  bool get canCreateMatches {
    return hasAdminAccess;
  }

  /// Check if role can edit matches
  bool get canEditMatches {
    return hasAdminAccess;
  }

  /// Check if role can delete matches
  bool get canDeleteMatches {
    return hasAdminAccess;
  }

  /// Check if role can control match state (start/stop)
  bool get canControlMatches {
    return hasAdminAccess;
  }

  /// Get role priority (higher number = more privileges)
  int get priority {
    switch (this) {
      case UserRole.host:
        return 3;
      case UserRole.scorer:
        return 2;
      case UserRole.viewer:
        return 1;
    }
  }
}
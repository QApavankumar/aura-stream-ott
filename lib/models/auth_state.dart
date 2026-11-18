enum AuthStatus {
  unauthenticated,
  otpSent,
  authenticated,
}

class AuthUser {
  final String id;
  final String identifier; // phone or email
  final bool isPhone;

  const AuthUser({
    required this.id,
    required this.identifier,
    this.isPhone = true,
  });
}

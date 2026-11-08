/// Holds transient sign-up state that is passed between auth screens.
/// This is a simple in-memory store — not persisted.
class SignUpSession {
  SignUpSession._();

  static String? username;
  static String? password;
  static String? email;
  static String? phone;

  static void reset() {
    username = null;
    password = null;
    email = null;
    phone = null;
  }
}

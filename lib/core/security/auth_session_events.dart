import 'dart:async';

enum AuthSessionEventType {
  sessionExpired,
}

class AuthSessionEvent {
  final AuthSessionEventType type;

  const AuthSessionEvent(this.type);
}

class AuthSessionEvents {
  AuthSessionEvents._();

  static final AuthSessionEvents instance = AuthSessionEvents._();

  final StreamController<AuthSessionEvent> _controller = StreamController<AuthSessionEvent>.broadcast();

  Stream<AuthSessionEvent> get stream => _controller.stream;

  void notifySessionExpired() {
    if (!_controller.isClosed) {
      _controller.add(const AuthSessionEvent(AuthSessionEventType.sessionExpired));
    }
  }
}

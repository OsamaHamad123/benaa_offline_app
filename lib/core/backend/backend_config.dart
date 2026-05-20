enum BackendFlavor {
  firebase,
  supabase,
}

class BackendConfig {
  const BackendConfig({
    required this.flavor,
  });

  final BackendFlavor flavor;

  static const String _flavorFromEnv = String.fromEnvironment(
    'BACKEND_FLAVOR',
    defaultValue: 'firebase',
  );

  static const BackendConfig current = BackendConfig(
    flavor: _flavorFromEnv == 'supabase' ? BackendFlavor.supabase : BackendFlavor.firebase,
  );
}

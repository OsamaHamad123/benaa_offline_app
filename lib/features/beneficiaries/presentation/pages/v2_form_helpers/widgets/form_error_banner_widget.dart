import 'package:benaa_offline_app/features/beneficiaries/presentation/widgets/v2/v2_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/beneficiary_form_provider.dart';

/// 🚨 Error Banner Widget (Separated for performance)
///
/// Only rebuilds when error message changes
class FormErrorBanner extends ConsumerWidget {
  const FormErrorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = ref.watch(
      beneficiaryFormProvider.select((s) => s.errorMessage),
    );

    if (errorMessage == null) {
      return const SizedBox.shrink();
    }

    return V2ErrorBanner(
      message: errorMessage,
      onDismiss: () => ref.read(beneficiaryFormProvider.notifier).clearError(),
    );
  }
}

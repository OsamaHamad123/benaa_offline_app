class FormTaxonomySyncHelper {
  static const String successMessage = 'تمت مزامنة التصنيفات بنجاح.';
  static const String genericFailureMessage = 'فشلت مزامنة التصنيفات.';
  static const String exceptionFailureMessage = 'تعذر مزامنة التصنيفات حالياً.';

  static String resolveFailureMessage(String? rawError) {
    final trimmed = rawError?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return genericFailureMessage;
    }
    return trimmed;
  }
}

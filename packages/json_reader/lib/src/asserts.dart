bool hasSingleNonNullValue(List<Object?> values) {
  final nonNullCount = values.where((v) => v != null).length;
  return nonNullCount == 1;
}

bool hasSingleNonEmptyString(List<String?> values) {
  final nonEmptyCount = values.where((v) => v?.isNotEmpty == true).length;
  return nonEmptyCount == 1;
}

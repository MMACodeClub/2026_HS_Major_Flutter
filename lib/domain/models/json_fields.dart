String requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Ungültiges oder fehlendes Feld: $key');
  }
  return value;
}

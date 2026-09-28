import 'app_exception.dart';

const maxRoomTitleLength = 80;
const maxMessageLength = 2000;

String? validateRoomTitle(String? value) =>
    _validate(value, maxRoomTitleLength, 'Raumname');
String? validateMessage(String? value) =>
    _validate(value, maxMessageLength, 'Nachricht');

String? _validate(String? value, int maxLength, String label) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '$label darf nicht leer sein.';
  if (text.length > maxLength) {
    return '$label darf höchstens $maxLength Zeichen enthalten.';
  }
  return null;
}

String requireRoomTitle(String value) {
  final error = validateRoomTitle(value);
  if (error != null) throw AppException(error);
  return value.trim();
}

String requireMessage(String value) {
  final error = validateMessage(value);
  if (error != null) throw AppException(error);
  return value.trim();
}

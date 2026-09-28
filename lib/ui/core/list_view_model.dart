import 'package:flutter/foundation.dart';
import '../../domain/app_exception.dart';

/// One operation at a time; preserve existing data if refreshing fails.
abstract class ListViewModel<T> extends ChangeNotifier {
  List<T> _items = [];
  bool _loading = false;
  bool _saving = false;
  bool _disposed = false;
  String? _error;

  List<T> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  bool get isBusy => _loading || _saving;
  String? get error => _error;

  @protected
  Future<List<T>> fetchItems();

  Future<void> load() async {
    if (_disposed || isBusy) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await fetchItems();
      if (!_disposed) _items = data;
    } catch (error) {
      if (!_disposed) _error = errorMessage(error);
    } finally {
      if (!_disposed) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  /// True means the write succeeded, even if the subsequent refresh failed.
  /// This prevents a user from retrying a successful POST and creating duplicates.
  @protected
  Future<bool> mutate(Future<void> Function() action) async {
    if (_disposed || isBusy) return false;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      if (_disposed) return true;
      try {
        final data = await fetchItems();
        if (!_disposed) _items = data;
      } catch (_) {
        if (!_disposed) {
          _error =
              'Gespeichert. Die Ansicht konnte nicht aktualisiert werden. Bitte neu laden.';
        }
      }
      return true;
    } catch (error) {
      if (!_disposed) _error = errorMessage(error);
      return false;
    } finally {
      if (!_disposed) {
        _saving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

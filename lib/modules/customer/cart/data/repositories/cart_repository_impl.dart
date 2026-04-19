import '../../../../../core/storage/local_storage.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';

/// Cart backed by [Hive] via [LocalStorage] (survives restarts; marked dirty for remote sync).
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._local);

  final LocalStorage _local;

  List<CartLine> _lines = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _lines = List.from(await _local.loadCart());
    _loaded = true;
  }

  Future<void> _persist() async {
    await _local.saveCart(_lines);
  }

  @override
  Future<List<CartLine>> getLines() async {
    await _ensureLoaded();
    return List.unmodifiable(_lines);
  }

  @override
  Future<void> addOrUpdateLine(CartLine line) async {
    await _ensureLoaded();
    final i = _lines.indexWhere(
      (l) => l.productId == line.productId && l.variantId == line.variantId,
    );
    if (i >= 0) {
      final merged = _lines[i].copyWith(
        quantity: _lines[i].quantity + line.quantity,
        imageUrl: line.imageUrl ?? _lines[i].imageUrl,
        lineTag: line.lineTag ?? _lines[i].lineTag,
      );
      _lines[i] = merged;
    } else {
      _lines.add(line);
    }
    await _persist();
  }

  @override
  Future<void> setQuantity(
    String productId,
    String variantId,
    int quantity,
  ) async {
    await _ensureLoaded();
    final i = _lines.indexWhere(
      (l) => l.productId == productId && l.variantId == variantId,
    );
    if (i < 0) return;
    if (quantity <= 0) {
      _lines.removeAt(i);
    } else {
      _lines[i] = _lines[i].copyWith(quantity: quantity);
    }
    await _persist();
  }

  @override
  Future<void> removeLine(String productId, String variantId) async {
    await _ensureLoaded();
    _lines.removeWhere(
      (l) => l.productId == productId && l.variantId == variantId,
    );
    await _persist();
  }

  @override
  Future<void> clear() async {
    await _ensureLoaded();
    _lines.clear();
    await _persist();
  }
}

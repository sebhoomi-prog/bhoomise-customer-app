import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/delivery_address_model.dart';
import 'address_remote_datasource.dart';

/// Address list per user in [SharedPreferences], with broadcast updates.
class AddressLocalDataSource implements AddressRemoteDataSource {
  AddressLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  final _uidChanged = StreamController<String>.broadcast();

  String _key(String uid) => 'delivery_addresses_$uid';

  List<DeliveryAddressModel> _load(String uid) {
    final raw = _prefs.getString(_key(uid));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .map((e) => DeliveryAddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) {
        if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
        return a.label.compareTo(b.label);
      });
      return list;
    } on Object {
      return [];
    }
  }

  Future<void> _save(String uid, List<DeliveryAddressModel> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_key(uid), encoded);
    _uidChanged.add(uid);
  }

  @override
  Stream<List<DeliveryAddressModel>> watchAddresses(String uid) async* {
    yield _load(uid);
    yield* _uidChanged.stream.where((u) => u == uid).map(_load);
  }

  @override
  Future<String> createAddress(String uid, DeliveryAddressModel address) async {
    final list = _load(uid);
    final id = 'addr_${DateTime.now().microsecondsSinceEpoch}';
    final withId = DeliveryAddressModel(
      id: id,
      label: address.label,
      recipientName: address.recipientName,
      phone: address.phone,
      line1: address.line1,
      line2: address.line2,
      landmark: address.landmark,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      isDefault: address.isDefault,
    );
    if (withId.isDefault) {
      for (var i = 0; i < list.length; i++) {
        list[i] = list[i].copyWith(isDefault: false);
      }
    }
    list.add(withId);
    await _save(uid, list);
    return id;
  }

  @override
  Future<void> updateAddress(String uid, DeliveryAddressModel address) async {
    final list = _load(uid);
    final i = list.indexWhere((a) => a.id == address.id);
    if (i < 0) return;
    if (address.isDefault) {
      for (var j = 0; j < list.length; j++) {
        if (j != i) {
          list[j] = list[j].copyWith(isDefault: false);
        }
      }
    }
    list[i] = address;
    await _save(uid, list);
  }

  @override
  Future<void> deleteAddress(String uid, String addressId) async {
    final list = _load(uid).where((a) => a.id != addressId).toList();
    await _save(uid, list);
  }

  @override
  Future<void> setDefaultAddress(String uid, String addressId) async {
    final list = _load(uid);
    final next = <DeliveryAddressModel>[];
    for (final a in list) {
      next.add(a.copyWith(isDefault: a.id == addressId));
    }
    await _save(uid, next);
  }
}

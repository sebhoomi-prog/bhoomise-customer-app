import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/location/delivery_location_controller.dart';
import '../../../../../core/network/connectivity_sync_service.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../core/widgets/adaptive_back_button.dart';
import '../../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/delivery_address.dart';
import '../../domain/usecases/create_delivery_address.dart';
import '../../domain/usecases/update_delivery_address.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _recipient;
  late final TextEditingController _phone;
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _landmark;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;

  String _label = AppStrings.labelHome;
  bool _isDefault = true;
  bool _saving = false;
  bool _fillingGps = false;
  Timer? _line1Debounce;

  DeliveryAddress? get _existing =>
      Get.arguments is DeliveryAddress ? Get.arguments as DeliveryAddress : null;

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    final existing = _existing;
    _recipient = TextEditingController(text: existing?.recipientName ?? '');
    _phone = TextEditingController(
      text: existing?.phone ?? auth.currentUser.value?.phoneNumber ?? '',
    );
    _line1 = TextEditingController(text: existing?.line1 ?? '');
    _line2 = TextEditingController(text: existing?.line2 ?? '');
    _landmark = TextEditingController(text: existing?.landmark ?? '');
    _city = TextEditingController(text: existing?.city ?? '');
    _state = TextEditingController(text: existing?.state ?? '');
    _pincode = TextEditingController(text: existing?.pincode ?? '');
    if (existing != null) {
      _label = existing.label;
      _isDefault = existing.isDefault;
    } else {
      _applyPrefillFromArguments();
    }
    _line1.addListener(_onLine1Changed);
  }

  void _applyPrefillFromArguments() {
    final a = Get.arguments;
    if (a is! Map) return;
    final m = Map<String, dynamic>.from(a);
    void take(String key, TextEditingController c) {
      final v = m[key];
      if (v is String && v.trim().isNotEmpty) {
        c.text = v.trim();
      }
    }

    take('line1', _line1);
    take('line2', _line2);
    take('landmark', _landmark);
    take('city', _city);
    take('state', _state);
    take('pincode', _pincode);
  }

  void _onLine1Changed() {
    _line1Debounce?.cancel();
    _line1Debounce = Timer(const Duration(milliseconds: 900), _autocompleteFromTypedAddress);
  }

  Future<void> _autocompleteFromTypedAddress() async {
    if (!mounted) return;
    if (_existing != null) return;
    if (!Get.find<ConnectivitySyncService>().isOnline.value) return;
    final q = _line1.text.trim();
    if (q.length < 10) return;
    try {
      final locs = await locationFromAddress('$q, India');
      if (locs.isEmpty || !mounted) return;
      final marks = await placemarkFromCoordinates(
        locs.first.latitude,
        locs.first.longitude,
      );
      if (marks.isEmpty || !mounted) return;
      final map = placemarkToAddressMap(marks.first);
      setState(() {
        if (_city.text.trim().isEmpty) {
          _city.text = map['city'] ?? '';
        }
        if (_state.text.trim().isEmpty) {
          _state.text = map['state'] ?? '';
        }
        if (_pincode.text.trim().isEmpty) {
          _pincode.text = map['pincode'] ?? '';
        }
      });
    } on Object catch (_) {}
  }

  Future<void> _fillFromCurrentLocation() async {
    final loc = Get.find<DeliveryLocationController>();
    setState(() => _fillingGps = true);
    try {
      await loc.refreshFromGps();
      final map = await loc.fetchPrefillMap();
      if (!mounted) return;
      if (map.isEmpty) return;
      setState(() {
        _line1.text = map['line1'] ?? _line1.text;
        if ((map['line2'] ?? '').isNotEmpty) {
          _line2.text = map['line2']!;
        }
        if ((map['landmark'] ?? '').isNotEmpty) {
          _landmark.text = map['landmark']!;
        }
        _city.text = map['city'] ?? _city.text;
        _state.text = map['state'] ?? _state.text;
        _pincode.text = map['pincode'] ?? _pincode.text;
      });
    } finally {
      if (mounted) setState(() => _fillingGps = false);
    }
  }

  @override
  void dispose() {
    _recipient.dispose();
    _phone.dispose();
    _line1.dispose();
    _line2.dispose();
    _landmark.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _line1.removeListener(_onLine1Changed);
    _line1Debounce?.cancel();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Get.find<AuthController>();
    final uid = auth.currentUser.value?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.signInToSaveAddress),
          action: SnackBarAction(
            label: AppStrings.signIn,
            onPressed: () => Get.toNamed<void>(AppRoutes.login),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final entity = DeliveryAddress(
        id: _existing?.id ?? '',
        label: _label,
        recipientName: _recipient.text.trim(),
        phone: _phone.text.trim(),
        line1: _line1.text.trim(),
        line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
        landmark:
            _landmark.text.trim().isEmpty ? null : _landmark.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        pincode: _pincode.text.trim(),
        isDefault: _isDefault,
      );

      if (_existing == null) {
        await Get.find<CreateDeliveryAddress>()(uid, entity);
      } else {
        await Get.find<UpdateDeliveryAddress>()(uid, entity);
      }
      if (!mounted) return;
      Get.back<void>();
    } on Object catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.addressSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing != null;

    return Scaffold(
      appBar: AppBar(
        leading: adaptiveAppBarLeading(context),
        automaticallyImplyLeading: adaptiveAppBarImplyLeading(context),
        title: Text(isEdit ? AppStrings.editAddress : AppStrings.addAddress),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              AppStrings.addressFormHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _fillingGps ? null : _fillFromCurrentLocation,
              icon: _fillingGps
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded, size: 20),
              label: Text(
                _fillingGps
                    ? AppStrings.locatingPleaseWait
                    : AppStrings.useCurrentLocation,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _label,
                    decoration: InputDecoration(
                      labelText: AppStrings.addressType,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      AppStrings.labelHome,
                      AppStrings.labelWork,
                      AppStrings.labelOther,
                    ]
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text(e)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _label = v ?? _label),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _recipient,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: AppStrings.recipientName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? AppStrings.required : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: InputDecoration(
                      labelText: AppStrings.phone,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().length < 10 ? AppStrings.validPhone : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _line1,
                    decoration: InputDecoration(
                      labelText: AppStrings.addressLine1,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? AppStrings.required : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _line2,
                    decoration: const InputDecoration(
                      labelText: AppStrings.addressLine2,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _landmark,
                    decoration: const InputDecoration(
                      labelText: AppStrings.landmark,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _city,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: AppStrings.city,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? AppStrings.required : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _state,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: AppStrings.state,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? AppStrings.required : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pincode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      labelText: AppStrings.pincode,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.length != 6) return AppStrings.validPincode;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _isDefault,
                    onChanged: (v) =>
                        setState(() => _isDefault = v ?? false),
                    title: const Text(AppStrings.saveAsDefaultAddress),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? AppStrings.save : AppStrings.saveAddress),
            ),
          ],
        ),
      ),
    );
  }
}

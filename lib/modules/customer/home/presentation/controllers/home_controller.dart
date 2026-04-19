import 'dart:async';

import 'package:get/get.dart';

import '../../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../../features/profile/domain/entities/user_profile.dart';
import '../../../../../features/profile/domain/usecases/get_user_profile.dart';
import '../../data/customer_home_defaults.dart';
import '../../data/customer_home_firestore_datasource.dart';
import '../../domain/customer_home_category.dart';

class HomeController extends GetxController {
  HomeController(this._getUserProfile, this._customerHome);

  final GetUserProfile _getUserProfile;
  final CustomerHomeFirestoreDataSource _customerHome;

  final Rxn<UserProfile> profile = Rxn<UserProfile>();
  final RxList<CustomerHomeCategory> homeCategories =
      defaultCustomerHomeCategories().obs;

  StreamSubscription<List<CustomerHomeCategory>>? _categoriesSub;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    ever(auth.currentUser, (user) {
      if (user == null) {
        profile.value = null;
      }
    });
    _categoriesSub = _customerHome.watchCategories().listen((list) {
      homeCategories.assignAll(list);
    });
  }

  @override
  void onClose() {
    _categoriesSub?.cancel();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    final uid = Get.find<AuthController>().currentUser.value?.uid;
    if (uid != null) {
      refreshProfile(uid);
    }
  }

  Future<void> refreshProfile(String uid) async {
    profile.value = await _getUserProfile(uid);
  }
}

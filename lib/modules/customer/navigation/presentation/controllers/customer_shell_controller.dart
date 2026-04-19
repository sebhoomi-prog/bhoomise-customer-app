import 'package:get/get.dart';

/// Drives customer [IndexedStack] tabs (Home · Search · Orders/Bag · Profile).
/// Use [CustomerShellNavigation] so tab index stays in sync when jumping from buttons
/// outside the bottom bar.
class CustomerShellController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void setTab(int i) => tabIndex.value = i.clamp(0, 3);
}

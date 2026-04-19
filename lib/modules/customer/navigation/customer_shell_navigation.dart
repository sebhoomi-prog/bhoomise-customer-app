import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import 'presentation/controllers/customer_shell_controller.dart';

/// Opens a customer shell tab and returns to [/home] when an overlay route
/// (e.g. product detail) would hide the shell.
class CustomerShellNavigation {
  CustomerShellNavigation._();

  static CustomerShellController _controller() {
    if (!Get.isRegistered<CustomerShellController>()) {
      Get.put(CustomerShellController(), permanent: true);
    }
    return Get.find<CustomerShellController>();
  }

  /// Switches shell tab (0–3). Pops overlays or resets stack to home when needed.
  static void openTab(int index) {
    final shell = _controller();
    final i = index.clamp(0, 3);
    shell.setTab(i);

    if (Get.currentRoute != AppRoutes.home) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != AppRoutes.home) {
          Get.offNamed(AppRoutes.home, arguments: i);
        }
      });
    }
  }

  static void goHome() => openTab(0);
  static void goSearch() => openTab(1);
  static void goCart() => openTab(2);
  static void goProfile() => openTab(3);
}

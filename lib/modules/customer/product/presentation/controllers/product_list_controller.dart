import 'package:get/get.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

class ProductListController extends GetxController {
  ProductListController(this._getProducts);

  final GetProducts _getProducts;

  final RxList<Product> products = <Product>[].obs;
  final RxBool loading = true.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      products.assignAll(await _getProducts());
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}

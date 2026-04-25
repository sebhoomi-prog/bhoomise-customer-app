import '../../modules/customer/home/domain/customer_home_category.dart';
import '../base/index.dart';

class HomeStarted extends BaseEvent {
  const HomeStarted();
}

class HomeProfileRefreshRequested extends BaseEvent {
  const HomeProfileRefreshRequested(this.uid);

  final String uid;

  @override
  List<Object?> get props => <Object?>[uid];
}

class HomeCategoriesUpdated extends BaseEvent {
  const HomeCategoriesUpdated(this.categories);

  final List<CustomerHomeCategory> categories;

  @override
  List<Object?> get props => <Object?>[categories];
}

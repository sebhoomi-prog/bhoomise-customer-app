import '../../features/profile/domain/entities/user_profile.dart';
import '../../modules/customer/home/domain/customer_home_category.dart';
import '../../modules/customer/home/data/customer_home_defaults.dart';

class HomeBlocState {
  const HomeBlocState({
    this.profile,
    this.categories = const <CustomerHomeCategory>[],
    this.loadingCategories = true,
  });

  final UserProfile? profile;
  final List<CustomerHomeCategory> categories;
  final bool loadingCategories;

  HomeBlocState copyWith({
    UserProfile? profile,
    bool clearProfile = false,
    List<CustomerHomeCategory>? categories,
    bool? loadingCategories,
  }) {
    return HomeBlocState(
      profile: clearProfile ? null : (profile ?? this.profile),
      categories: categories ?? this.categories,
      loadingCategories: loadingCategories ?? this.loadingCategories,
    );
  }

  List<CustomerHomeCategory> get categoriesOrDefault =>
      categories.isEmpty ? defaultCustomerHomeCategories() : categories;
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../modules/customer/home/data/customer_home_api_datasource.dart';
import '../base/index.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<BaseEvent, HomeBlocState> {
  HomeBloc(this._watchAuthState, this._getUserProfile, this._homeApi)
    : super(const HomeBlocState()) {
    on<HomeStarted>(_onStarted);
    on<HomeProfileRefreshRequested>(_onProfileRefresh);
    on<HomeCategoriesUpdated>(_onCategoriesUpdated);
  }

  final WatchAuthState _watchAuthState;
  final GetUserProfile _getUserProfile;
  final CustomerHomeApiDataSource _homeApi;

  StreamSubscription<dynamic>? _categoriesSub;
  StreamSubscription<dynamic>? _authSub;

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeBlocState> emit,
  ) async {
    await _categoriesSub?.cancel();
    _categoriesSub = _homeApi.watchCategories().listen((list) {
      add(HomeCategoriesUpdated(list));
    });

    await _authSub?.cancel();
    _authSub = _watchAuthState().listen((user) {
      if (user == null) {
        emit(state.copyWith(clearProfile: true));
        return;
      }
      add(HomeProfileRefreshRequested(user.uid));
    });
  }

  Future<void> _onCategoriesUpdated(
    HomeCategoriesUpdated event,
    Emitter<HomeBlocState> emit,
  ) async {
    emit(
      state.copyWith(categories: event.categories, loadingCategories: false),
    );
  }

  Future<void> _onProfileRefresh(
    HomeProfileRefreshRequested event,
    Emitter<HomeBlocState> emit,
  ) async {
    final profile = await _getUserProfile(event.uid);
    emit(state.copyWith(profile: profile));
  }

  @override
  Future<void> close() async {
    await _categoriesSub?.cancel();
    await _authSub?.cancel();
    return super.close();
  }
}

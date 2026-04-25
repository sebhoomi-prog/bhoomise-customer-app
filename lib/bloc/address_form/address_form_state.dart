class AddressFormBlocState {
  const AddressFormBlocState({
    this.uid,
    this.phoneNumber,
    this.saving = false,
    this.requireSignIn = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  final String? uid;
  final String? phoneNumber;
  final bool saving;
  final bool requireSignIn;
  final bool saveSuccess;
  final String? errorMessage;

  AddressFormBlocState copyWith({
    String? uid,
    bool clearUid = false,
    String? phoneNumber,
    bool clearPhoneNumber = false,
    bool? saving,
    bool? requireSignIn,
    bool? saveSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddressFormBlocState(
      uid: clearUid ? null : (uid ?? this.uid),
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      saving: saving ?? this.saving,
      requireSignIn: requireSignIn ?? this.requireSignIn,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../bloc/profile/index.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/adaptive_back_button.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      final state = context.read<ProfileBloc>().state;
      if (state.profile != null) {
        _name.text = state.profile!.displayName;
        _email.text = state.profile!.email ?? '';
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
      ProfileSubmitRequested(displayName: _name.text, email: _email.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileBlocState>(
      listenWhen: (previous, current) =>
          previous.profile != current.profile ||
          previous.errorMessage != current.errorMessage ||
          previous.navigateToRoute != current.navigateToRoute ||
          previous.closeCurrentPage != current.closeCurrentPage,
      listener: (context, state) {
        if (state.profile != null && _name.text.trim().isEmpty) {
          _name.text = state.profile!.displayName;
          _email.text = state.profile!.email ?? '';
        }
        final route = state.navigateToRoute;
        if (route != null && route.isNotEmpty) {
          Get.offAllNamed(route);
          context.read<ProfileBloc>().add(const ProfileUiFlagsCleared());
          return;
        }
        if (state.closeCurrentPage) {
          Get.back<void>();
          context.read<ProfileBloc>().add(const ProfileUiFlagsCleared());
          return;
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<ProfileBloc>().add(const ProfileUiFlagsCleared());
        }
      },
      builder: (context, state) {
        final title = state.isSignup
            ? AppStrings.completeProfile
            : AppStrings.editProfile;
        return Scaffold(
          appBar: AppBar(
            leading: adaptiveAppBarLeading(context),
            automaticallyImplyLeading: adaptiveAppBarImplyLeading(context),
            title: Text(title),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  state.isSignup
                      ? AppStrings.signupProfileSubtitle
                      : AppStrings.editProfileSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: AppStrings.fullName,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return AppStrings.enterName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppStrings.emailOptional,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: state.loading ? null : _submit,
                  child: state.loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          state.isSignup
                              ? AppStrings.continueLabel
                              : AppStrings.save,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/adaptive_back_button.dart';
import '../../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../../features/profile/domain/entities/user_profile.dart';
import '../../../../../features/auth/domain/entities/auth_user.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';

const Color _kGreen = Color(0xFF006B2C);
const Color _kGreenAlt = Color(0xFF00873A);
const Color _kInk = Color(0xFF121C2A);
const Color _kMeta = Color(0xFF5D5D4E);
const Color _kRowIcon = Color(0xFF3E4A3D);
const Color _kChevron = Color(0xFF6E7B6C);
const Color _kLogoutRed = Color(0xFFBA1A1A);
const Color _kAccountShell = Color(0xFFEFF4FF);
const Color _kLogoutBg = Color(0xFFD9E3F6);
const Color _kIconWell = Color(0xFFF8F9FF);
const Color _kAvatarBorder = Color(0xFFDEE9FC);

const String _kAvatarUrl =
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?fm=jpg&fit=crop&w=400&q=80';

/// Customer shell **Profile** tab — Figma Customer Profile (frost header, identity, bento, settings).
class CustomerProfileTabPage extends StatelessWidget {
  const CustomerProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const headerH = 68.0;
    final scrollTop = topInset + headerH + 32;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 112;

    return Scaffold(
      backgroundColor: DesignTokens.figmaHeaderFrostTint,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Obx(() {
              Get.find<AuthController>().currentUser.value;
              Get.find<CartController>().cartVersion.value;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, scrollTop, 24, bottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _IdentityBlock(
                      avatarUrl: _kAvatarUrl,
                      kGreen: _kGreen,
                      kGreenAlt: _kGreenAlt,
                      kInk: _kInk,
                      kMeta: _kMeta,
                      kAvatarBorder: _kAvatarBorder,
                    ),
                    const SizedBox(height: 32),
                    _QuickBentoGrid(
                      kGreen: _kGreen,
                      kInk: _kInk,
                      kMeta: _kMeta,
                    ),
                    const SizedBox(height: 32),
                    _AccountSettingsBlock(
                      kGreen: _kGreen,
                      kInk: _kInk,
                      kRowIcon: _kRowIcon,
                      kChevron: _kChevron,
                    ),
                    const SizedBox(height: 32),
                    _LogoutSection(kLogoutBg: _kLogoutBg, kLogoutRed: _kLogoutRed),
                  ],
                ),
              );
            }),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _FigmaProfileHeader(
              topInset: topInset,
              height: headerH,
              kGreen: _kGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaProfileHeader extends StatelessWidget {
  const _FigmaProfileHeader({
    required this.topInset,
    required this.height,
    required this.kGreen,
  });

  final double topInset;
  final double height;
  final Color kGreen;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24, topInset + 16, 24, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FF).withValues(alpha: 0.7),
          ),
          child: SizedBox(
            height: height - 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      adaptiveFrostedBackControl(
                        context,
                        iconColor: kGreen,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppStrings.navProfile,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 24,
                            height: 32 / 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: kGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings — coming soon')),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: kGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({
    required this.avatarUrl,
    required this.kGreen,
    required this.kGreenAlt,
    required this.kInk,
    required this.kMeta,
    required this.kAvatarBorder,
  });

  final String avatarUrl;
  final Color kGreen;
  final Color kGreenAlt;
  final Color kInk;
  final Color kMeta;
  final Color kAvatarBorder;

  String _phoneLine(AuthUser? auth, UserProfile? profile) {
    final raw = profile?.phoneNumber?.trim().isNotEmpty == true
        ? profile!.phoneNumber!
        : auth?.phoneNumber;
    if (raw == null || raw.isEmpty) return 'Add phone in account';
    final t = raw.trim();
    if (t.startsWith('+91') && t.length >= 12) {
      final d = t.substring(3);
      return '+91 $d • ${AppStrings.appName}';
    }
    if (t.startsWith('+1') && t.length >= 12) {
      final d = t.replaceAll(RegExp(r'\D'), '');
      if (d.length >= 11) {
        final a = d.substring(1);
        return '+1 (${a.substring(0, 3)}) ${a.substring(3, 6)}-${a.substring(6)} • ${AppStrings.appName}';
      }
    }
    return '$t • ${AppStrings.appName}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      final user = auth.currentUser.value;
      final profile = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>().profile.value
          : null;
      final name = user == null
          ? 'Guest'
          : (profile?.displayName.trim().isNotEmpty == true
              ? profile!.displayName
              : 'Member');

      return Column(
        children: [
          Center(
            child: SizedBox(
              width: 128,
              height: 128,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(color: kAvatarBorder, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(44),
                      child: user == null
                          ? ColoredBox(
                              color: kAvatarBorder,
                              child: Icon(
                                Icons.person_rounded,
                                size: 56,
                                color: kGreen.withValues(alpha: 0.5),
                              ),
                            )
                          : Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: kAvatarBorder,
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty
                                        ? name.substring(0, 1).toUpperCase()
                                        : '?',
                                    style: GoogleFonts.manrope(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                      color: kGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (user != null)
                    Positioned(
                      right: -8,
                      bottom: -8,
                      child: Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [kGreen, kGreenAlt],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: DesignTokens.figmaHeaderFrostTint,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (user != null)
            Align(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.toNamed(AppRoutes.profileEdit),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 30,
                        height: 36 / 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.75,
                        color: kInk,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 30,
                height: 36 / 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.75,
                color: kInk,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            user == null ? 'Sign in to sync orders & addresses' : _phoneLine(user, profile),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w400,
              color: kMeta,
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_rounded, size: 12, color: kGreen),
                  const SizedBox(width: 8),
                  Text(
                    'MEMBER SINCE OCT 2023',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      height: 15 / 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: kGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _QuickBentoGrid extends StatelessWidget {
  const _QuickBentoGrid({
    required this.kGreen,
    required this.kInk,
    required this.kMeta,
  });

  final Color kGreen;
  final Color kInk;
  final Color kMeta;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Obx(() {
      final n = cart.lines.length;
      final active = '$n ACTIVE';
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _BentoTile(
                  icon: Icons.storefront_outlined,
                  title: 'My Orders',
                  subtitle: active,
                  kGreen: kGreen,
                  kInk: kInk,
                  kMeta: kMeta,
                  onTap: () => Get.toNamed(AppRoutes.orderTrack, arguments: 'SH-9921'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BentoTile(
                  icon: Icons.location_on_outlined,
                  title: 'Addresses',
                  subtitle: '2 SAVED',
                  kGreen: kGreen,
                  kInk: kInk,
                  kMeta: kMeta,
                  onTap: () => Get.toNamed(AppRoutes.addresses),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BentoTile(
                  icon: Icons.payments_outlined,
                  title: 'Refunds',
                  subtitle: 'NO PENDING',
                  kGreen: kGreen,
                  kInk: kInk,
                  kMeta: kMeta,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refunds — coming soon')),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BentoTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Support',
                  subtitle: '24/7 CARE',
                  kGreen: kGreen,
                  kInk: kInk,
                  kMeta: kMeta,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support — coming soon')),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.kGreen,
    required this.kInk,
    required this.kMeta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color kGreen;
  final Color kInk;
  final Color kMeta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0x1ABDCABA)),
            boxShadow: [
              BoxShadow(
                color: kGreen.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: kGreen, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  height: 15 / 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: kMeta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountSettingsBlock extends StatelessWidget {
  const _AccountSettingsBlock({
    required this.kGreen,
    required this.kInk,
    required this.kRowIcon,
    required this.kChevron,
  });

  final Color kGreen;
  final Color kInk;
  final Color kRowIcon;
  final Color kChevron;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'Account Settings',
            style: GoogleFonts.manrope(
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: kGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _kAccountShell,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                kInk: kInk,
                kRowIcon: kRowIcon,
                kChevron: kChevron,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications — coming soon')),
                ),
              ),
              const SizedBox(height: 4),
              _SettingsRow(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Payments',
                kInk: kInk,
                kRowIcon: kRowIcon,
                kChevron: kChevron,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payments — coming soon')),
                ),
              ),
              const SizedBox(height: 4),
              _SettingsRow(
                icon: Icons.translate_rounded,
                title: 'Language',
                subtitle: 'English',
                kInk: kInk,
                kRowIcon: kRowIcon,
                kChevron: kChevron,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language — coming soon')),
                ),
              ),
              const SizedBox(height: 4),
              _SettingsRow(
                icon: Icons.description_outlined,
                title: 'Legal',
                kInk: kInk,
                kRowIcon: kRowIcon,
                kChevron: kChevron,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Legal — coming soon')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.kInk,
    required this.kRowIcon,
    required this.kChevron,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color kInk;
  final Color kRowIcon;
  final Color kChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _kIconWell,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: kRowIcon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: subtitle == null
                    ? Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w700,
                          color: kInk,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              height: 24 / 16,
                              fontWeight: FontWeight.w700,
                              color: kInk,
                            ),
                          ),
                          Text(
                            subtitle!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w500,
                              color: _kMeta,
                            ),
                          ),
                        ],
                      ),
              ),
              Icon(Icons.chevron_right_rounded, color: kChevron, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  const _LogoutSection({
    required this.kLogoutBg,
    required this.kLogoutRed,
  });

  final Color kLogoutBg;
  final Color kLogoutRed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = Get.find<AuthController>();
      final loggedIn = auth.currentUser.value != null;
      if (!loggedIn) {
        return FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _kGreen,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          onPressed: () => Get.toNamed(AppRoutes.login),
          child: Text(
            AppStrings.signIn,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }
      return Material(
        color: kLogoutBg,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () => auth.signOutUser(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: kLogoutRed, size: 20),
                const SizedBox(width: 12),
                Text(
                  AppStrings.signOut,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w800,
                    color: kLogoutRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

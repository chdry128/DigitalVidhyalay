// ============================================================
//  PROFILE — Student ki details, help, about, logout
//
//  Menu me nayi line jodni ho → neeche _MenuItem(...) copy karo
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../data/models/user_profile.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import '../widgets/app_card.dart';
import 'login_screen.dart';
import 'my_certificates_screen.dart';
import 'payment_history_screen.dart';
import 'profile_setup_screen.dart';
import 'verify_certificate_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout karein?'),
        content: const Text('Dobara login karne ke liye OTP lagega.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;

    await context.read<AppState>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Help & Support', style: AppText.h2),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.call_outlined, color: AppColors.primary),
                title: const Text('Call karein'),
                subtitle: const Text(
                  '${AppConfig.supportPhoneLabel} · ${AppConfig.supportTimings}',
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  callSupport(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_outlined, color: AppColors.primary),
                title: const Text('WhatsApp'),
                subtitle: const Text('Chat par jaldi jawab'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  openWhatsApp(context, message: 'Hello Digital Vidyalaya, mujhe help chahiye.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                title: const Text('Email'),
                subtitle: const Text(AppConfig.supportEmail),
                onTap: () {
                  Navigator.pop(sheetContext);
                  emailSupport(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.jpg', width: 110, height: 110),
            const SizedBox(height: 12),
            const Text(AppConfig.appName, style: AppText.h2),
            const SizedBox(height: 4),
            const Text(
              AppConfig.companyName,
              textAlign: TextAlign.center,
              style: AppText.small,
            ),
            const SizedBox(height: 12),
            const Text(
              'Online courses, practical internships aur university admission guidance — kam fees me.',
              textAlign: TextAlign.center,
              style: AppText.muted,
            ),
            const SizedBox(height: 12),
            const Text(AppConfig.appVersionLabel, style: AppText.tiny),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProfile? user = context.watch<AppState>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // ---------- User card ----------
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    user?.initials ?? 'S',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Student', style: AppText.h2),
                      if ((user?.college ?? '').isNotEmpty)
                        Text(user!.college, style: AppText.small),
                      if ((user?.phone ?? '').isNotEmpty)
                        Text('+91 ${user!.phone}', style: AppText.small),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profile',
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileSetupScreen(isEditing: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---------- Menu ----------
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.workspace_premium_outlined,
                  label: 'My Certificates',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const MyCertificatesScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Verify Certificate',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const VerifyCertificateScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Payment History',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const PaymentHistoryScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.support_agent_rounded,
                  label: 'Free Admission Counselling',
                  onTap: () => openWhatsApp(
                    context,
                    message: context.read<AppState>().home.counsellingMessage,
                  ),
                ),
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () => _showHelp(context),
                ),
                _MenuItem(
                  icon: Icons.language_rounded,
                  label: 'Visit Website',
                  onTap: () => openWebsite(context),
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About Digital Vidyalaya',
                  onTap: () => _showAbout(context),
                ),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  color: AppColors.error,
                  showDivider: false,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text(AppConfig.appVersionLabel, style: AppText.tiny)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textDark,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color == AppColors.textDark ? AppColors.textMuted : color),
          title: Text(label, style: TextStyle(fontSize: 14, color: color)),
          trailing: Icon(Icons.chevron_right_rounded, color: color == AppColors.textDark ? AppColors.textMuted : color),
          onTap: onTap,
        ),
        if (showDivider) const Divider(indent: 16, endIndent: 16),
      ],
    );
  }
}

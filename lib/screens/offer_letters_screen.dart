// ============================================================
//  OFFER LETTERS SCREEN — Student ke internship offer letters
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/offer_letter.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

class OfferLettersScreen extends StatefulWidget {
  const OfferLettersScreen({super.key});

  @override
  State<OfferLettersScreen> createState() => _OfferLettersScreenState();
}

class _OfferLettersScreenState extends State<OfferLettersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().loadOfferLetters();
      }
    });
  }

  void _copyRef(BuildContext context, String refNo) {
    Clipboard.setData(ClipboardData(text: refNo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Offer Reference $refNo copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final List<OfferLetterRecord> offers = state.offerLetters;

    return Scaffold(
      appBar: AppBar(title: const Text('Internship Offer Letters')),
      body: Builder(
        builder: (context) {
          if (state.isLoadingOfferLetters && offers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.offerLettersError != null && offers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    const Text('Offer letters load nahi ho paye', style: AppText.title),
                    const SizedBox(height: 8),
                    Text(
                      state.offerLettersError!,
                      textAlign: TextAlign.center,
                      style: AppText.small,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AppState>().loadOfferLetters(forceRefresh: true),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Dobara koshish karein'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (offers.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<AppState>().loadOfferLetters(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.mark_email_read_outlined,
                    title: 'Abhi koi offer letter nahi',
                    message: 'Internship me enroll karne par official offer letter yahan jari kiya jayega.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AppState>().loadOfferLetters(forceRefresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.gap),
              itemBuilder: (context, index) {
                final OfferLetterRecord o = offers[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.programTitle, style: AppText.cardTitle),
                                const SizedBox(height: 2),
                                Text('${o.category} · ${o.durationWeeks} Weeks', style: AppText.small),
                                const SizedBox(height: 2),
                                Text('Issued: ${o.dateLabel}', style: AppText.tiny),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ref No:', style: AppText.tiny),
                          GestureDetector(
                            onTap: () => _copyRef(context, o.offerRefNo),
                            child: Row(
                              children: [
                                Text(
                                  o.offerRefNo,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (o.pdfDownloadUrl != null && o.pdfDownloadUrl!.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => openLink(context, o.pdfDownloadUrl!),
                                icon: const Icon(Icons.download_rounded, size: 16),
                                label: const Text('Download PDF', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          if (o.pdfDownloadUrl != null && o.pdfDownloadUrl!.isNotEmpty)
                            const SizedBox(width: 8),
                          if (o.verificationUrl != null && o.verificationUrl!.isNotEmpty)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => openLink(context, o.verificationUrl!),
                                icon: const Icon(Icons.verified_user_outlined, size: 16),
                                label: const Text('Verify Online', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
//  INTERNSHIPS SCREEN — Paid / Free / Stipend / Project tabs
//                       + domain filter (Software, AI & ML ...)
//
//  Internships badalni ho to: assets/data/internships.json
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/internship.dart';
import '../state/app_state.dart';
import '../widgets/app_chip.dart';
import '../widgets/empty_state.dart';
import '../widgets/internship_card.dart';
import 'internship_detail_screen.dart';

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({super.key});

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {
  String _type = 'paid'; // Kaunsa tab khula hai
  String _domain = 'All'; // Kaunsa domain chuna hai

  // Tabs pe dikhne wale naam
  static const Map<String, String> _tabNames = {
    'paid': 'Paid',
    'free': 'Free',
    'stipend': 'Stipend',
    'project': 'Project',
  };

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<Internship> ofType = state.internshipsOfType(_type);
    final List<Internship> list =
        _domain == 'All' ? ofType : ofType.where((i) => i.domain == _domain).toList();
    final List<String> domains = state.domainsForType(_type);

    return Scaffold(
      appBar: AppBar(title: const Text('Internships'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          // ---------- Type tabs ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (final String type in Internship.allTypes)
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        _type = type;
                        _domain = 'All';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _type == type ? AppColors.primary : AppColors.border,
                              width: _type == type ? 2 : 1,
                            ),
                          ),
                        ),
                        child: Text(
                          '${_tabNames[type]} (${state.internshipsOfType(type).length})',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _type == type ? FontWeight.w600 : FontWeight.w500,
                            color: _type == type ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------- Domain chips (sirf jab 1 se zyada domain ho) ----------
          if (domains.length > 1) ...[
            ChipBar(
              labels: ['All', ...domains],
              selected: _domain,
              onSelected: (value) => setState(() => _domain = value),
            ),
            const SizedBox(height: 12),
          ],

          // ---------- List ----------
          Expanded(
            child: list.isEmpty
                ? const EmptyState(
                    icon: Icons.work_off_outlined,
                    title: 'Abhi koi internship nahi',
                    message: 'Jald hi naye programs aayenge.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.gap),
                    itemBuilder: (context, index) {
                      final Internship internship = list[index];
                      return InternshipCard(
                        internship: internship,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => InternshipDetailScreen(internship: internship),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

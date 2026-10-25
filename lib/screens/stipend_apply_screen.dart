// ============================================================
//  STIPEND APPLY — Stipend wali internship ka application form
//
//  Form ke sawaal badalne ho to neeche _Field(...) badlein.
//  Resume upload backend lagne ke baad jodenge (abhi Drive link).
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../data/models/internship.dart';
import '../data/models/user_profile.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';

class StipendApplyScreen extends StatefulWidget {
  const StipendApplyScreen({super.key, required this.internship});

  final Internship internship;

  @override
  State<StipendApplyScreen> createState() => _StipendApplyScreenState();
}

class _StipendApplyScreenState extends State<StipendApplyScreen> {
  // College ka saal — options yahan se badlein
  static const List<String> _years = ['1st year', '2nd year', '3rd year', '4th year', 'Pass out'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _college;
  final TextEditingController _resume = TextEditingController();
  final TextEditingController _why = TextEditingController();
  String? _year;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final UserProfile? user = context.read<AppState>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _college = TextEditingController(text: user?.college ?? '');
  }

  @override
  void dispose() {
    for (final TextEditingController c in [_name, _phone, _college, _resume, _why]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    // DEMO: phone me "applied" save hota hai. Backend me form server pe jayega.
    await context.read<AppState>().applyForInternship(widget.internship);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
        title: const Text('Application submit ho gayi'),
        content: const Text(
          'Hamari team 48 ghante me aapko call karegi. Selection ke baad internship shuru hogi.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Theek hai')),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Yeh bharna zaroori hai' : null;

  @override
  Widget build(BuildContext context) {
    final Internship internship = widget.internship;
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Internship')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AppCard(
                color: AppColors.primaryLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(internship.title, style: AppText.title),
                    if (internship.role != null) Text(internship.role!, style: AppText.small),
                    const SizedBox(height: 4),
                    Text(
                      '${internship.priceLabel} stipend · ${internship.durationLabel}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _Field(label: 'Full name *', child: TextFormField(controller: _name, validator: _required)),
              _Field(
                label: 'Mobile number *',
                child: TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(counterText: '', prefixText: '+91 '),
                  validator: (v) => RegExp(r'^[6-9][0-9]{9}$').hasMatch(v?.trim() ?? '')
                      ? null
                      : 'Sahi 10-digit number daalein',
                ),
              ),
              _Field(
                label: 'College / University *',
                child: TextFormField(controller: _college, validator: _required),
              ),
              _Field(
                label: 'Current year *',
                child: DropdownButtonFormField<String>(
                  initialValue: _year,
                  hint: const Text('Chunein'),
                  items: [
                    for (final String y in _years) DropdownMenuItem<String>(value: y, child: Text(y)),
                  ],
                  onChanged: (v) => setState(() => _year = v),
                  validator: (v) => v == null ? 'Saal chunein' : null,
                ),
              ),
              _Field(
                label: 'Resume link (Google Drive)',
                child: TextFormField(
                  controller: _resume,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(hintText: 'https://drive.google.com/...'),
                ),
              ),
              _Field(
                label: 'Aapko kyon select karein? *',
                child: TextFormField(
                  controller: _why,
                  maxLines: 4,
                  validator: _required,
                  decoration: const InputDecoration(
                    hintText: 'Apni skills aur interest ke baare me 2-3 line likhein',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

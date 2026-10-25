// ============================================================
//  PROFILE SETUP — Naam, email, college, city
//
//  2 jagah use hoti hai:
//   • Pehli baar login ke baad (isEditing = false)
//   • Profile → Edit Profile    (isEditing = true)
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../data/models/user_profile.dart';
import '../state/app_state.dart';
import 'main_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.isEditing = false});

  final bool isEditing;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _college;
  late final TextEditingController _city;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final UserProfile? user = context.read<AppState>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _college = TextEditingController(text: user?.college ?? '');
    _city = TextEditingController(text: user?.city ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _college.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await context.read<AppState>().saveProfile(
          name: _name.text,
          email: _email.text,
          college: _college.text,
          city: _city.text,
        );
    if (!mounted) return;

    if (widget.isEditing) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile update ho gayi')),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Profile' : 'Create Profile'),
        automaticallyImplyLeading: widget.isEditing,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (!widget.isEditing) ...[
                const Text('Apne baare me batayein', style: AppText.h1),
                const SizedBox(height: 6),
                const Text(
                  'Isse hum aapke liye sahi courses suggest kar payenge.',
                  style: AppText.muted,
                ),
                const SizedBox(height: 12),
              ],
              _Field(
                label: 'Full name *',
                controller: _name,
                hint: 'e.g. Rahul Kumar',
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Naam likhna zaroori hai' : null,
              ),
              _Field(
                label: 'Email address',
                controller: _email,
                hint: 'e.g. rahul@gmail.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final String value = v?.trim() ?? '';
                  if (value.isEmpty) return null; // email optional hai
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
                      ? null
                      : 'Sahi email likhein';
                },
              ),
              _Field(
                label: 'College / University *',
                controller: _college,
                hint: 'Aapke college ka naam',
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'College ka naam likhein' : null,
              ),
              _Field(
                label: 'City',
                controller: _city,
                hint: 'e.g. Roorkee',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(widget.isEditing ? 'Save Changes' : 'Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label + input box
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            validator: validator,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  LAUNCHER — Call, WhatsApp, Email aur Website kholna
//
//  Number / email badalna ho to yahan nahi,
//  config/app_config.dart me badlein.
// ============================================================
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

Future<void> _open(BuildContext context, Uri uri) async {
  bool opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeh app phone me nahi khul paya')),
    );
  }
}

/// WhatsApp chat kholta hai (message pehle se likha hota hai)
Future<void> openWhatsApp(BuildContext context, {String message = ''}) {
  final Uri uri = Uri.parse(
    'https://wa.me/${AppConfig.whatsappNumber}?text=${Uri.encodeComponent(message)}',
  );
  return _open(context, uri);
}

/// Support number pe call
Future<void> callSupport(BuildContext context) {
  return _open(context, Uri(scheme: 'tel', path: AppConfig.supportPhone));
}

/// Support email
Future<void> emailSupport(BuildContext context) {
  return _open(
    context,
    Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      query: 'subject=${Uri.encodeComponent('Digital Vidyalaya App Support')}',
    ),
  );
}

/// Website browser me
Future<void> openWebsite(BuildContext context) {
  return _open(context, Uri.parse(AppConfig.websiteUrl));
}

/// Koi bhi link browser me
Future<void> openLink(BuildContext context, String url) {
  return _open(context, Uri.parse(url));
}

/// YouTube video YouTube app me (app ke andar player na chale to backup)
Future<void> openYouTube(BuildContext context, String videoId) {
  return _open(context, Uri.parse('https://www.youtube.com/watch?v=$videoId'));
}

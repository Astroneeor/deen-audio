import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// One source credited in Settings → About.
class Credit {
  const Credit(this.label, this.detail, this.url);

  final String label;
  final String detail;

  /// Shown as text; tapping the row copies it.
  final String url;
}

/// The content sources the app ships or downloads, with their terms. Tanzil's
/// terms require the source to be named with a link to tanzil.net.
const appCredits = [
  Credit(
    'Quran text',
    'Tanzil Project, Uthmani text · CC BY 3.0, unmodified',
    'https://tanzil.net',
  ),
  Credit(
    'Translation',
    'Saheeh International, via tanzil.net',
    'https://tanzil.net/trans/',
  ),
  Credit(
    'Arabic font',
    'Amiri Quran · SIL Open Font License',
    'https://amirifont.org',
  ),
  Credit(
    'Recitations',
    'QuranicAudio.com · personal use only',
    'https://quranicaudio.com',
  ),
];

/// A credit row: label, detail and URL as text. Tap copies the URL.
class CreditTile extends StatelessWidget {
  const CreditTile(this.credit, {super.key});

  final Credit credit;

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: credit.url));
    messenger?.showSnackBar(
      SnackBar(content: Text('Copied ${credit.url}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _copy(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(credit.label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(credit.detail,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(credit.url,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          color: AppColors.gold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

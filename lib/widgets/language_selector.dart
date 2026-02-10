import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'change_language'.tr(),
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _langButton(context, const Locale('en'), 'lang_en'.tr()),
            const SizedBox(width: 10),
            _langButton(context, const Locale('ru'), 'lang_ru'.tr()),
            const SizedBox(width: 10),
            _langButton(context, const Locale('kk'), 'lang_kk'.tr()),
          ],
        ),
      ],
    );
  }

  Widget _langButton(BuildContext context, Locale locale, String label) {
    final currentLocale = context.locale;
    final isSelected = currentLocale == locale;

    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          await context.setLocale(locale);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? const Color(0xFF4F46E5) : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
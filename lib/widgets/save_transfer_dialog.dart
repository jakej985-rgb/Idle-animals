import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_notifier.dart';
import '../theme/app_theme.dart';

/// Moves progress across an app-data clear or a device swap, which the single
/// local save cannot survive on its own.
class SaveTransferDialog extends ConsumerStatefulWidget {
  const SaveTransferDialog({super.key});

  @override
  ConsumerState<SaveTransferDialog> createState() => _SaveTransferDialogState();
}

class _SaveTransferDialogState extends ConsumerState<SaveTransferDialog> {
  final TextEditingController _input = TextEditingController();
  String? _error;
  bool _copied = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _copy(String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  void _restore() {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (ref.read(gameProvider.notifier).importSave(_input.text)) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Save restored.')));
      return;
    }
    setState(
      () => _error = 'That is not a complete Extinction Sanctuary backup.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.read(gameProvider.notifier).exportSave();

    return Dialog(
      backgroundColor: AppColors.sheet,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.borderStrong),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Save data', style: AppText.title),
              const SizedBox(height: 6),
              const Text(
                'Keep a copy of this text somewhere safe. Restoring it replaces '
                'the progress on this device.',
                style: AppText.body,
              ),
              const SizedBox(height: 14),
              const Text('BACKUP', style: AppText.overline),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 90),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    token,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copy(token),
                      icon: const Icon(Icons.copy, size: 16),
                      label: Text(_copied ? 'Copied' : 'Copy backup'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('RESTORE', style: AppText.overline),
              const SizedBox(height: 6),
              TextField(
                controller: _input,
                minLines: 2,
                maxLines: 3,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste a backup here',
                  hintStyle: const TextStyle(
                    color: AppColors.textSubdued,
                    fontSize: 12,
                  ),
                  errorText: _error,
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _restore,
                  child: const Text('Restore'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

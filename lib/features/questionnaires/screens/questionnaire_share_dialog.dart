import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/app_models.dart';
import '../../../core/providers/sync_provider.dart';
import 'public_questionnaire_screen.dart';

class QuestionnaireShareDialog extends ConsumerStatefulWidget {
  const QuestionnaireShareDialog({super.key, required this.questionnaire});
  final Questionnaire questionnaire;
  @override
  ConsumerState<QuestionnaireShareDialog> createState() =>
      _QuestionnaireShareDialogState();
}

class _QuestionnaireShareDialogState
    extends ConsumerState<QuestionnaireShareDialog> {
  final _slug = TextEditingController();
  final _consent = TextEditingController(
      text:
          'I have read the study information above and voluntarily agree to participate.');
  bool _name = true, _contact = false, _busy = true;
  int _days = 30;
  String? _error;
  Map<String, dynamic>? _link;
  @override
  void initState() {
    super.initState();
    _request('status');
  }

  @override
  void dispose() {
    _slug.dispose();
    _consent.dispose();
    super.dispose();
  }

  Future<void> _request(String action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (action == 'publish') {
        await ref.read(syncProvider.notifier).syncAll();
        final sync = ref.read(syncProvider);
        if (sync.status != SyncStateStatus.success)
          throw Exception(
              'Sync the questionnaire successfully before publishing. ${sync.message ?? ''}');
      }
      final result = await questionnaireLinkRequest({
        'action': action,
        'questionnaireId': widget.questionnaire.id,
        'slug': _slug.text.trim().toLowerCase(),
        'consentText': _consent.text.trim(),
        'collectName': _name,
        'collectContact': _contact,
        'days': _days
      });
      if (!mounted) return;
      setState(() {
        _link = result['link'] == null
            ? null
            : Map<String, dynamic>.from(result['link']);
        if (_link != null) {
          _slug.text = _link!['slug'];
          _consent.text = _link!['consent_text'];
          _name = _link!['collect_name'];
          _contact = _link!['collect_contact'];
        }
      });
    } catch (e) {
      if (mounted)
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _link?['active'] == true &&
        DateTime.parse(_link!['expires_at']).isAfter(DateTime.now());
    final url =
        _link == null ? null : 'https://www.afrisoft.space/${_link!['slug']}';
    return AlertDialog(
        title: const Text('Collect & share questionnaire'),
        content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(widget.questionnaire.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () {
                              Navigator.pop(context);
                              context.go(
                                  '/data-collection/${widget.questionnaire.id}');
                            },
                      icon: const Icon(Icons.phone_android),
                      label:
                          const Text('Answer on this device (works offline)')),
                  const Divider(height: 32),
                  const Text(
                      'Online link — participants do not need an account.'),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _slug,
                      enabled: !_busy && _link == null,
                      decoration: const InputDecoration(
                          labelText: 'Unique link name',
                          prefixText: 'afrisoft.space/',
                          hintText: 'kondwani001',
                          helperText:
                              '6–60 lowercase letters, numbers or hyphens. Reserved once created.')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _consent,
                      enabled: !_busy,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Study information and consent *',
                          helperText:
                              'Explain the purpose and what participants agree to.')),
                  SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Collect participant names'),
                      subtitle: const Text(
                          'Every participant also gets an identification code.'),
                      value: _name,
                      onChanged:
                          _busy ? null : (v) => setState(() => _name = v)),
                  SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ask for optional phone and email'),
                      value: _contact,
                      onChanged:
                          _busy ? null : (v) => setState(() => _contact = v)),
                  DropdownButtonFormField<int>(
                      initialValue: _days,
                      decoration: const InputDecoration(
                          labelText: 'Accept responses for'),
                      items: [7, 30, 90, 365]
                          .map((d) => DropdownMenuItem(
                              value: d, child: Text('$d days')))
                          .toList(),
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _days = v ?? 30)),
                  const SizedBox(height: 12),
                  const Text(
                      'Anyone with this public link can respond. Participants cannot see other answers. The link accepts up to 10,000 submissions.'),
                  if (_link != null) ...[
                    const SizedBox(height: 16),
                    Text(active ? 'Open for responses' : 'Closed or expired',
                        style: TextStyle(
                            color: active ? Colors.green : Colors.orange)),
                    SelectableText(url!),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      OutlinedButton.icon(
                          onPressed: active
                              ? () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: url));
                                  if (context.mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Link copied')));
                                }
                              : null,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy link')),
                      OutlinedButton(
                          onPressed: active
                              ? () {
                                  Navigator.pop(context);
                                  context.push('/${_link!['slug']}');
                                }
                              : null,
                          child: const Text('Open participant view')),
                    ]),
                    const Text(
                        'Public links become reachable after GitHub Pages and the domain are connected.'),
                  ],
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                  if (_busy)
                    const Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator()),
                ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done')),
          if (active)
            TextButton(
                onPressed: _busy ? null : () => _request('close'),
                child: const Text('Close link')),
          FilledButton(
              onPressed: _busy ? null : () => _request('publish'),
              child: Text(
                  active ? 'Update link settings' : 'Publish online link')),
        ]);
  }
}

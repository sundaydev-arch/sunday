import "package:cloudflare_turnstile/cloudflare_turnstile.dart";
import "package:flutter/material.dart";

import "../core/analytics.dart";
import "../core/config.dart";
import "../core/theme.dart";
import "../data/contact_api.dart";
import "../data/contact_validation.dart";
import "../i18n/dictionary.dart";

class ContactForm extends StatefulWidget {
  const ContactForm({super.key, required this.dict});

  final Dictionary dict;

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  final _api = ContactApi();
  final _turnstileController = TurnstileController();

  String? _turnstileToken;
  var _pending = false;
  Map<String, String> _fieldErrors = {};

  Map<String, String> get _fields => widget.dict.contactFields;
  Map<String, String> get _validation => widget.dict.contactValidation;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    _turnstileController.dispose();
    super.dispose();
  }

  String _messageFor(ContactValidationError code) =>
      _validation[code] ?? contactErrorMessages[code] ?? code;

  Future<void> _submit() async {
    if (_pending) return;

    if (AppConfig.hasTurnstile &&
        (_turnstileToken == null || _turnstileToken!.isEmpty)) {
      _toast(_fields["error"]!, detail: _messageFor("captcha_required"));
      return;
    }

    final parsed = parseContactBody(
      name: _name.text,
      email: _email.text,
      message: _message.text,
      turnstileToken: _turnstileToken,
    );

    if (!parsed.success) {
      setState(() {
        _fieldErrors = {
          for (final e in (parsed.fieldErrors ?? {}).entries)
            e.key: _messageFor(e.value),
        };
      });
      _toast(_fields["error"]!, detail: _messageFor(parsed.error!));
      return;
    }

    setState(() {
      _pending = true;
      _fieldErrors = {};
    });

    final result = await _api.submit(parsed.data!);

    if (!mounted) return;

    setState(() => _pending = false);

    switch (result) {
      case ContactSubmitOk():
        await Analytics.instance.captureEvent(
          AnalyticsEvents.contactSubmitSucceeded,
        );
        _name.clear();
        _email.clear();
        _message.clear();
        _turnstileToken = null;
        await _turnstileController.refreshToken();
        _toast(_fields["success"]!);
      case ContactSubmitErr(:final message, :final statusCode, :final code):
        await Analytics.instance.captureEvent(
          AnalyticsEvents.contactSubmitFailed,
          properties: {"status": statusCode ?? 0},
        );
        final detail = message == "network"
            ? _fields["network"]!
            : (code != null ? _messageFor(code) : message);
        _toast(_fields["error"]!, detail: detail);
        _turnstileToken = null;
        await _turnstileController.refreshToken();
    }
  }

  void _toast(String title, {String? detail}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: SundayColors.ink)),
            if (detail != null) ...[
              const SizedBox(height: 4),
              Text(detail, style: const TextStyle(color: SundayColors.muted)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.dict.contact["formHint"] as String,
          style: theme.textTheme.labelSmall?.copyWith(
            color: SundayColors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        _field(
          controller: _name,
          label: _fields["name"]!,
          hint: _fields["namePlaceholder"]!,
          error: _fieldErrors["name"],
        ),
        const SizedBox(height: 12),
        _field(
          controller: _email,
          label: _fields["email"]!,
          hint: _fields["emailPlaceholder"]!,
          error: _fieldErrors["email"],
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _field(
          controller: _message,
          label: _fields["message"]!,
          hint: _fields["messagePlaceholder"]!,
          error: _fieldErrors["message"],
          maxLines: 6,
        ),
        if (AppConfig.hasTurnstile) ...[
          const SizedBox(height: 16),
          CloudflareTurnstile(
            siteKey: AppConfig.turnstileSiteKey,
            baseUrl: AppConfig.apiBaseUrl,
            controller: _turnstileController,
            options: TurnstileOptions(
              theme: TurnstileTheme.dark,
              size: TurnstileSize.flexible,
            ),
            onTokenReceived: (token) => setState(() => _turnstileToken = token),
            onTokenExpired: () => setState(() => _turnstileToken = null),
            onError: (_) => setState(() => _turnstileToken = null),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _pending ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: SundayColors.accent,
              foregroundColor: SundayColors.accentInk,
              disabledBackgroundColor: SundayColors.accentDim,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            child: Text(
              _pending ? _fields["sending"]! : _fields["submit"]!,
              style: theme.textTheme.titleSmall?.copyWith(
                color: SundayColors.accentInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? error,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: SundayColors.accent),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: SundayColors.ink),
          cursorColor: SundayColors.accent,
          decoration: InputDecoration(hintText: hint, errorText: error),
        ),
      ],
    );
  }
}

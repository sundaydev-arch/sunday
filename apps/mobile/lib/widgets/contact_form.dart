import "package:cloudflare_turnstile/cloudflare_turnstile.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/analytics.dart";
import "../core/config.dart";
import "../core/di.dart";
import "../core/mobile_copy.dart";
import "../core/theme.dart";
import "../data/connectivity_service.dart";
import "../data/contact_api.dart";
import "../data/contact_outbox.dart";
import "../data/contact_validation.dart";
import "../i18n/dictionary.dart";
import "../i18n/locale_controller.dart";
import "app_chrome.dart";

class ContactForm extends ConsumerStatefulWidget {
  const ContactForm({super.key, required this.dict});

  final Dictionary dict;

  @override
  ConsumerState<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<ContactForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  final _turnstileController = TurnstileController();

  String? _turnstileToken;
  var _pending = false;
  var _submitted = false;
  Map<String, String> _fieldErrors = {};
  String? _formErrorTitle;
  String? _formErrorDetail;

  Map<String, String> get _fields => widget.dict.contactFields;
  Map<String, String> get _validation => widget.dict.contactValidation;

  void _setFormError(String title, {String? detail}) {
    setState(() {
      _formErrorTitle = title;
      _formErrorDetail = detail;
    });
  }

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

  void _revalidateVisible() {
    if (!_submitted) return;
    final parsed = parseContactBody(
      name: _name.text,
      email: _email.text,
      message: _message.text,
      turnstileToken: _turnstileToken,
    );
    setState(() {
      _fieldErrors = {
        for (final e in (parsed.fieldErrors ?? {}).entries)
          e.key: _messageFor(e.value),
      };
    });
  }

  Future<void> _submit() async {
    if (_pending) return;

    if (AppConfig.hasTurnstile &&
        (_turnstileToken == null || _turnstileToken!.isEmpty)) {
      HapticFeedback.heavyImpact();
      _setFormError(
        _fields["error"]!,
        detail: _messageFor("captcha_required"),
      );
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
        _submitted = true;
        _formErrorTitle = null;
        _formErrorDetail = null;
        _fieldErrors = {
          for (final e in (parsed.fieldErrors ?? {}).entries)
            e.key: _messageFor(e.value),
        };
      });
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _pending = true;
      _submitted = false;
      _fieldErrors = {};
      _formErrorTitle = null;
      _formErrorDetail = null;
    });

    final connectivity = getIt<ConnectivityService>();
    final outbox = getIt<ContactOutbox>();
    final api = ref.read(contactApiProvider);
    final payload = parsed.data!;
    final zhLocale = Localizations.localeOf(context).languageCode == "zh";

    ContactSubmitResult result;
    if (!connectivity.isOnline) {
      if (AppConfig.hasTurnstile) {
        // Captcha cannot be completed / replayed offline.
        result = const ContactSubmitErr(message: "network");
      } else {
        await outbox.enqueue(payload);
        result = const ContactSubmitQueued();
      }
    } else {
      result = await api.submit(payload);
      if (result is ContactSubmitErr &&
          result.message == "network" &&
          !AppConfig.hasTurnstile) {
        await outbox.enqueue(payload);
        result = const ContactSubmitQueued();
      }
    }

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
        if (AppConfig.hasTurnstile) {
          await _turnstileController.refreshToken();
        }
        HapticFeedback.mediumImpact();
        _toastSuccess(_fields["success"]!);
      case ContactSubmitQueued():
        await Analytics.instance.captureEvent(
          AnalyticsEvents.contactSubmitSucceeded,
          properties: {"queued": true},
        );
        _name.clear();
        _email.clear();
        _message.clear();
        _turnstileToken = null;
        if (AppConfig.hasTurnstile) {
          await _turnstileController.refreshToken();
        }
        HapticFeedback.mediumImpact();
        _toastSuccess(
          zhLocale ? "已加入发送队列" : "Saved to send queue",
          detail: zhLocale
              ? "网络恢复后会自动发送。"
              : "We’ll send it automatically when you’re back online.",
        );
      case ContactSubmitErr(:final message, :final statusCode, :final code):
        await Analytics.instance.captureEvent(
          AnalyticsEvents.contactSubmitFailed,
          properties: {"status": statusCode ?? 0},
        );
        await Analytics.instance.captureException(
          Exception("contact_submit_failed"),
          stackTrace: StackTrace.current,
          extras: {
            "status": statusCode ?? 0,
            "code": code ?? "",
            "message": message,
          },
        );
        final detail = message == "network"
            ? _fields["network"]!
            : (code != null ? _messageFor(code) : message);
        HapticFeedback.heavyImpact();
        _setFormError(_fields["error"]!, detail: detail);
        _turnstileToken = null;
        if (AppConfig.hasTurnstile) {
          await _turnstileController.refreshToken();
        }
    }
  }

  void _toastSuccess(String title, {String? detail}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final bottomInset = appBottomChromeInset(context);

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
        duration: const Duration(seconds: 4),
        backgroundColor: SundayColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SundayRadii.md),
          side: const BorderSide(color: SundayColors.accent),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: SundayColors.accent,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: SundayColors.ink,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: SundayColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MobileCopy.formLead(locale), style: theme.textTheme.titleMedium),
        const SizedBox(height: 28),
        _field(
          controller: _name,
          label: MobileCopy.name(locale),
          hint: MobileCopy.nameHint(locale),
          error: _fieldErrors["name"],
          fieldKey: "name",
          autofill: const [AutofillHints.name],
        ),
        const SizedBox(height: 18),
        _field(
          controller: _email,
          label: MobileCopy.email(locale),
          hint: MobileCopy.emailHint(locale),
          error: _fieldErrors["email"],
          fieldKey: "email",
          keyboard: TextInputType.emailAddress,
          autocorrect: false,
          autofill: const [AutofillHints.email],
        ),
        const SizedBox(height: 18),
        _field(
          controller: _message,
          label: MobileCopy.message(locale),
          hint: MobileCopy.messageHint(locale),
          error: _fieldErrors["message"],
          fieldKey: "message",
          maxLines: 6,
        ),
        if (AppConfig.hasTurnstile) ...[
          const SizedBox(height: 20),
          CloudflareTurnstile(
            siteKey: AppConfig.turnstileSiteKey,
            baseUrl: AppConfig.apiBaseUrl,
            controller: _turnstileController,
            options: TurnstileOptions(
              theme: TurnstileTheme.light,
              size: TurnstileSize.flexible,
            ),
            onTokenReceived: (token) {
              setState(() {
                _turnstileToken = token;
                _formErrorTitle = null;
                _formErrorDetail = null;
              });
            },
            onTokenExpired: () => setState(() => _turnstileToken = null),
            onError: (_) => setState(() => _turnstileToken = null),
          ),
        ],
        if (_formErrorTitle != null) ...[
          const SizedBox(height: 16),
          _FormErrorBanner(
            title: _formErrorTitle!,
            detail: _formErrorDetail,
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _pending ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: _pending
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(MobileCopy.sending(locale)),
                    ],
                  )
                : Text(MobileCopy.submit(locale)),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String fieldKey,
    String? error,
    TextInputType? keyboard,
    int maxLines = 1,
    bool autocorrect = true,
    List<String>? autofill,
  }) {
    final hasError = error != null;
    final theme = Theme.of(context);
    final borderColor = hasError ? SundayColors.danger : SundayColors.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          autocorrect: autocorrect,
          autofillHints: autofill,
          style: theme.textTheme.bodyMedium?.copyWith(color: SundayColors.ink),
          cursorColor: SundayColors.ink,
          onChanged: (_) {
            if (_fieldErrors.containsKey(fieldKey) || _submitted) {
              _revalidateVisible();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            errorMaxLines: 2,
            filled: true,
            fillColor: SundayColors.field,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SundayRadii.sm),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SundayRadii.sm),
              borderSide: BorderSide(
                color: hasError ? SundayColors.danger : SundayColors.ink,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SundayRadii.sm),
              borderSide: const BorderSide(color: SundayColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SundayRadii.sm),
              borderSide: const BorderSide(
                color: SundayColors.danger,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormErrorBanner extends StatelessWidget {
  const _FormErrorBanner({required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SundayColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SundayRadii.sm),
        border: Border.all(color: SundayColors.danger.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: SundayColors.danger,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: SundayColors.ink,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SundayColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/di.dart";
import "../core/theme.dart";
import "../data/connectivity_service.dart";
import "../data/contact_outbox.dart";
import "../i18n/locale_controller.dart";

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => getIt<ConnectivityService>(),
);

final contactOutboxProvider = Provider<ContactOutbox>(
  (ref) => getIt<ContactOutbox>(),
);

/// Strip below the top chrome when offline or draining the outbox.
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  ConnectivityService? _connectivity;
  ContactOutbox? _outbox;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_connectivity != null) return;
    _connectivity = ref.read(connectivityServiceProvider);
    _outbox = ref.read(contactOutboxProvider);
    _connectivity!.addListener(_onChange);
    _outbox!.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _connectivity?.removeListener(_onChange);
    _outbox?.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = _connectivity;
    final outbox = _outbox;
    if (connectivity == null || outbox == null) {
      return const SizedBox.shrink();
    }

    final locale = ref.watch(localeProvider);
    final offline = !connectivity.isOnline;
    final queued = outbox.pendingCount;
    final draining = outbox.isDraining;

    if (!offline && queued == 0 && !draining) {
      return const SizedBox.shrink();
    }

    final zh = locale == "zh";
    final String text;
    if (offline) {
      text = zh
          ? (queued > 0 ? "离线中 · $queued 条消息将在恢复后发送" : "当前离线 — 部分功能暂不可用")
          : (queued > 0
                ? "You’re offline · $queued message(s) will send later"
                : "You’re offline — some features need a network");
    } else if (draining) {
      text = zh ? "正在发送排队中的消息…" : "Sending queued messages…";
    } else {
      text = zh ? "$queued 条消息待发送" : "$queued message(s) waiting to send";
    }

    return Material(
      color: offline
          ? SundayColors.danger.withValues(alpha: 0.92)
          : SundayColors.accent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          children: [
            Icon(
              offline ? Icons.cloud_off_rounded : Icons.cloud_upload_outlined,
              size: 16,
              color: offline ? SundayColors.ink : SundayColors.accentInk,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: offline ? SundayColors.ink : SundayColors.accentInk,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

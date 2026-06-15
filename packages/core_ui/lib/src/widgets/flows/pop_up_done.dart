import 'dart:async';

import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../typography.dart';
import '../button/wh_button.dart';

class WhPopUpDone extends StatefulWidget {
  const WhPopUpDone({
    super.key,
    required this.nextStepLabel,
    required this.onBackToFlow,
    this.onDetail,
    this.detailLabel,
    this.autoCloseSeconds = 7,
  });

  final String nextStepLabel;
  final VoidCallback onBackToFlow;
  final VoidCallback? onDetail;
  final String? detailLabel;
  final int autoCloseSeconds;

  @override
  State<WhPopUpDone> createState() => _WhPopUpDoneState();
}

class _WhPopUpDoneState extends State<WhPopUpDone> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoCloseSeconds > 0) {
      _timer = Timer(Duration(seconds: widget.autoCloseSeconds), () {
        widget.onBackToFlow();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: WHColors.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: WHColors.success2, width: 5),
                color: WHColors.surface,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: WHColors.success2,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ALL DONE!',
              style: WHTypography.title.copyWith(
                color: WHColors.success1,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.nextStepLabel,
              textAlign: TextAlign.center,
              style: WHTypography.bodyText.copyWith(
                color: WHColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            if (widget.onDetail != null && widget.detailLabel != null) ...[
              WHButton(
                label: widget.detailLabel!,
                onPressed: () {
                  _timer?.cancel();
                  widget.onDetail!();
                },
                backgroundColor: WHColors.primary3,
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  _timer?.cancel();
                  widget.onBackToFlow();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: WHColors.textPrimary,
                  backgroundColor: WHColors.surface,
                  side: const BorderSide(color: WHColors.grey3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Back to Flow',
                  style: WHTypography.bodyText.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showWhPopUpDone({
  required BuildContext context,
  required String nextStepLabel,
  required VoidCallback onBackToFlow,
  VoidCallback? onDetail,
  String? detailLabel,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => WhPopUpDone(
      nextStepLabel: nextStepLabel,
      onBackToFlow: onBackToFlow,
      onDetail: onDetail,
      detailLabel: detailLabel,
    ),
  );
}

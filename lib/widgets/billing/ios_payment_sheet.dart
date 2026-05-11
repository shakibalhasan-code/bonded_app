import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Mock iOS-style payment bottom sheet shown when [BillingConfig.isIosDebug]
/// is enabled.
///
/// Mimics Apple's subscription / IAP confirmation sheet so the UX can be
/// tested and reviewed without a real App Store connection.
class IosPaymentSheet extends StatefulWidget {
  const IosPaymentSheet({
    super.key,
    required this.productId,
    required this.displayName,
    required this.price,
    this.isSubscription = false,
    required this.onConfirm,
    required this.onCancel,
  });

  final String productId;
  final String displayName;
  final String price;
  final bool isSubscription;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  State<IosPaymentSheet> createState() => _IosPaymentSheetState();
}

class _IosPaymentSheetState extends State<IosPaymentSheet> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7), // iOS grouped background
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            _header(),
            const SizedBox(height: 4),
            _productCard(),
            const SizedBox(height: 12),
            _debugBadge(),
            const SizedBox(height: 16),
            _confirmButton(),
            const SizedBox(height: 8),
            _cancelButton(),
            const SizedBox(height: 8),
            _termsText(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Drag handle ────────────────────────────────────────────────────────────

  Widget _handle() => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );

  // ── App header (icon + name) ───────────────────────────────────────────────

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonded',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'In-App Purchase',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // ── Product card ───────────────────────────────────────────────────────────

  Widget _productCard() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Color(0xFF6C63FF),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.isSubscription
                                ? 'Auto-renewing subscription'
                                : 'One-time purchase',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // ── TEST MODE badge ────────────────────────────────────────────────────────

  Widget _debugBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD60A), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.science_outlined, size: 14, color: Color(0xFF856404)),
            SizedBox(width: 5),
            Text(
              'TEST MODE — no real charge',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF856404),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      );

  // ── Confirm button ─────────────────────────────────────────────────────────

  Widget _confirmButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: const Color(0xFF007AFF), // iOS blue
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.symmetric(vertical: 14),
            onPressed: _processing ? null : _handleConfirm,
            child: _processing
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Text(
                    widget.isSubscription ? 'Subscribe' : 'Pay ${widget.price}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      );

  // ── Cancel ─────────────────────────────────────────────────────────────────

  Widget _cancelButton() => CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _processing ? null : widget.onCancel,
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 17,
            color: Color(0xFF007AFF),
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  // ── Terms ──────────────────────────────────────────────────────────────────

  Widget _termsText() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          widget.isSubscription
              ? 'Subscription automatically renews unless cancelled at least '
                '24 hours before the end of the period.'
              : 'Payment will be charged to your Apple ID account.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            height: 1.4,
          ),
        ),
      );

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _handleConfirm() async {
    setState(() => _processing = true);
    // Simulate the brief processing delay Apple's sheet shows.
    await Future.delayed(const Duration(milliseconds: 900));
    widget.onConfirm();
  }
}

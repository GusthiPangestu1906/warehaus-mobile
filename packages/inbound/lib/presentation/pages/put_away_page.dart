import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/pa_scan_card.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_header.dart';
import 'package:inbound/presentation/widgets/quality_control_put_away/qc_product_card.dart';

class PutAwayPage extends StatefulWidget {
  const PutAwayPage({super.key});

  @override
  State<PutAwayPage> createState() => _PutAwayPageState();
}

class _PutAwayPageState extends State<PutAwayPage> {
  final bool _isLastProduct = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHColors.background,
      appBar: WHAppbar(title: 'Put Away'),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: WHButton(
          label: _isLastProduct ? 'Finish Put Away' : 'Next Product',
          backgroundColor: WHColors.secondary3,
          onPressed: () {
            if (_isLastProduct) {
              Navigator.pop(context);
            } else {
              // Navigate to the next product
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          QcHeader(
            typeLabel: 'PURCHASE ORDER',
            orderNumber: 'PO-9805-Y',
            currentItem: 1,
            totalItems: 5,
          ),
          const SizedBox(height: 18),
          QcProductCard(
            sku: 'SKU-12345',
            productName: 'Product Name Example',
            expectedQty: 100,
            unitOfMeasure: 'pcs',
          ),
          const SizedBox(height: 16),
          PaScanCard(),
          const SizedBox(height: 16),
          if (!_isLastProduct) ...[
            Text(
              'Upcoming',
              style: WHTypography.bodyText.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            QcProductCard(
              sku: 'SKU-67890',
              productName: 'Next Product Example',
              expectedQty: 50,
              unitOfMeasure: 'pcs',
            ),
          ],
        ],
      ),
    );
  }
}

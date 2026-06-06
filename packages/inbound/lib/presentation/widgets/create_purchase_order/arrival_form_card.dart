import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class ArrivalFormCard extends StatefulWidget {
  const ArrivalFormCard({
    super.key,
    required this.supplierNameController,
    required this.etaController,
    required this.carrierController,
  });

  final TextEditingController supplierNameController;
  final TextEditingController etaController;
  final TextEditingController carrierController;

  @override
  State<ArrivalFormCard> createState() => _ArrivalFormCardState();
}

class _ArrivalFormCardState extends State<ArrivalFormCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final etaText = widget.etaController.text;

    return Container(
      decoration: BoxDecoration(
        color: WHColors.grey4,
        border: Border.all(color: WHColors.grey5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Arrival Information',
                      style: WHTypography.heading2.copyWith(
                        color: WHColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: WHColors.grey3,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        WHTextField(
                          label: 'Supplier Name',
                          hintText: 'e.g., Mayora',
                          controller: widget.supplierNameController,
                        ),
                        const SizedBox(height: 16),
                        WHDateField(
                          label: 'Expected Arrival Date (ETA):',
                          hintText: '01/01/2026',
                          selectedDate: etaText.isEmpty
                              ? null
                              : DateTime.tryParse(etaText),
                          onDateSelected: (date) {
                            setState(() {
                              widget.etaController.text = date
                                  .toIso8601String()
                                  .split('T')
                                  .first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        WHTextField(
                          label: 'Carrier',
                          hintText: 'e.g., JNE Cargo',
                          controller: widget.carrierController,
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

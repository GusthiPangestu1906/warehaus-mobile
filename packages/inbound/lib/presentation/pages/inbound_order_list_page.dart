import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:inbound/presentation/pages/create_purchase_order_page.dart';

class InboundOrderListPage extends StatefulWidget {
  const InboundOrderListPage({super.key});

  @override
  State<InboundOrderListPage> createState() => _InboundOrderListPageState();
}

class _InboundOrderListPageState extends State<InboundOrderListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WHAppbar(title: 'FLOW MANAGEMENT'),
      body: const Center(
        child: Text('List of Inbound Orders will be displayed here.'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'inbound-create-po-fab',
        onPressed: () async {
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const CreatePurchaseOrderPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        backgroundColor: WHColors.primary3,
        child: const Icon(Icons.add, color: WHColors.surface),
      ),
    );
  }
}

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/bloc/sales_order_state.dart';
import 'package:outbound/presentation/pages/create_sales_order_page.dart';
import 'package:outbound/presentation/pages/sales_order_list_page.dart';

final _getIt = GetIt.instance;

class OutboundListPage extends StatefulWidget {
  const OutboundListPage({super.key});

  @override
  State<OutboundListPage> createState() => _OutboundListPageState();
}

class _OutboundListPageState extends State<OutboundListPage> {
  late final SalesOrderBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = _getIt<SalesOrderBloc>()..add(GetSalesOrdersEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<SalesOrderBloc, SalesOrderState>(
        listener: (context, state) {
          if (state is SalesOrderError) {
            WHSnackBar.showError(context, state.message);
          } else if (state is SalesOrderActionSuccess &&
              state.message == 'Sales Order Deleted') {
            _showSalesOrderNotice(
              context,
              message: 'Sales Order Deleted',
              backgroundColor: const Color(0xFFC71920),
            );
          }
        },
        child: Scaffold(
          backgroundColor: WHColors.background,
          appBar: const WHAppbar(title: 'OUTBOUND'),
          body: const SalesOrderListPage(),
          floatingActionButton: FloatingActionButton(
            heroTag: 'outbound-create-so-fab',
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => BlocProvider.value(
                    value: _bloc,
                    child: const CreateSalesOrderPage(),
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              if (!context.mounted || saved != true) return;
              _showSalesOrderNotice(
                context,
                message: 'Sales Order Saved',
                backgroundColor: const Color(0xFF27C46A),
              );
            },
            backgroundColor: WHColors.primary3,
            child: const Icon(Icons.add, color: WHColors.surface),
          ),
        ),
      ),
    );
  }
}

void _showSalesOrderNotice(
  BuildContext context, {
  required String message,
  required Color backgroundColor,
}) {
  final overlay = Overlay.of(context);
  final topInset = MediaQuery.of(context).padding.top;
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: topInset,
      left: 0,
      right: 0,
      child: Material(
        color: backgroundColor,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future<void>.delayed(const Duration(seconds: 2), () {
    if (entry.mounted) entry.remove();
  });
}

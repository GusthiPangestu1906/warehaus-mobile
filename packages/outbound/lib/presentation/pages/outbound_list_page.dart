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
          }
        },
        child: Scaffold(
          backgroundColor: WHColors.background,
          appBar: const WHAppbar(title: 'OUTBOUND'),
          body: const SalesOrderListPage(),
          floatingActionButton: FloatingActionButton(
            heroTag: 'outbound-create-so-fab',
            onPressed: () async {
              await Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => BlocProvider.value(
                    value: _bloc,
                    child: const CreateSalesOrderPage(),
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
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

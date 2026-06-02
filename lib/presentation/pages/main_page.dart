import 'package:core_ui/core_ui.dart';
import 'package:dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/presentation/pages/inbound_order_list_page.dart';
import 'package:mobile/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_event.dart';
import 'package:mobile/presentation/bloc/navigation_state.dart';
import 'package:outbound/outbound.dart';
import 'package:product/presentation/pages/product_list_page.dart';
import 'package:zone/presentation/pages/zone_list_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: const [
              DashboardPage(),
              ProductListPage(),
              InboundOrderListPage(),
              ZoneListPage(),
              OutboundListPage(),
            ],
          ),
          bottomNavigationBar: WHBottomNav(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<NavigationBloc>().add(ChangeTabEvent(index));
            },
          ),
        );
      },
    );
  }
}

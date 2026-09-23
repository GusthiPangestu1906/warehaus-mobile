import 'package:auth/domain/entities/app_permissions.dart';
import 'package:auth/domain/entities/user_session.dart';
import 'package:auth/presentation/bloc/auth_bloc.dart';
import 'package:auth/presentation/bloc/auth_state.dart';
import 'package:auth/presentation/pages/setting_page.dart';
import 'package:core_ui/core_ui.dart';
import 'package:dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/presentation/pages/flow_management_page.dart';
import 'package:mobile/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_event.dart';
import 'package:mobile/presentation/bloc/navigation_state.dart';
import 'package:product/presentation/pages/product_list_page.dart';
import 'package:zone/presentation/pages/zone_list_page.dart';

/// Definisi satu entry tab: widget halaman + item nav bar.
class _TabEntry {
  final Widget page;
  final WHBottomNavItem navItem;

  const _TabEntry({required this.page, required this.navItem});
}

/// Membangun daftar tab yang dapat diakses user berdasarkan [session].
List<_TabEntry> _buildAllowedTabs(UserSession session) {
  final tabs = <_TabEntry>[];

  // Dashboard — tampil jika punya dashboard:view
  if (session.hasPermission(AppPermissions.dashboardView)) {
    tabs.add(
      const _TabEntry(
        page: DashboardPage(),
        navItem: WHBottomNavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'DASHBOARD',
        ),
      ),
    );
  }

  // Product — tampil jika punya product:view
  if (session.hasPermission(AppPermissions.productView)) {
    tabs.add(
      const _TabEntry(
        page: ProductListPage(),
        navItem: WHBottomNavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'PRODUCTS',
        ),
      ),
    );
  }

  // Flows (Inbound + Outbound) — tampil jika bisa akses inbound ATAU outbound
  final canViewInbound =
      session.hasPermission(AppPermissions.poView) ||
      session.hasPermission(AppPermissions.qcExecute) ||
      session.hasPermission(AppPermissions.putExecute);

  final canViewOutbound =
      session.hasPermission(AppPermissions.soView) ||
      session.hasPermission(AppPermissions.pickExecute) ||
      session.hasPermission(AppPermissions.packExecute);

  if (canViewInbound || canViewOutbound) {
    tabs.add(
      const _TabEntry(
        page: FlowManagementPage(),
        navItem: WHBottomNavItem(
          icon: Icons.local_shipping_outlined,
          activeIcon: Icons.local_shipping,
          label: 'FLOWS',
        ),
      ),
    );
  }

  // Zone — tampil jika punya zone:view
  if (session.hasPermission(AppPermissions.zoneView)) {
    tabs.add(
      const _TabEntry(
        page: ZoneListPage(),
        navItem: WHBottomNavItem(
          icon: Icons.layers_outlined,
          activeIcon: Icons.layers,
          label: 'ZONES',
        ),
      ),
    );
  }

  // Setting
  tabs.add(
    const _TabEntry(
      page: SettingPage(),
      navItem: WHBottomNavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'SETTING',
      ),
    ),
  );

  return tabs;
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthState = context.read<AuthBloc>().state;

    // Jika session tidak tersedia (seharusnya tidak terjadi karena MainPage
    // hanya dibuka dari AuthenticatedState), tampilkan semua tab sebagai fallback.
    final UserSession? session = AuthState is AuthenticatedState
        ? AuthState.session
        : null;

    final tabs = session != null
        ? _buildAllowedTabs(session)
        : [
            // Fallback: tampilkan semua tab
            const _TabEntry(
              page: DashboardPage(),
              navItem: WHBottomNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'DASHBOARD',
              ),
            ),
            const _TabEntry(
              page: ProductListPage(),
              navItem: WHBottomNavItem(
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'PRODUCTS',
              ),
            ),
            const _TabEntry(
              page: FlowManagementPage(),
              navItem: WHBottomNavItem(
                icon: Icons.local_shipping_outlined,
                activeIcon: Icons.local_shipping,
                label: 'FLOWS',
              ),
            ),
            const _TabEntry(
              page: ZoneListPage(),
              navItem: WHBottomNavItem(
                icon: Icons.layers_outlined,
                activeIcon: Icons.layers,
                label: 'ZONES',
              ),
            ),
          ];

    // Jika tidak ada tab sama sekali, tampilkan layar kosong
    if (tabs.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada akses halaman.')),
      );
    }

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        // Pastikan index tidak melebihi jumlah tab yang tersedia
        final safeIndex = state.currentIndex.clamp(0, tabs.length - 1);

        return Scaffold(
          body: IndexedStack(
            index: safeIndex,
            children: tabs.map((t) => t.page).toList(),
          ),
          bottomNavigationBar: WHBottomNav(
            currentIndex: safeIndex,
            items: tabs.map((t) => t.navItem).toList(),
            onTap: (index) {
              context.read<NavigationBloc>().add(ChangeTabEvent(index));
            },
          ),
        );
      },
    );
  }
}
